#!/bin/bash

# change here the master list name
MAINLIST="main"
CONF=~/mailman-sync-except.ini

list_members -o /tmp/members $MAINLIST

MEMBERS=`cat /tmp/members`

rm /tmp/members

# ini file format :
# each line starts with the list name to sync
# the arguments are the emails to remove from the main list
cat $CONF | while read line ; do
    LIST=`echo $line | cut -d= -f1  | tr -d ' '`
    REMOVE=`echo $line | cut -d= -f2`
    FILTERED=""
    for orig in $MEMBERS ; do
        ADDMAIL=$orig
        for email in $REMOVE ; do
            FOUND=`echo $orig | grep $email | wc -l`
            if [ "$FOUND" -gt "0" ] ; then
                ADDMAIL=""
            fi
        done
        FILTERED=`echo $FILTERED $ADDMAIL`
    done
    touch /tmp/members_sync && rm /tmp/members_sync
    for email in $FILTERED ; do
        echo "$email" >> /tmp/members_sync
    done
    echo "$LIST :"

    sync_members --welcome-msg=no --goodbye-msg=no --digest=no --notifyadmin=yes --file /tmp/members_sync $LIST
    rm /tmp/members_sync
done
