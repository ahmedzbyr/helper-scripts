#!/bin/sh
SVN_REPOSITORIES_ROOT_DIR="/home/ahmed/SVNREPOS_TEST/multiple_repos" 
BACKUP_DIRECTORY="/home/ahmed/SVNREPOS_TEST/test_backup_full"
DATE=`date '+%d'-'%m'-'%Y'-'%H':'%M':'%S' `

for REPOSITORY in `ls -1 $SVN_REPOSITORIES_ROOT_DIR` 
do 
	#echo 'dumping repository: ' $REPOSITORY
	svnadmin dump $SVN_REPOSITORIES_ROOT_DIR/$REPOSITORY | gzip > $BACKUP_DIRECTORY/full-backup-$REPOSITORY-$DATE'.gz'
done
echo 'dumping repository: Successfull -' $DATE > /tmp/full-backup-$DATE.log
