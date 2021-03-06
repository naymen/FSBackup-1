#!/bin/sh
# ������ ����� ������� �� �������� ����

# ������������� �������� ��������� ���� ������.
ulimit -v 200000

# ��������� ������������� ������ ���� rsync ���������.
IDLE=`ps -auxwww | grep -E "root.*rsync" | grep -vE "grep|rsync_backup"`
if [ "$IDLE" != "" ];  then
    echo "FATAL DUP"| mail -s "FATAL RSYNC BACKUP DUP" admins@testhost.ru
exit
fi

date
#/sbin/mount -u -w /backup
#/bin/mount -o remount,rw /backup

#��������� ������ ���� ���������� � �� ����������
/usr/local/fsbackup/scripts/create_dir_list.pl / > /usr/local/fsbackup/sys_backup/dir_list.txt

#/usr/local/bin/rsync -a -v --delete --delete-excluded --backup --exclude-from=/etc/rsync_backup.exclude / /backup
/usr/local/bin/rsync -a -v --delete --backup --exclude-from=/etc/rsync_backup.exclude / /backup

RETCODE=$?
if [ $RETCODE -ne 0 -a $RETCODE -ne 24 ]; then
        echo "Err code=$RETCODE"| mail -s "FATAL RSYNC BACKUP" admins@testhost.ru
fi
echo RET: $RETCODE

# �������������� ����� �������� ������ (��� �������������� ������ �����)
/usr/local/bin/rsync -a -v --delete /var/mail /backup/var/

/bin/chmod 0700 /backup
#/sbin/mount -u -r /backup
#/bin/mount -o remount,rw /backup

date

