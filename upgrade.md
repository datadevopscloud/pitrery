---
layout: default
title: pitrery - Upgrade
---

Upgrade to 1.5
==============

Configuration
-------------

The following new configuration variables may be used, here are their
defaults:

* `PGXLOG` (empty). Path to put pg_xlog outside of PGDATA when
  restoring.
* `PRE_BACKUP_COMMAND` (empty) and `POST_BACKUP_COMMAND`. Command to
  run before and after the base backup.
* `STORAGE` (tar). Storage method, "tar" or "rsync".
* `COMPRESS_BIN`, `COMPRESS_SUFFIX` and `UNCOMPRESS_BIN`. Controls to
  tool used to compress archived WAL files.


Archiving
---------

Compression options are only available in the configuration file,
customizing this forces to use `-C` option of `archive_xlog`.


Upgrade to 1.4
==============

Archiving
---------

As of 1.4, the archive_xlog.conf files is no longer used to configure
archive_xlog. All parameter are now in pitr.conf.

To upgrade, you need to merge your configuration into a pitr.conf
file. The default one is available in DOCDIR
(/usr/local/share/doc/pitrery by default), comments should be enough
to help you reconfigure archive_xlog.

The archive_command should be updated to have archive_xlog search for
the configuration file, -C option accept the basename of the
configuration file name and searches in the configuration directory, a
full path is also accepted:

    archive_command = 'archive_xlog -C mypitr %p'



Upgrade to 1.3
==============

Archiving
---------

As of 1.3, pitrery no longer archive more than one file. Thus
archive_nodes.conf file has been removed. The archive_xlog script now
archives only one file.

If you are archiving more than one time, you have to chain archiving
in the archive_command parameter of postgresql.conf:

    archive_command = 'archive_xlog -C archive_xlog %p && rsync -az %p standby:/path/to/archives/%f'

Of course you can chain archive_xlog to archive multiple times.


Backup and restore
------------------

As of 1.3, the best backup is found by storing the stop time of the
backup as an offset from the Unix Epoch in the backup_timestamp file
inside each backup directory. The files can be created from the
backup_label files using this shell script:

    BACKUP_DIR=/path/to/backup/dir
    LABEL=pitr
    
    for x in ${BACKUP_DIR}/${LABEL}/[0-9]*/backup_label; do
        psql -At -c "select extract(epoch from timestamp with time zone '`awk '/^STOP TIME:/ { print $3" "$4" "$5 }' $x`');" > `dirname $x`/backup_timestamp
    done

