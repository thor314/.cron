#!/usr/bin/fish
# Maintain the list of resources I want auto-published every day out of my Obsidian vault

# move images

function copy_file 
    set SOURCE_FILE $argv[1]
    set SOURCE_HEADING $argv[2]
    set DEST_FILE $argv[3]

    if not test -f $SOURCE_FILE
        echo "Source file does not exist"
        return 1
    end
    if not test -f $DEST_FILE
        echo "Destination file does not exist"
        return 1
    end
    if not rg -q "^$SOURCE_HEADING$" $SOURCE_FILE
        echo "Source file does not contain the heading $SOURCE_HEADING"
        return 1
    end
    if not rg -q "^$SOURCE_HEADING$" $DEST_FILE
        echo "Destination file does not contain the heading $SOURCE_HEADING"
        return 1
    end

    # Extract the section from the source file
    set heading_type (echo $SOURCE_HEADING | cut -f1 --delimiter=" " )
    set start_line (rg --no-heading --line-number "^$SOURCE_HEADING" $SOURCE_FILE | cut -f1 -d:)
    set section_candidate (rg --no-heading --line-number "^$heading_type " $SOURCE_FILE | rg --no-heading "^$start_line:" -A1 | cut --delimiter=":" -f1)
    if ($section_candidate | count) -lt 2
        # heading was last in file, cut to the end of the file
        set end_line $(wc -l < "$SOURCE_FILE")
        set end_line # last_line in file
    else
        # cut to the 
        set end_line (echo $section_candidate | tail -n 1)
    end

    set next_line (rg --no-heading --line-number "^$SOURCE_HEADING" $SOURCE_FILE | cut -f1 -d:)

    # extract from source_heading until the next line starting with $heading_type

    # Replace the section in the destination file
    # This is a bit tricky and might need a more complex solution like a temporary file
    set temp_file (mktemp)
    awk -v heading="$SOURCE_HEADING" -v replacement="$section" '
        BEGIN {skip=0}
        /^$/ {skip=0}
        skip {next}
        {print}
        /^'"$SOURCE_HEADING"'$/ {
            print replacement
            skip=1
        }
    ' $DEST_FILE > $temp_file
    mv $temp_file $DEST_FILE
end
