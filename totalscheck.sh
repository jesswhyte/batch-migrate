#!/bin/bash
for disknum in $(seq -f "%03g" 1 53); do 
    ListTotal=$(grep "^$disknum" ListSelMigrate.csv | wc -l); 
    if [ -d "Selvadurai_40_${disknum}/Migrated" ]; then
    MigratedTotal=$(find Selvadurai_40_${disknum}/Migrated/ -type f | wc -l); 
    else
        MigratedTotal=0
    fi
    if [ $ListTotal -ne $MigratedTotal ]; then
        echo "--------------------"
        echo "DISK: $disknum"; 
        echo "Total in Wanted List: ${ListTotal}"; 
        echo "Total Migrated Files: $MigratedTotal" ; 
        #echo "Difference of $((${ListTotal} - ${MigratedTotal}))"
        echo
        echo "Files from ListSelMigrate.csv:"
        grep "^$disknum" ListSelMigrate.csv
        echo
        echo "Files from Selvadurai_40_${disknum}/Migrated/:"
        find Selvadurai_40_${disknum}/Migrated/ -type f | sort
        echo
    fi
done

for disknum in $(seq -f "%03g" 54 116); do 
    ListTotal=$(grep "^$disknum" ListSelMigrate.csv | wc -l); 
    if [ -d "Selvadurai_41_${disknum}/Migrated" ]; then
    MigratedTotal=$(find Selvadurai_41_${disknum}/Migrated/ -type f | wc -l); 
    else
        MigratedTotal=0
    fi
    if [ $ListTotal -ne $MigratedTotal ]; then
        echo "--------------------"
        echo "DISK: $disknum"; 
        echo "Total in Wanted List: ${ListTotal}"; 
        echo "Total Migrated Files: $MigratedTotal" ; 
        #echo "Difference of $((${ListTotal} - ${MigratedTotal}))"
        echo
        echo "Files from ListSelMigrate.csv:"
        grep "^$disknum" ListSelMigrate.csv
        echo
        echo "Files from Selvadurai_41_${disknum}/Migrated/:"
        find Selvadurai_41_${disknum}/Migrated/ -type f | sort
        echo
    fi
done