#!/bin/bash
#-------------------------------------------------------------------------------
# Andrew Schofield 2007
# weekly snapshot rotator - weekly_snapshot.sh
# rotates weekly snapshots for 4 weeks and creates new from 6 day old snapshot
# modified from http://www.mikerubel.org/computers/rsync_snapshots/
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
#EXCLUDES=/path/to/exclude/list;

export BLOCATION=$1;

# make sure we're running as root
if (( `$ID -u` != 0 )); then { $ECHO "Sorry, must be root.  Exiting..."; exit; } fi

# attempt to remount the RW mount point as RW; else abort
$MOUNT -o remount,rw $MOUNT_DEVICE $SNAPSHOT_RW ;
if (( $? )); then
{
	$ECHO "snapshot: could not remount $SNAPSHOT_RW readwrite";
	exit;
}
fi;

# delete oldest backup if it exists
if [ -d $SNAPSHOT_RW/$BLOCATION/4_weeks_ago ] ; then
$RM -rf $SNAPSHOT_RW/$BLOCATION/4_weeks_ago;
fi;

# shuffle intermediate backups
if [ -d $SNAPSHOT_RW/$BLOCATION/3_weeks_ago ] ; then
$MV $SNAPSHOT_RW/$BLOCATION/3_weeks_ago $SNAPSHOT_RW/$BLOCATION/4_weeks_ago;
fi;
if [ -d $SNAPSHOT_RW/$BLOCATION/2_weeks_ago ] ; then
$MV $SNAPSHOT_RW/$BLOCATION/2_weeks_ago $SNAPSHOT_RW/$BLOCATION/3_weeks_ago;
fi;
if [ -d $SNAPSHOT_RW/$BLOCATION/_last_week ] ; then
$MV $SNAPSHOT_RW/$BLOCATION/_last_week $SNAPSHOT_RW/$BLOCATION/2_weeks_ago;
fi;

# make a hard-link copy of backup from 6 days ago into _last_week if it exists
if [ -d $SNAPSHOT_RW/$BLOCATION/6_days_ago ]; then
$CP -al $SNAPSHOT_RW/$BLOCATION/6_days_ago $SNAPSHOT_RW/$BLOCATION/_last_week;
fi;

# remount RO
$MOUNT -o remount,ro $MOUNT_DEVICE $SNAPSHOT_RW ;
if (( $? )); then
{
	$ECHO "snapshot: could not remount $SNAPSHOT_RW readonly";
	exit;
} fi;
