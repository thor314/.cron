#!/usr/bin/fish
# Maintain the list of resources I want auto-published every day out of my Obsidian vault

set LOGFILE ~/.cron/logs/publish.log
# disable noise errors that X display cannot be opened
set -x DISPLAY :0 &>> $LOGFILE
set DATE  "$(date -u +%Y-%m-%d-%H:%M%Z)"
set COMMIT_MSG "$(hostname)-$DATE"
set TMP_FILE "/tmp/cron-publish-$DATE"

function copy_file 
    set SOURCE_FILE $argv[1]
    set DEST_FILE $argv[2]
    set HEADING $argv[3]
    echo "source: $SOURCE_FILE"
    echo "dest: $DEST_FILE"
    echo "heading: $HEADING"

    if not test -f $SOURCE_FILE
        echo "Source file does not exist"
        return 1
    end
    if not test -f $DEST_FILE
        echo "Destination file does not exist"
        return 1
    end
    
    if not test $HEADING
        if /home/thor/.cargo/bin/difft $SOURCE_FILE $DEST_FILE >> /dev/null
            echo "~-------------------~"
            echo "source file $SOURCE_FILE has changed and no heading specified, updating dest file"
            cp $SOURCE_FILE $DEST_FILE
            echo "~-------------------~"
            return 0
        end
    end

    if not rg -q "^$HEADING" $SOURCE_FILE
        echo "Source file does not contain the heading $HEADING"
        return 1
    end
    if not rg -q "^$HEADING" $DEST_FILE
        echo "Destination file does not contain the heading $HEADING"
        return 1
    end

    # extract the section to a tmp file
    set LINE_NUMBERS (get_line_numbers $SOURCE_FILE $HEADING)
    set START_LINE (echo $LINE_NUMBERS | cut --delimiter=" " -f1)
    set END_LINE (echo $LINE_NUMBERS | cut --delimiter=" " -f2)
    set N_TOTAL_LINES (math "$END_LINE - $START_LINE + 1")
    # echo "copying from line $START_LINE to $END_LINE in $SOURCE_FILE"
    head $SOURCE_FILE -n $END_LINE | tail -n $N_TOTAL_LINES > $TMP_FILE.new

    # todo: If I eventually get less lazy, maybe handle moving images too 

    # Replace the section in the destination file
    set LINE_NUMBERS (get_line_numbers $DEST_FILE $HEADING)
    set START_LINE (echo $LINE_NUMBERS | cut --delimiter=" " -f1)
    set END_LINE (echo $LINE_NUMBERS | cut --delimiter=" " -f2)
    set N_TOTAL_LINES (math "$END_LINE - $START_LINE + 1")
    # echo "cutting from line $START_LINE to $END_LINE in $DEST_FILE"
    head $DEST_FILE -n $END_LINE | tail -n $N_TOTAL_LINES > $TMP_FILE.old

    if /home/thor/.cargo/bin/difft $TMP_FILE.new $TMP_FILE.old >> /dev/null
        echo "~----------------------------------------------------------------~"
        echo changes detected in $DEST_FILE
        echo "<<<<<<<<<<<<<<<< replacing section:"
        cat $TMP_FILE.old
        echo --------- with section ----------
        cat $TMP_FILE.new
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

        # Replace the lines in $DEST_FILE between $START_LINE and $END_LINE with the lines in $TMP_FILE
        head -n (math $START_LINE - 1) $DEST_FILE > $TMP_FILE.all
        cat $TMP_FILE.new >> $TMP_FILE.all
        tail -n (math (count (cat $DEST_FILE)) - $END_LINE) $DEST_FILE >> $TMP_FILE.all

        cp $TMP_FILE.all $DEST_FILE
        rm $TMP_FILE.all
        echo "$DEST_FILE updated"
        echo "~----------------------------------------------------------------~"
    end
    
    rm $TMP_FILE.new $TMP_FILE.old
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

function publish
    echo ============================ 
    echo -e "cronlog: $COMMIT_MSG"    
    echo "publishing......"          
    echo ============================ 

    copy_file ~/obsidian/writing/personal/Getting\ Started\ with\ Obsidian.md  ~/projects/obsidian-setup/Getting\ Started\ with\ Obsidian.md  '## Part Three: All the plugins'

    # copy_file ~/tmp/j-2024-01-12.md ~/tmp/j-2024-01-13.md "## test"
end  

fish ~/.cron/help_scripts/rotate_logs.sh $LOGFILE
publish &>> $LOGFILE

