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

# find Extracted Files' Directories and output to temp.ExtractedList
find . -name "*Extracted" -type d | sort > tmp.ExtractedList

# check files within against wanted list
for DIRECTORY in $(cat tmp.ExtractedList); do
    echo && echo "-----------------------"
    echo "Checking: ${DIRECTORY}" && echo
    PARENTDIR=$(echo "${DIRECTORY}" | awk -F"/" '{print $2}')
    # search for files within the Extracted directory, for each file TESTFILE, do...
    find ${DIRECTORY} -type f -print0 | while read -d $'\0' TESTFILE; do
        # get md5sum
        TESTMD5=$(md5sum "${TESTFILE}" | awk '{ print $1 }')
        # search the "wanted" csv for the file's checksum, if found and if type includes Word or WordPerfect do...
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
                #soffice locations for Mac is typically /Applications/LibreOffice.app/Contents/MacOS/
                soffice --headless --convert-to pdf:writer_pdf_Export --outdir ${PARENTDIR}/Migrated/ "${TESTFILE}"
                # because soffice headless cuts off the filename extension and adds .pdf as the new extension, this creates
                # issues when users used unique or custome filename extensions or had the same filename but different extensions
                # below moves the file created by soffice to its original filename + .pdf
                # get basename of file currently working on
                TEMPBASE=$(basename ${TESTFILE})
                # get stripped filename as soffice would
                TEMPNAME=$(echo ${TEMPBASE%.*})
                # move soffice created .pdf filename to desired filename location, originalfilename+pdf extension
                mv ${PARENTDIR}/Migrated/${TEMPNAME}.pdf ${PARENTDIR}/Migrated/${TESTFILE}.pdf 
            else
                cp "${TESTFILE}" ${PARENTDIR}/Migrated/    
            fi
            chmod -R 755 ${PARENTDIR}/Migrated
        fi
    done
done 
rm tmp.*

# while IFS="," read -r DISK NAME SIZE MTIME MD5 TYPE; do 
