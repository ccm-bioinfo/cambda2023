#!/bin/bash
# Usage:  ./download.sh [username]@[url]:[directory] [files]

# Change to base directory and create raw/ directory
cd $(dirname "$(dirname "$(readlink -f $0)")")
mkdir -p raw/

# Change to raw/ directory and download requested files into it
cd raw/
sftp -o ServerAliveInterval=60 $1 <<EOF
get -a $2
exit
EOF
