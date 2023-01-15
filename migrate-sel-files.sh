#!/bin/bash


function show_help() {
  echo
  echo -e "USAGE: bash migrate3.sh -c CSV\n"
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
#soffice="/Applications/LibreOffice.app/Contents/MacOS/soffice"

<<<<<<< HEAD
# find Extracted Files' Directories and output to temp.ExtractedList
=======
# find Migrated Files' Directories
>>>>>>> move unwanted files to Excluded list, remove duplicates
find . -name "*Extracted" -type d | sort > tmp.ExtractedList


for DIRECTORY in $(cat tmp.ExtractedList); do 
# check files within against wanted list
    #echo && echo "---------------------------"
    PARENTDIR=$(echo "${DIRECTORY}" | awk -F"/" '{print $2}')
<<<<<<< HEAD
    # search for files within the Extracted directory, for each file TESTFILE, do...
=======
    DISK=$(echo "${PARENTDIR}" | awk -F"_" '{print $3}')
   # echo "Checking: ${DIRECTORY}, DISK ##${DISK}" && echo
>>>>>>> move unwanted files to Excluded list, remove duplicates
    find ${DIRECTORY} -type f -print0 | while read -d $'\0' TESTFILE; do
        # get md5sum
        TESTMD5=$(md5sum "${TESTFILE}" | awk '{ print $1 }')
        # search the "wanted" csv for the file's checksum, if found and if type includes Word or WordPerfect do...
        if grep -q "${TESTMD5}" "${CSV}"; then
            #echo "${TESTFILE} checksum found in WANTED CSV, checking now..."
            INFO=$(grep "${TESTMD5}" ${CSV} )
            INFO=${INFO//$'\n'/}
            DISKCSV=$(echo "${INFO}" | awk -F, '{ print $1 }' )
            NAME=$(echo "${INFO}" | awk -F, '{ print $2 }' )
            MD5=$(echo "${INFO}" | awk -F, '{ print $5 }' )
            TYPE=$(echo "${INFO}" | awk -F, '{ print $6 }' )
            if [ "${DISK}" != "${DISKCSV}" ]; then
	            # echo "DISK NUMBERS for ${TESTFILE} DO NOT MATCH. CSVDIR is ${DISKCSV}. DIRDISK is ${DISK}"
                mkdir -p ${PARENTDIR}/${PARENTDIR}-ExcludedFiles
                rsync -a "${TESTFILE}" ${PARENTDIR}/${PARENTDIR}-ExcludedFiles/
            fi
            #remove newline characters
            
            if [[ "${TYPE}" =~ "Word" ]] || [[ "${TYPE}" =~ "WordPerfect" ]]; then
<<<<<<< HEAD
                #soffice locations for Mac is typically /Applications/LibreOffice.app/Contents/MacOS/
=======
>>>>>>> move unwanted files to Excluded list, remove duplicates
                soffice --headless --convert-to pdf:writer_pdf_Export --outdir ${PARENTDIR}/Migrated/ "${TESTFILE}"
                # because soffice headless cuts off the filename extension and adds .pdf as the new extension, this creates
                # issues when users used unique or custome filename extensions or had the same filename but different extensions
                # below moves the file created by soffice to its original filename + .pdf
<<<<<<< HEAD
                # get basename of file currently working on
                TEMPBASE=$(basename ${TESTFILE})
                # get stripped filename as soffice would
                TEMPNAME=$(echo ${TEMPBASE%.*})
                # move soffice created .pdf filename to desired filename location, originalfilename+pdf extension
                mv ${PARENTDIR}/Migrated/${TEMPNAME}.pdf ${PARENTDIR}/Migrated/${TESTFILE}.pdf 
=======
                BASETEMP=$(basename "${TESTFILE}")
		        TEMPNAME=$(echo "${BASETEMP%.*}")
                #echo "TESTFILE is ${TESTFILE}"
		        #echo "TEMPNAME is ${TEMPNAME}"
		        mv -n ${PARENTDIR}/Migrated/"${TEMPNAME}".pdf ${PARENTDIR}/Migrated/"${BASETEMP}".pdf 
>>>>>>> move unwanted files to Excluded list, remove duplicates
            else
                cp "${TESTFILE}" ${PARENTDIR}/Migrated/    
            fi
            chmod -R 755 ${PARENTDIR}/Migrated
        else
             echo "ERROR: checksum for ${TESTFILE} not found in wanted CSV list"
             mkdir -p ${PARENTDIR}/${PARENTDIR}-ExcludedFiles
             rsync -a "${TESTFILE}" ${PARENTDIR}/${PARENTDIR}-ExcludedFiles/
        #     echo "ERROR ERROR ERROR ERROR CHECKSUM NOT FOUND"
        #     echo "DELETE THIS FILE"
        #     echo && echo && echo
        fi
    done
done < ${CSV}
rm tmp.*

# while IFS="," read -r DISK NAME SIZE MTIME MD5 TYPE; do 
