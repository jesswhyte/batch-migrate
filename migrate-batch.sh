#!/bin/bash

function show_help() {
  echo
  echo -e "USAGE: bash "
  echo -e "-c : collection name that preceeds disk### in directory names, e.g. Coll999_162_Smith"
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
    c) COLL=${OPTARG};;
  esac
done

function list_files() {
    exit 
}

# for MAC environment
#soffice="/Applications/LibreOffice.app/Contents/MacOS/soffice"

# find Extracted Files' Directories and output to temp.ExtractedList
find . -name "${COLL}*-Extracted" -type d | sort > tmp.ExtractedList

for DIRECTORY in $(cat tmp.ExtractedList); do 
    echo && echo "---------------------------"
    PARENTDIR=$(echo "${DIRECTORY}" | awk -F"/" '{print $1}')
    DISK=$(echo "${DIRECTORY}" | awk -F"[_-]" '{print $4}')
    DirFILECOUNT=$(find ${DIRECTORY} -type f | wc -l)
   # echo "Checking: ${DIRECTORY}, DISK ##${DISK}" && echo
    echo "DIRECTORY is ${DIRECTORY}"
    echo "DISKNUM is ${DISK}"
    echo "FileCount = ${DirFILECOUNT}"
    mkdir -p ${PARENTDIR}/${COLL}_${DISK}-Excluded
    mkdir -p ${PARENTDIR}/${COLL}_${DISK}-Migrated
    echo "PARENTDIR is ${PARENTDIR}"
    echo "will make directory ${PARENTDIR}/${COLL}_${DISK}-Excluded"
    echo "will make directory ${PARENTDIR}/${COLL}_${DISK}-Migrated"

    # search for files within the Extracted directory, for each file TESTFILE, do...
    find ${DIRECTORY} -type f -print0 | while read -d $'\0' TESTFILE; do
        # move 0B files to ${PARENTDIR}/${COLL}_${DISK}-Excluded directory    
        if [ ! -s "${TESTFILE}" ]; then
            echo "${TESTFILE} is 0B, moving to ${PARENTDIR}/${COLL}_${DISK}-Excluded"
            mv "${TESTFILE}" ${PARENTDIR}/${COLL}_${DISK}-Excluded/
        fi
        # a whole lot of mess to deal with the special characters in these filenames:

        OrigDIRNAME=$(dirname "${TESTFILE}")
        MigDIRNAME=$(echo "${OrigDIRNAME}" | sed 's/Extracted/Migrated/')
        TEMPBASE=$(basename "${TESTFILE}")
        FILE="${OrigDIRNAME}"/"${TEMPBASE}"
        NEWFILE="${MigDIRNAME}"/"${TEMPBASE}".pdf
        echo "New file will be ${NEWFILE}"
        # get stripped filename as soffice would
        TEMPNAME="${TEMPBASE%.*}"
        echo "TEMPNAME is ${TEMPNAME}"
       
       # check $FILE exists
        if [ ! -f "${FILE}" ]; then
            echo "${FILE} does NOT EXIST"
        fi
        
        soffice --headless --convert-to pdf:writer_pdf_Export --outdir "${MigDIRNAME}" "${TESTFILE}"
       
        # move soffice created .pdf filename to desired filename location, originalfilename+pdf extension
        mv -n "${MigDIRNAME}"/"${TEMPNAME}".pdf "${NEWFILE}"
    done
echo
done 
rm tmp.*
find . -name "*-Migrated" -type d -exec chmod -R 755 {} \;

