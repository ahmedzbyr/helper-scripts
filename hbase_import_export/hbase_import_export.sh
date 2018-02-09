#!/bin/bash

#
# Text Formating
#

BOLD="\033[1m";
NORM="\033[0m";

BLACK_F="\033[30m"; BLACK_B="\033[40m"
RED_F="\033[31m"; RED_B="\033[41m"
GREEN_F="\033[32m"; GREEN_B="\033[42m"
YELLOW_F="\033[33m"; YELLOW_B="\033[43m"
BLUE_F="\033[34m"; BLUE_B="\033[44m"
MAGENTA_F="\033[35m"; MAGENTA_B="\033[45m"
CYAN_F="\033[36m"; CYAN_B="\033[46m"
WHITE_F="\033[37m"; WHITE_B="\033[47m"

CURRENTTIME="$(date +'%Y%m%d%H%M')"
DATE="$(date +'%Y%m%d')"
# This should come from commandline
TABLE_NAME=$1

EXPORT_CMD="sudo hbase org.apache.hadoop.hbase.mapreduce.Export"
IMPORT_CMD="sudo hbase org.apache.hadoop.hbase.mapreduce.Import"

exportHbaseTables()
{

    echo -e "${BOLD}${RED_F}Backing up Hbase Tables .... ${NORM}"

    $EXPORT_CMD "$1" $2/"$1"_$3 $4 $5 $6

    echo -e "${BOLD}${RED_F}Backup Complete ... ${NORM}"
    echo -e "${YELLOW_F}"
    hadoop fs -ls $2/"$1"*$3*
    echo -e "${NORM}"
    echo -e "${BOLD}${RED_F}Backup Location on HDFS : hadoop fs -ls $2/ ${NORM}"

    echo -e "Files can be found in Location : $2/"$1"*$3* " | `mailx -v -A gmail -s "HBASE backup Completed : Did a $backupType Backup " 'zubair.ahmed@me.com'`
}

importHbaseTables()
{

    echo -e "${BOLD}${RED_F}Importing Hbase Tables .... ${NORM}"

    $IMPORT_CMD "$1" $2/"$1"_$3

    echo -e "${BOLD}${RED_F}Import Complete ... ${NORM}"
    echo -e "Files which were imported are in Location : $2/"$1"*$3* " | `mailx -v -A gmail -s "HBASE Import Completed : Did a $backupType Import " 'zubair.ahmed@me.com'`
}

# Do we want to Import or Export
# IMPORT
# EXPORT
importExport=$2

# COMPLETE_BACKUP
# INCREMENTAL_BACKUP
# COMPLETE_BACKUP_ALL_VERSIONS
backupType=$3

if [ -z $backupType ];
then
    echo -e "${BOLD}${YELLOW_F}For Complete backup Use the below command ${NORM}"
    echo -e "${BOLD}${RED_F}    usage: sh <filename.sh> TBL_NAME EXPORT COMPLETE_BACKUP ${NORM}\n"
    echo -e "${BOLD}${YELLOW_F}For Incremental backup Use below command - will take last 3days backup ${NORM}"
    echo -e "${BOLD}${RED_F}    usage: sh <filename.sh> TBL_NAME EXPORT INCREMENTAL_BACKUP ${NORM}\n"
    echo -e "${BOLD}${YELLOW_F}For Complete backup with ALL versions Use below command.${NORM}"
    echo -e "${BOLD}${RED_F}    usage: sh <filename.sh> TBL_NAME EXPORT COMPLETE_BACKUP_ALL_VERSIONS ${NORM}\n"
    exit
fi

if [ -z ${importExport} ];
then
    echo -e "${BOLD}${YELLOW_F}For Complete backup Use the below command ${NORM}"
    echo -e "${BOLD}${RED_F}    usage: sh <filename.sh> TBL_NAME EXPORT COMPLETE_BACKUP ${NORM}\n"
    echo -e "${BOLD}${YELLOW_F}For Incremental backup Use below command - will take last 3days backup ${NORM}"
    echo -e "${BOLD}${RED_F}    usage: sh <filename.sh> TBL_NAME EXPORT INCREMENTAL_BACKUP ${NORM}\n"
    echo -e "${BOLD}${YELLOW_F}For Complete backup with ALL versions Use below command.${NORM}"
    echo -e "${BOLD}${RED_F}    usage: sh <filename.sh> TBL_NAME EXPORT COMPLETE_BACKUP_ALL_VERSIONS ${NORM}\n"
    exit
fi


if [ $backupType == "COMPLETE_BACKUP" ];
then
    # Setting parameter to null as this will take complete backup of latest version
    echo -e "${BOLD}${RED_F}HBASE BACKUP : Starting COMPLETE_BACKUP ${NORM}\n"
    backupStartTimestamp=""
    backupEndTimestamp=""
    versionNumber=""
elif [ $backupType == "INCREMENTAL_BACKUP" ];
then
    # Setting to take Incremental back up from past 3days till current time.
    echo -e "${BOLD}${RED_F}HBASE BACKUP : Starting INCREMENTAL_BACKUP ${NORM}\n"
    versionNumber="2147483647"
    backupStartTimestamp="$(date --date="$date -3 day" +%s)000"
    backupEndTimestamp="$(date +%s)000"
elif [ $backupType == "COMPLETE_BACKUP_ALL_VERSIONS" ];
then
    # Complete backup for all versions
    echo -e "${BOLD}${RED_F}HBASE BACKUP : Starting COMPLETE_BACKUP_ALL_VERSIONS ${NORM}\n"
    versionNumber="2147483647"
    backupStartTimestamp="-2147483648"
    backupEndTimestamp="$(date +%s)000"
else
    echo -e "${BOLD}${RED_F}Enter Correct Parameter ${NORM}"
    exit
fi



# Setting Basepath Based on type of Backup.
BASE_PATH="/data/zahmed/tables/backup"

if [ $importExport == "EXPORT" ];
then
    # Creating backup Base Path
    BACKUP_BASE_PATH="$BASE_PATH/$DATE/$backupType"

    # Export Function take 6 Parameters
        # 1. Table Name 
        # 2. Base Path to Backup
        # 3. Current time which is include in the creation of directory
        # 4. Version Number for hbase version which needs to be backedup
        # 5. backup startime - this is the timestamp in hbase when row was written in Hbase 
        # 6. backup endtime - this is timestamp in hbase when row was written in Hbase
    echo "Starting EXPORT - data will be stored in $BACKUP_BASE_PATH/"
    exportHbaseTables $TABLE_NAME $BACKUP_BASE_PATH $CURRENTTIME $versionNumber $backupStartTimestamp $backupEndTimestamp 

elif [ $importExport == "IMPORT" ];
then
    # Get Date to Import from
    IMPORT_DATE=$4

    # Get Directory Prefix from import path yyyymmddHHMM
    DIRECTORY_TIMESTAMP=$5

    # While we are at it lets get the Hbase table prefix as well "PRD_LIVE_"
    TBL_PREFIX=$6

    # Check if we have what we need. 
    if [ -z $IMPORT_DATE ];
    then
        echo -e "${BOLD}${YELLOW_F}For Import Use the below command ${NORM}"
        echo -e "${BOLD}${RED_F}usage: sh <filename.sh> TBL_NAME IMPORT [ COMPLETE_BACKUP | INCREMENTAL_BACKUP | COMPLETE_BACKUP_ALL_VERSIONS ] <IMPORT_DATE(yyyymmdd)> <DIRECTORY_TIMESTAMP(yyyymmddHHMM)> <HBASE_TABLE_PREFIX(PRD_LIVE_)> ${NORM}"
        
        # If something is missing then Exit
        exit
    fi

    if [ -z $TBL_PREFIX ];
    then
        echo -e "${BOLD}${YELLOW_F}For Import Use the below command ${NORM}"
        echo -e "${BOLD}${RED_F}usage: sh <filename.sh> TBL_NAME IMPORT [ COMPLETE_BACKUP | INCREMENTAL_BACKUP | COMPLETE_BACKUP_ALL_VERSIONS ] <IMPORT_DATE(yyyymmdd)> <DIRECTORY_TIMESTAMP(yyyymmddHHMM)> <HBASE_TABLE_PREFIX(PRD_LIVE_)> ${NORM}"
        
        # If something is missing then Exit
        exit
    fi

    if [ -z $DIRECTORY_TIMESTAMP ];
    then
        echo -e "${BOLD}${YELLOW_F}For Import Use the below command ${NORM}"
        echo -e "${BOLD}${RED_F}usage: sh <filename.sh> TBL_NAME IMPORT [ COMPLETE_BACKUP | INCREMENTAL_BACKUP | COMPLETE_BACKUP_ALL_VERSIONS ] <IMPORT_DATE(yyyymmdd)> <DIRECTORY_TIMESTAMP(yyyymmddHHMM)> <HBASE_TABLE_PREFIX(PRD_LIVE_)> ${NORM}"
        
        # If something is missing then Exit
        exit
    fi


    # Creating basepath for import
    BACKUP_BASE_PATH="$BASE_PATH/$IMPORT_DATE/$backupType"

    # Import Functiontakes 3 Parameters
        # 1. Table prefix
        # 2. Base path to backedup data
        # 3. Directory prefix this is timestamp given when the hbase was backed up. format as 'yyyymmddHHMM'
    #importHbaseTables $TABLE_NAME $BACKUP_BASE_PATH $DIRECTORY_TIMESTAMP
else
    echo -e "${BOLD}${RED_F}Enter Correct Parameter ${NORM}"
    exit
fi
