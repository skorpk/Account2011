SELECT bm.physical_device_name
FROM msdb.dbo.backupset bus inner join msdb.dbo.backupmediafamily bm on
		bus.media_set_id=bm.media_set_id
where bus.database_name='AccountOMS' 
		and bus.backup_set_id=(select MAX(backup_set_id) from msdb.dbo.backupset where database_name='AccountOMS')

