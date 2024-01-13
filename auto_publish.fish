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

    # extract the section to a tmp file
    set LINE_NUMBERS (get_line_numbers $SOURCE_FILE $SOURCE_HEADING)
    set START_LINE (echo $LINE_NUMBERS | cut --delimiter=" " -f1)
    set END_LINE (echo $LINE_NUMBERS | cut --delimiter=" " -f2)
    set N_TOTAL_LINES (math "$END_LINE - $START_LINE + 1")
    echo "cutting from line $START_LINE to $END_LINE in $SOURCE_FILE"
    head $SOURCE_FILE -n $END_LINE | tail -n $N_TOTAL_LINES > $TMP_FILE

    echo we captured:
    cat $TMP_FILE

    # todo: If I eventually get less lazy, maybe handle moving images too 

    
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

function get_line_numbers
    set FILE $argv[1]
    set HEADING $argv[2]
    
    # Extract the section from the source file to a tmp file
    set H_TYPE (echo $HEADING | cut -f1 --delimiter=" " )
    set START_LINE (rg --no-heading --line-number "^$HEADING" $FILE | cut -f1 -d:)
    set SECTION_CANDIDATE (rg --no-heading --line-number "^$H_TYPE " $FILE | rg --no-heading "^$START_LINE:" -A1 | cut --delimiter=":" -f1)
    set N_MATCHES (printf '%s\n' $SECTION_CANDIDATE | count)

    if test $N_MATCHES -eq 2
        # get the next heading line number, subtract one
        set END_LINE (echo $SECTION_CANDIDATE | cut -f2 --delimiter=" ")
        set END_LINE (math "$END_LINE - 1")
    else
        # heading was last in file, cut to the end of the file
        set END_LINE $(wc -l < "$FILE")
    end
    
    echo $START_LINE $END_LINE
end


copy_file ~/tmp/j-2024-01-12.md ~/tmp/j-2024-01-13.md "## test"
