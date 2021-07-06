#!/usr/bin/env bash

./mcrcon -H localhost -P 25575 -p MINECRAFT_PASS say "Attempt to backup the world..."
./mcrcon -H localhost -P 25575 -w 5 -p MINECRAFT_PASS save-all save-off
# wait until all files are stored
sleep 1m

mkdir -p backup
tar -Jcvf backup/world-backup.tar.xz world
#TODO gsutil cp to GS

./mcrcon -H localhost -P 25575 -p MINECRAFT_PASS save-on say "Saving world has been restored"
