# A tool to index and download old dos games

    $ rake console     # Start a console
    $ rake continue    # Continue working last index or specify one with INDEX=path/to/index.json
    $ rake download    # Downloads missing games from last index or specify one with INDEX=path/to/index.json
    $ rake duplicates  # Find duplicates and remove them, use DRYRUN=0 to really delete
    $ rake index       # Create new JSON index file and save it to indexes/index_YYYYMMDDHHMMSS.json
