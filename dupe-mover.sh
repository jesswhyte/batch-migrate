#!/bin/bash

function show_help() {
  echo
  echo -e "USAGE: bash dupe-mover.sh -c ../duplicates-Hill-list.csv "
  echo -e "run from within directory e.g. data/"
  echo -e "-c : csv of dupe files"
  echo -e ""
}

function fail_exit() {
    exit $1
}

while getopts "h?c:" OPTION
do
  case "${OPTION}" in
    h|\?)
        show_help
        fail_exit 1
        ;;
    c) CSV=${OPTARG};;
  esac
done

# set old md5 value to blank
old_md5=""

# read each line of input file
while IFS=',' read -r name size mtime error md5 filetype version warning; do
  disknum=$(echo "${name}" | awk -F"_" '{print $4}' | sed 's/_Extracted*//' | awk -F"/" '{print $1}')
  # check if md5 is same as old md5
  if [ "$md5" != "$old_md5" ]; then
    echo
    echo "Keeping ${name}"
    old_md5=${md5}
  else
    # mkdir -p Coll593_27_Hill_${disknum}_Duplicates
    #echo "verifying Duplicate: ${name} exists"
    newname=$(echo ${name} | sed 's/"//g')
    if [ ! -f "${newname}" ]; then
        echo "${newname} does not exist"
    else
        echo "Duplicate: "${newname}", will move to Coll593_27_Hill_${disknum}_Duplicates/"
        mv -v "${newname}" Coll593_27_Hill_${disknum}_Duplicates/
    fi
  fi
done < "$CSV"
