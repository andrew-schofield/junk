#!/bin/bash
#-------------------------------------------------------------------------------
# Andrew Schofield 2007
# Daily snapshot creator - daily_snapshot.sh
# Creates incremental snapshots via cp and rsync and rotates them daily
# modified from http://www.mikerubel.org/computers/rsync_snapshots/
# takes backup source within /backup_sources as 1st argument. i.e. make sure the
# source is mounted within the local filesystem...see fstab
#-------------------------------------------------------------------------------
# Changelog
# 2007/02/15 -	Added delete-after and delete-excluded which got removed
#		previously when I broke the script by not including
#		ignore-errors. This should mean that the excludes that are
#		currently still present after some initial breakages will get
#		removed on the next cycle.
#-------------------------------------------------------------------------------

unset PATH

#------------------ system commands used by script -----------------------------
ID=/usr/bin/id;
ECHO=/bin/echo;

MOUNT=/bin/mount;
RM=/bin/rm;
MV=/bin/mv;
CP=/bin/cp;
TOUCH=/bin/touch;
MKDIR=/bin/mkdir;

RSYNC=/usr/bin/rsync;

#-------- location of backup partition as device and as mount point ------------

MOUNT_DEVICE=/dev/sda7;
SNAPSHOT_RW=/root/backups;
export BLOCATION=$1;
EXCLUDES=/backup_sources/$BLOCATION/.rsync_excludes; #exclude list always held in "root" of source 


#------------------------------ start her up! ----------------------------------

# must be running as root or die
if (( `$ID -u` != 0 )); then { $ECHO "Sorry, must be root. Exiting..."; exit; } fi

# attempt to mount backup device as RW in /root (stays RO in /backups)
$MOUNT -o remount,rw $MOUNT_DEVICE $SNAPSHOT_RW;
if (( $? )); then
{
	$ECHO "snapshot: could not remount $SNAPSHOT_RW readwrite";
	exit;
}
fi;

# start rotating old snapshots

# 1st remove oldest snapshot if it exists:
if [ -d $SNAPSHOT_RW/$BLOCATION/6_days_ago ] ; then
$RM -rf $SNAPSHOT_RW/$BLOCATION/6_days_ago ;
fi ;

# shuffle all intermediate snapshots around:
if [ -d $SNAPSHOT_RW/$BLOCATION/5_days_ago ] ; then
$MV $SNAPSHOT_RW/$BLOCATION/5_days_ago $SNAPSHOT_RW/$BLOCATION/6_days_ago ;
fi ;

if [ -d $SNAPSHOT_RW/$BLOCATION/4_days_ago ] ; then
$MV $SNAPSHOT_RW/$BLOCATION/4_days_ago $SNAPSHOT_RW/$BLOCATION/5_days_ago ;
fi ;

if [ -d $SNAPSHOT_RW/$BLOCATION/3_days_ago ] ; then
$MV $SNAPSHOT_RW/$BLOCATION/3_days_ago $SNAPSHOT_RW/$BLOCATION/4_days_ago ;
fi ;

if [ -d $SNAPSHOT_RW/$BLOCATION/2_days_ago ] ; then
$MV $SNAPSHOT_RW/$BLOCATION/2_days_ago $SNAPSHOT_RW/$BLOCATION/3_days_ago ;
fi ;

# hard link the latest snapshot if it exists
if [ -d $SNAPSHOT_RW/$BLOCATION/Yesterday ] ; then
$CP -al $SNAPSHOT_RW/$BLOCATION/Yesterday $SNAPSHOT_RW/$BLOCATION/2_days_ago ;
else
$MKDIR -p $SNAPSHOT_RW/$BLOCATION/Yesterday;
fi ;

# rsync from the shared $BLOCATION into latest snapshot
$RSYNC -vv -a -x --delete --delete-after --delete-excluded --ignore-errors --numeric-ids /backup_sources/$BLOCATION/ $SNAPSHOT_RW/$BLOCATION/Yesterday ;

# update mtime of _Today to reflect current time
$TOUCH $SNAPSHOT_RW/$BLOCATION/Yesterday;

# all done

# remount back as RO

$MOUNT -o remount,ro $MOUNT_DEVICE $SNAPSHOT_RW;
if (( $? )); then
{
	$ECHO "snapshot: could not remount $SNAPSHOT_RW readonly";
	exit;
} fi;
