#!/bin/bash

# This script updates the symbolic links between users

# home directory
cd /home

# get the list of users starting with 'ccm_'
users=$(ls -d ccm_*)

# get the list of data folders (excluding symbolic links)
folders=$(ls -ld ccm_*/cambda2023/03_classification/generated_imgs-* | grep -v ".*->" | cut -d' ' -f9)

# remove empty lines
folders=$(echo "$folders" | sed '/^\s*$/d')

# for each user's home directory remove the broken symbolic links
for user in $users
do
  # change directory to user's home directory
  cd ${user}/cambda2023

  # get list of folders inside cambda2023/03_classification
  # keeping only the broken symbolic links
  broken_links=$(find . -maxdepth 2 -type l -exec test ! -e {} \; -print)

  # unlink the broken symbolic links
  for broken_link in $broken_links
  do
    unlink $broken_link
  done

  # return to home directory
  cd /home

  # get a sub-list of folders not owned by the current user
  subfolders=$(echo "$folders" | grep -v "${user}/cambda2023/03_classification")

  # update the group ownership of the folders
  #chgrp -R ${user} ${subfolders}

  # get a sub-list of folders not owned by the current user
  subfolders=$(echo "$folders" | grep -v "${user}/cambda2023/03_classification")

  # iterate over the sub-list of folders
  for folder in $subfolders
  do
    # replace the user name with the current user
    new_folder=$(echo "$folder" | sed "s/ccm_[a-z]*/${user}/g")
    
    # if the symlink exists continue the loop
    if [ -L "$new_folder" ]
    then
      continue
    fi

    # create the symbolic link
    echo "command: ln -s /home/$folder /home/$new_folder"
    ln -s /home/$folder /home/$new_folder
  done
done

# get a new list of folders
folders=$(ls -ld ccm_*/cambda2023/clasificacion/generated_imgs-* | grep -v ".*->" | cut -d' ' -f9)
folders=$(echo "$folders" | sed '/^\s*$/d')

# iterate over the list of folders
for folder in $folders
do
  # get an alternative folder name
  new_folder=$(echo "$folder" | sed "s/clasificacion/03_classification/g")

  # if new_folder already exists continue the loop
  if [ -d "$new_folder" ]
  then
    continue
  fi

  # copy old folder to new folder
  echo "command: cp -r $folder $new_folder"
  #cp -r "$folder" "$new_folder"
done
