#!/usr/bin/env fish

# ============================================================
# focus-guard.fish -- app blocker for Linux (Wayland-compatible)
#
# Features:
#   - Focus hours: block apps entirely during configured windows
#   - Daily limits: max minutes per app per day
#   - Session limits: max continuous minutes, with warnings at 30s and 10s
#   - Cooldown: minimum time between app sessions
#
# Usage:
#   ./focus-guard.fish              # run in foreground
#   ./focus-guard.fish --daemon     # run in background
#   ./focus-guard.fish --status     # show current usage stats
#   ./focus-guard.fish --reset      # reset daily counters
#   ./focus-guard.fish --clear-sessions # clear stale session counters
#
# Config: edit the configure() function below.
# State: stored in ~/.local/share/focus-guard/
# ============================================================

set -g POLL_INTERVAL 5          # seconds between checks
set -g STATE_DIR "$HOME/.local/share/focus-guard"
set -g LOG_FILE "$STATE_DIR/focus-guard.log"

# ============================================================
# CONFIGURATION -- edit this section
# ============================================================
function configure
    # Focus hours: app is killed on sight during these windows.
    # Format: "app_process|start_HH:MM|end_HH:MM|days"
    # days: 0=Sun 1=Mon ... 6=Sat, comma-separated, or * for all
    set -g FOCUS_RULES \
        "signal-desktop|06:00|14:00|1,2,3,4,5" \
        "telegram-desktop|06:00|14:00|*"

    # Daily limits: max total minutes per day.
    # Format: "app_process|max_minutes_per_day"
    set -g DAILY_LIMITS \
        "signal-desktop|45" \
        "telegram-desktop|20"

    # Session limits: max continuous minutes before auto-close.
    # Format: "app_process|max_session_minutes"
    set -g SESSION_LIMITS \
        "signal-desktop|15" \
        "telegram-desktop|10"

    # Cooldown: minimum minutes between sessions.
    # Format: "app_process|cooldown_minutes"
    set -g COOLDOWN_RULES \
        "signal-desktop|90" \
        "telegram-desktop|90"
end

# ============================================================
# HELPERS
# ============================================================

function log_msg
    set -l ts (date '+%Y-%m-%d %H:%M:%S')
    echo "[$ts] $argv" >> $LOG_FILE
    echo "[$ts] $argv"
end

function ensure_state_dir
    mkdir -p $STATE_DIR
end

function today_key
    date '+%Y-%m-%d'
end

function now_minutes
    # minutes since midnight
    set -l h (date '+%H' | sed 's/^0//')
    set -l m (date '+%M' | sed 's/^0//')
    test -z "$h"; and set h 0
    test -z "$m"; and set m 0
    math "$h * 60 + $m"
end

function hhmm_to_minutes -a hhmm
    set -l parts (string split ':' $hhmm)
    set -l h (echo $parts[1] | sed 's/^0//')
    set -l m (echo $parts[2] | sed 's/^0//')
    test -z "$h"; and set h 0
    test -z "$m"; and set m 0
    math "$h * 60 + $m"
end

function current_dow
    date '+%w'
end

function is_app_running -a app
    pgrep -x "$app" >/dev/null 2>&1
end

function kill_app -a app -a reason
    if is_app_running $app
        log_msg "KILLING $app -- $reason"
        pkill -x "$app" 2>/dev/null
    end
end

function send_notification -a title -a body
    notify-send -u critical "$title" "$body" 2>/dev/null
end

# --- state file helpers ---

function state_file -a app -a suffix
    echo "$STATE_DIR/$app.$suffix"
end

function read_state -a app -a suffix
    set -l f (state_file $app $suffix)
    if test -f $f
        cat $f
    else
        echo ""
    end
end

function write_state -a app -a suffix -a value
    echo "$value" > (state_file $app $suffix)
end

# Daily usage in seconds
function get_daily_usage -a app
    set -l stored (read_state $app "daily."(today_key))
    test -z "$stored"; and set stored 0
    echo $stored
end

function add_daily_usage -a app -a seconds
    set -l current (get_daily_usage $app)
    set -l new_val (math "$current + $seconds")
    write_state $app "daily."(today_key) $new_val
end

# Session start time (unix timestamp)
function get_session_start -a app
    read_state $app "session_start"
end

function set_session_start -a app -a ts
    write_state $app "session_start" $ts
end

function clear_session -a app
    rm -f (state_file $app "session_start")
    rm -f (state_file $app "warned_30")
    rm -f (state_file $app "warned_10")
end

# Last close time (unix timestamp)
function get_last_close -a app
    read_state $app "last_close"
end

function set_last_close -a app -a ts
    write_state $app "last_close" $ts
end

# Warning flags
function was_warned -a app -a level
    test -f (state_file $app "warned_$level")
end

function set_warned -a app -a level
    write_state $app "warned_$level" "1"
end

# ============================================================
# RULE LOOKUPS
# ============================================================

function parse_rule -a rule
    string split '|' $rule
end

function get_daily_limit -a app
    for rule in $DAILY_LIMITS
        set -l parts (parse_rule $rule)
        if test "$parts[1]" = "$app"
            echo $parts[2]
            return
        end
    end
    echo ""
end

function get_session_limit -a app
    for rule in $SESSION_LIMITS
        set -l parts (parse_rule $rule)
        if test "$parts[1]" = "$app"
            echo $parts[2]
            return
        end
    end
    echo ""
end

function get_cooldown -a app
    for rule in $COOLDOWN_RULES
        set -l parts (parse_rule $rule)
        if test "$parts[1]" = "$app"
            echo $parts[2]
            return
        end
    end
    echo ""
end

function all_managed_apps
    set -l apps
    for rule in $FOCUS_RULES $DAILY_LIMITS $SESSION_LIMITS $COOLDOWN_RULES
        set -l parts (parse_rule $rule)
        if not contains $parts[1] $apps
            set -a apps $parts[1]
        end
    end
    printf '%s\n' $apps
end

# ============================================================
# CHECK FUNCTIONS
# ============================================================

function check_focus_hours -a app
    set -l now_min (now_minutes)
    set -l dow (current_dow)

    for rule in $FOCUS_RULES
        set -l parts (parse_rule $rule)
        test "$parts[1]" != "$app"; and continue

        set -l start_min (hhmm_to_minutes $parts[2])
        set -l end_min (hhmm_to_minutes $parts[3])
        set -l days $parts[4]

        # check day
        if test "$days" != "*"
            set -l day_list (string split ',' $days)
            if not contains $dow $day_list
                continue
            end
        end

        # check time window
        if test $start_min -le $end_min
            # normal window e.g. 06:00-12:00
            if test $now_min -ge $start_min -a $now_min -lt $end_min
                return 0  # in focus hours
            end
        else
            # overnight window e.g. 22:00-06:00
            if test $now_min -ge $start_min -o $now_min -lt $end_min
                return 0
            end
        end
    end
    return 1  # not in focus hours
end

function check_cooldown -a app
    set -l cooldown_min (get_cooldown $app)
    test -z "$cooldown_min"; and return 1  # no cooldown rule

    set -l last_close (get_last_close $app)
    test -z "$last_close"; and return 1  # never closed

    set -l now_ts (date '+%s')
    set -l elapsed_min (math "($now_ts - $last_close) / 60")

    if test $elapsed_min -lt $cooldown_min
        set -l remaining (math "$cooldown_min - $elapsed_min" | math --scale=0 ceil)
        kill_app $app "cooldown: $remaining min remaining"
        send_notification "Focus Guard" "$app: cooldown active, $remaining min remaining"
        return 0  # in cooldown
    end
    return 1
end

function check_daily_limit -a app
    set -l limit_min (get_daily_limit $app)
    test -z "$limit_min"; and return 1  # no daily limit

    set -l usage_sec (get_daily_usage $app)
    set -l usage_min (math "$usage_sec / 60")

    if test $usage_min -ge $limit_min
        kill_app $app "daily limit reached ($limit_min min)"
        send_notification "Focus Guard" "$app: daily limit of $limit_min min reached"
        return 0
    end
    return 1
end

function check_session_limit -a app
    set -l limit_min (get_session_limit $app)
    test -z "$limit_min"; and return 1  # no session limit

    set -l session_start (get_session_start $app)
    test -z "$session_start"; and return 1

    set -l now_ts (date '+%s')
    set -l elapsed_sec (math "$now_ts - $session_start")
    set -l limit_sec (math "$limit_min * 60")
    set -l remaining_sec (math "$limit_sec - $elapsed_sec")

    if test $remaining_sec -le 0
        kill_app $app "session limit reached ($limit_min min)"
        send_notification "Focus Guard" "$app: session limit of $limit_min min reached. Cooldown started."
        set_last_close $app $now_ts
        clear_session $app
        return 0
    else if test $remaining_sec -le 10
        if not was_warned $app 10
            send_notification "Focus Guard" "$app closing in 10 seconds"
            set_warned $app 10
        end
    else if test $remaining_sec -le 30
        if not was_warned $app 30
            send_notification "Focus Guard" "$app closing in 30 seconds"
            set_warned $app 30
        end
    end
    return 1
end

# ============================================================
# MAIN LOOP
# ============================================================

function run_loop
    log_msg "focus-guard started (poll every {$POLL_INTERVAL}s)"

    while true
        # echo "DEBUG: $app running=$running focus="(check_focus_hours $app; echo $status)
        for app in (all_managed_apps)
            set -l running (is_app_running $app; and echo yes; or echo no)

            if test "$running" = "yes"
                # 1. Focus hours -- highest priority
                if check_focus_hours $app
                    kill_app $app "focus hours"
                    send_notification "Focus Guard" "$app blocked during focus hours"
                    set_last_close $app (date '+%s')
                    clear_session $app
                    continue
                end

                # 2. Cooldown check
                if check_cooldown $app
                    set_last_close $app (date '+%s')
                    clear_session $app
                    continue
                end

                # 3. Daily limit check
                if check_daily_limit $app
                    set_last_close $app (date '+%s')
                    clear_session $app
                    continue
                end

                # 4. Track session
                set -l session_start (get_session_start $app)
                if test -z "$session_start"
                    set_session_start $app (date '+%s')
                    log_msg "SESSION START: $app"
                end

                # 5. Session limit check (with warnings)
                if check_session_limit $app
                    continue
                end

                # 6. Accumulate daily usage
                add_daily_usage $app $POLL_INTERVAL

            else
                # App not running -- close out session if one was active
                set -l session_start (get_session_start $app)
                if test -n "$session_start"
                    set -l now_ts (date '+%s')
                    set -l session_sec (math "$now_ts - $session_start")
                    log_msg "SESSION END: $app ({$session_sec}s)"
                    set_last_close $app $now_ts
                    clear_session $app
                end
            end
        end

        sleep $POLL_INTERVAL
    end
end

# ============================================================
# STATUS DISPLAY
# ============================================================

function show_status
    echo "focus-guard status -- "(date)
    echo ""
    set -l today (today_key)

    for app in (all_managed_apps)
        set -l running (is_app_running $app; and echo "RUNNING"; or echo "stopped")
        set -l usage_sec (get_daily_usage $app)
        set -l usage_min (math --scale=1 "$usage_sec / 60")
        set -l daily_limit (get_daily_limit $app)
        test -z "$daily_limit"; and set daily_limit "∞"

        set -l session_info ""
        set -l session_start (get_session_start $app)
        if test -n "$session_start"
            set -l now_ts (date '+%s')
            set -l s_min (math --scale=1 "($now_ts - $session_start) / 60")
            set -l s_limit (get_session_limit $app)
            test -z "$s_limit"; and set s_limit "∞"
            set session_info "  session: {$s_min}m / {$s_limit}m"
        end

        set -l cooldown_info ""
        set -l last_close (get_last_close $app)
        set -l cd_min (get_cooldown $app)
        if test -n "$last_close" -a -n "$cd_min"
            set -l now_ts (date '+%s')
            set -l elapsed (math --scale=1 "($now_ts - $last_close) / 60")
            if test (math "$elapsed < $cd_min") -eq 1
                set -l remaining (math --scale=0 "$cd_min - $elapsed")
                set cooldown_info "  cooldown: {$remaining}m left"
            end
        end

        set -l focus ""
        if check_focus_hours $app
            set focus "  [FOCUS BLOCKED]"
        end

        echo "  $app: $running  daily: {$usage_min}m / {$daily_limit}m$session_info$cooldown_info$focus"
    end
end

# ============================================================
# CLEANUP OLD STATE FILES
# ============================================================

function cleanup_old_state
    set -l today (today_key)
    for f in $STATE_DIR/*.daily.*
        if not string match -q "*$today" $f
            rm -f $f
        end
    end
end

# ============================================================
# ENTRYPOINT
# ============================================================

configure
ensure_state_dir

switch "$argv[1]"
    case --daemon
        log_msg "starting as daemon"
        cleanup_old_state
        run_loop &
        echo "focus-guard running in background (pid $last_pid)"

    case --status
        show_status

    case --reset
        for f in $STATE_DIR/*.daily.*
            rm -f $f
        end
        log_msg "daily counters reset"
        echo "daily counters reset"

    case --clear-sessions
        for app in (all_managed_apps)
            clear_session $app
        end
        log_msg "stale sessions cleared"
        echo "stale sessions cleared"
    case --help -h
        echo "usage: focus-guard.fish [--daemon|--status|--reset|--help]"
        echo ""
        echo "  (no args)   run in foreground"
        echo "  --daemon    run in background"
        echo "  --status    show current usage stats"
        echo "  --reset     reset daily counters"
        echo "  --clear-sessions  clear stale session timers"

    case '*'
        cleanup_old_state
        run_loop
end
