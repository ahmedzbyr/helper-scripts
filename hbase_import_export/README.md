HBASE IMPORT EXPORT SCRIPT
===============================

******* TESTING_PENDING ********

EXPORT
--------------------------------------------
    For Complete backup Use the below command
     usage: sh <filename.sh> TBL_NAME EXPORT COMPLETE_BACKUP
    For Incremental backup Use below command - will take last 3days backup
     usage: sh <filename.sh> TBL_NAME EXPORT INCREMENTAL_BACKUP
    For Complete backup with ALL versions Use below command.
     usage: sh <filename.sh> TBL_NAME EXPORT COMPLETE_BACKUP_ALL_VERSIONS


IMPORT
--------------------------------------------
    usage: sh <filename.sh>
                <TBL_NAME>
                [ IMPORT ]
                [ COMPLETE_BACKUP | INCREMENTAL_BACKUP | COMPLETE_BACKUP_ALL_VERSIONS ]
                <IMPORT_DATE(yyyymmdd)>
                <DIRECTORY_TIMESTAMP(yyyymmddHHMM)>
                <HBASE_TABLE_PREFIX(PRD_LIVE_)>
    
    NOTE :
    For 'mailx' to work it needs to be configured.