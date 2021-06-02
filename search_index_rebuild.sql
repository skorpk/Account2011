SELECT  OBJECT_NAME(s.[object_id]) AS [ObjectName] ,
        i.name AS [IndexName] ,
        i.index_id ,
        s.avg_fragmentation_in_percent,
        'alter index '+QUOTENAME(i.name)+' on dbo.'+QUOTENAME(OBJECT_NAME(s.[object_id]))+' rebuild'        
FROM    sys.dm_db_index_physical_stats(DB_ID(),null,null,null,null) AS s
        INNER JOIN sys.indexes AS i ON 
			s.[object_id] = i.[object_id]
			and s.index_id=i.index_id
WHERE   --i.object_id=object_id('dbo.t_RecordCaseBack')        
        s.database_id = DB_ID() and i.name is not null and s.avg_fragmentation_in_percent>30
ORDER BY avg_fragmentation_in_percent desc,i.object_id asc
