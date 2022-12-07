#!/bin/bash

function show_help() {
  echo
  echo -e "USAGE: bash migrate-sel-files.sh -c CSV\n"
  echo -e "-c : csv of wanted files"
  #echo -e "-d : directory to run on"
  echo -e ""
}

function fail_exit() {
    exit $1
}

while getopts "h?c:d:" OPTION
do
  case "${OPTION}" in
    h|\?)
        show_help
        fail_exit 1
        ;;
   #d) DIR=${OPTARG};;
    c) CSV=${OPTARG};;
  esac
done

function list_files() {
    exit 
}

# for MAC environment
soffice="/Applications/LibreOffice.app/Contents/MacOS/soffice"

# find Extracted Files' Directories
find . -name "*Extracted" -type d | sort > tmp.ExtractedList

# check files within against wanted list
for DIRECTORY in $(cat tmp.ExtractedList); do
    echo && echo "-----------------------"
    echo "Checking: ${DIRECTORY}" && echo
    PARENTDIR=$(echo "${DIRECTORY}" | awk -F"/" '{print $2}')
    find ${DIRECTORY} -type f -print0 | while read -d $'\0' TESTFILE; do
        # get md5sum
        TESTMD5=$(md5sum "${TESTFILE}" | awk '{ print $1 }')
        if grep -q "${TESTMD5}" "${CSV}"; then
            mkdir -p ${PARENTDIR}/Migrated
            #echo "${TESTFILE} Found and md5sum match"
            INFO=$(grep "${TESTMD5}" ${CSV} )
            DISK=$(echo "${INFO}" | awk -F, '{ print $1 }' )
            MD5=$(echo "${INFO}" | awk -F, '{ print $5 }' )
            TYPE=$(echo "${INFO}" | awk -F, '{ print $6 }' )
            #remove newline characters
            TYPE=${TYPE//$'\n'/}
            if [[ "${TYPE}" =~ "Word" ]] || [[ "${TYPE}" =~ "WordPerfect" ]]; then
                /Applications/LibreOffice.app/Contents/MacOS/soffice --headless --convert-to pdf:writer_pdf_Export --outdir ${PARENTDIR}/Migrated/ "${TESTFILE}"
            else
                cp "${TESTFILE}" ${PARENTDIR}/Migrated/    
            fi
            chmod -R 755 ${PARENTDIR}/Migrated
            fi
        fi
    done
done 
rm tmp.*

# while IFS="," read -r DISK NAME SIZE MTIME MD5 TYPE; do 
