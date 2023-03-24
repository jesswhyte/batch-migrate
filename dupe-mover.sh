#!/bin/bash

function show_help() {
  echo
  echo -e "USAGE: bash dupe-mover.sh -c ../duplicates-Hill-list.csv "
  echo -e "-c : csv of dupe files"
  echo -e "-d : directory to run on"
  echo -e "-N : don't actually move the files, **** use this for a dry run ****"
  echo -e ""
}

function fail_exit() {
    exit $1
}

DRYRUN=false
CSV=""
DIR="" 

while getopts "h?c:d:N" OPTION
do
  case "${OPTION}" in
    h|\?)
        show_help
        fail_exit 1
        ;;
    c) CSV=${OPTARG};;
    d) DIR=${OPTARG};;
    N) DRYRUN=true
  esac
done

# set old md5 value to blank
old_md5=""

DIR=${DIR%/}

# read each line of input file
while IFS=',' read -r name size mtime error md5 namespace ID format version MIME basis warning; do
  disknum=$(echo "${name}" | awk -F"_" '{print $4}' | sed 's/-Extracted*//' | awk -F"/" '{print $1}')
  diskdir=$(echo "${name}" | awk -F"/" '{print $1}' | sed 's/-Extracted*//')
  # check if md5 is same as old md5
  if [ "$md5" != "$old_md5" ]; then
    echo
    echo "Keeping ${DIR}/${name}"
    old_md5=${md5}
  else
    #echo "verifying Duplicate: ${name} exists"
    newname=$(echo ${name} | sed 's/"//g')
    if [ ! -f "${DIR}/${newname}" ]; then
        echo "${newname} does not exist"
    else
      if $DRYRUN; then
        echo "Duplicate: "${DIR}/${newname}", will move to ${DIR}/${diskdir}-Duplicates/"
	    else
        mv -v "${DIR}/${newname}" ${DIR}/${diskdir}-Duplicates/
		    echo "MOVED: ${DIR}/${newname} to ${DIR}/${diskdir}-Duplicates/"
	    fi
    fi
  fi
done < "$CSV"
