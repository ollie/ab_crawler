# A tool to index and download old dos games

    $ rake console   # Start a console
    $ rake continue  # Continue working last index or specify one with INDEX=path/to/index.json
    $ rake download  # Downloads missing games from last index or specify one with INDEX=path/to/index.json
    $ rake index     # Create new JSON index file and save it to indexes/index_YYYYMMDDHHMMSS.json
    $ rake stats     # Show missing games, duplicates, etc
