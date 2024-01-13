#!/usr/bin/fish
# Maintain the list of resources I want auto-published every day out of my Obsidian vault

set LOGFILE ~/.cron/logs/publish.log
fish ~/.cron/help_scripts/rotate_logs.sh $LOGFILE
# disable noise errors that X display cannot be opened
set -x DISPLAY :0 &>> $LOGFILE
set DATE  "$(date -u +%Y-%m-%d\ %H:%M%Z)"
set COMMIT "$(hostname)-$DATE"
set TMP_FILE "/tmp/cron-publish-$DATE"

function copy_file 
    set SOURCE_FILE $argv[1]
    set DEST_FILE $argv[2]
    set SOURCE_HEADING $argv[3]

    if not test -f $SOURCE_FILE
        echo "Source file does not exist"
        return 1
    end
    if not test -f $DEST_FILE
        echo "Destination file does not exist"
        return 1
    end
    if not rg -q "^$SOURCE_HEADING\$" $SOURCE_FILE
        echo "Source file does not contain the heading $SOURCE_HEADING"
        return 1
    end
    if not rg -q "^$SOURCE_HEADING\$" $DEST_FILE
        echo "Destination file does not contain the heading $SOURCE_HEADING"
        return 1
    end

    # Extract the section from the source file to a tmp file
    set heading_type (echo $SOURCE_HEADING | cut -f1 --delimiter=" " )
    set start_line (rg --no-heading --line-number "^$SOURCE_HEADING" $SOURCE_FILE | cut -f1 -d:)
    set section_candidate (rg --no-heading --line-number "^$heading_type " $SOURCE_FILE | rg --no-heading "^$start_line:" -A1 | cut --delimiter=":" -f1)
    set n_matches (printf '%s\n' $section_candidate | count)

    if test $n_matches -eq 2
        # get the next heading line number, subtract one
        set end_line (echo $section_candidate | cut -f2 --delimiter=" ")
        set end_line (math "$end_line - 1")
    else
        # heading was last in file, cut to the end of the file
        set end_line $(wc -l < "$SOURCE_FILE")
    end
    set n_total_lines (math "$end_line - $start_line + 1")

    # extract the section to a tmp file
    echo "cutting from line $start_line to $end_line in $SOURCE_FILE"
    # sed -n "$start_line,$end_line p" $SOURCE_FILE > $TMP_FILE
    echo (head $SOURCE_FILE -n $end_line | tail -n $n_total_lines)
    echo -e "\n--\n"
    head $SOURCE_FILE -n $end_line | tail -n $n_total_lines > $TMP_FILE
    cat $TMP_FILE

    # # Replace the section in the destination file
    # # This is a bit tricky and might need a more complex solution like a temporary file
    # set temp_file (mktemp)
    # awk -v heading="$SOURCE_HEADING" -v replacement="$section" '
    #     BEGIN {skip=0}
    #     /^$/ {skip=0}
    #     skip {next}
    #     {print}
    #     /^'"$SOURCE_HEADING"'$/ {
    #         print replacement
    #         skip=1
    #     }
    # ' $DEST_FILE > $temp_file
    # mv $temp_file $DEST_FILE
end

copy_file ~/tmp/j-2024-01-12.md ~/tmp/j-2024-01-13.md "## test"
