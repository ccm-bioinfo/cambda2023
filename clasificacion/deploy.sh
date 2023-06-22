#!/bin/bash

# This code is to deploy the given folder into all the folders with pattern "/home/ccm_*"
# The folder to deploy is the first argument
# The folder should be linked inside /home/ccm_*/CAMBDA2023/clasificacion/ only if it is not already linked
# The folder will be linked only if current user is named ccm_*
# The folder will be linked only if current host is named xeon

# get the source folder
SOURCE_FOLDER=$1

# get and validate the current user
# a valid user starts with ccm_
CURRENT_USER=$(whoami)
if [[ $CURRENT_USER != ccm_* ]]; then
    echo "Current user is not valid: $CURRENT_USER"
    exit 1
fi

# get and validate the current host
# a valid host starts with xeon
CURRENT_HOST=$(hostname)
if [[ $CURRENT_HOST != xeon* ]]; then
    echo "Current host is not valid: $CURRENT_HOST"
    exit 1
fi

# get the destination folders
DESTINATION_FOLDERS=$(find /home/ccm_* -maxdepth 1 -type d -name "CAMBDA2023")

# deploy the source folder into the destination folders
for DESTINATION_FOLDER in $DESTINATION_FOLDERS; do
    # get the destination folder
    DESTINATION_FOLDER=$(dirname $DESTINATION_FOLDER)
    DESTINATION_FOLDER=$DESTINATION_FOLDER/clasificacion

    # if destination folder does not exist, create it
    if [[ ! -d $DESTINATION_FOLDER ]]; then
        mkdir $DESTINATION_FOLDER
    fi

    # correct the destination folder based on source folder
    DESTINATION_FOLDER=$DESTINATION_FOLDER/$(basename $SOURCE_FOLDER)

    # if destination folder does not exist, create a link to the source folder
    if [[ ! -d $DESTINATION_FOLDER ]]; then
        ln -s $SOURCE_FOLDER $DESTINATION_FOLDER
    fi
done
