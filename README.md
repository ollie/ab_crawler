# A tool to index and download old dos games
    # Create new JSON index file and save it to ./indexes/index_YYYYMMDDHHMMSS.json.
    rake index
    
    # Read the JSON index file and downloads games that aren't already downloaded.
    rake download INDEX=YYYYMMDDHHMMSS
    
    # Find duplicates and remove them, use DRYRUN=0 to really delete.
    rake duplicates
    
    # Diff two logs. For example rake log:diff TOOL=meld FILE1=./indexes/index_20110228005550.log FILE2=./indexes/index_20110527123321.log.
    rake log:diff