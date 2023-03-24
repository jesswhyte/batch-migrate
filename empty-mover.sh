#!/bin/bash

function show_help() {
  echo
  echo -e "USAGE: bash empty-mover.sh -c ../errors.csv "
  echo -e "-c : csv of errors"
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

DIR=${DIR%/}

#Siegfried/Brunnhilde errors.csv format
#File,Size,Date Modified,Errors,Warnings

# read each line of input file
while IFS=',' read -r name size date errors warning; do
  disknum=$(echo "${name}" | awk -F"_" '{print $4}' | sed 's/-Extracted*//' | awk -F"/" '{print $1}')
  diskdir=$(echo "${name}" | awk -F"/" '{print $1}' | sed 's/-Extracted*//')

  newname=$(echo ${name} | sed 's/"//g')
  if [ ! -f "${DIR}/${newname}" ]; then
      continue
      #echo "${newname} does not exist"
  else
    if [ "${errors}" == "empty source" ]; then
      if $DRYRUN; then
        echo "Empty Source File: "${DIR}/${newname}", will move to ${DIR}/${diskdir}-Excluded/"
      else
        mv -v "${DIR}/${newname}" ${DIR}/${diskdir}-Excluded/
        echo "MOVED: ${DIR}/${newname} to ${DIR}/${diskdir}-Excluded/"
      fi
    fi
  fi

done < "$CSV"
