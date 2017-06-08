#!/bin/sh
# perform daily updates on the following folders
# 1st argument of daily_snapshot is the backup source within /backup_sources/
/bin/sh /root/daily_snapshot.sh Mudskipper/home/uncle_fungus
/bin/sh /root/daily_snapshot.sh Gecko/home/uncle_fungus
/bin/sh /root/daily_snapshot.sh Salamander/C$
/bin/sh /root/daily_snapshot.sh Salamander/D$
/bin/sh /root/daily_snapshot.sh Chameleon/home/cloak
#etc. etc. etc.
