use RegisterCases
go
select
		ISNULL(FG.name, (SELECT name FROM sys.data_spaces WHERE data_space_id = a3.data_space_id)) AS [File Group]
,		a5.name as [Schema]
,       a2.name as [Table]
,       a3.name as [Index]
,		a3.type as [TypeId]
,       a3.type_desc as [Type]
,       a1.partition_number as [Partition Number]
,		cast((a1.in_row_reserved_page_count + a1.row_overflow_reserved_page_count) * 8.0 / 1024 as decimal(15,3)) as [Reserved, Mb]
,		cast((a1.in_row_used_page_count + a1.row_overflow_used_page_count) * 8.0 / 1024 as decimal(15,3)) as [Used, Mb]
,       a1.row_count AS [Row Count]
from sys.dm_db_partition_stats a1
inner join sys.all_objects a2  on ( a1.object_id = a2.object_id )
inner join sys.schemas a5 on (a5.schema_id = a2.schema_id)
left outer join  sys.indexes a3  on ( (a1.object_id = a3.object_id) and (a1.index_id = a3.index_id) )
OUTER APPLY (SELECT DS.name FROM sys.destination_data_spaces AS DD INNER JOIN
                      sys.data_spaces AS DS ON DD.data_space_id = DS.data_space_id 
                      WHERE DD.partition_scheme_id = a3.data_space_id AND DD.destination_id = a1.partition_number) AS FG
OUTER APPLY (SELECT T.lob_data_space_id FROM sys.tables AS T WHERE T.object_id = a1.object_id
AND a3.type IN (0, 1) AND ISNULL(lob_data_space_id, 0) > 0) AS LD
where a2.type NOT IN (N'S', N'IT')
AND a2.is_ms_shipped = 0
UNION ALL
select
		COALESCE(FG.name, (SELECT name FROM sys.data_spaces WHERE data_space_id = LD.lob_data_space_id),
			(SELECT name FROM sys.data_spaces WHERE data_space_id = a3.data_space_id)) AS [File Group]		
,		a5.name as [Schema]
,       a2.name as [Table]
,       a3.name as [Index]
,		a3.type as [TypeId]
,       'BLOB' as [Type]
,       a1.partition_number as [Partition Number]
,		cast(a1.lob_reserved_page_count * 8.0 / 1024 as decimal(15,3)) as [Reserved, Mb]
,		cast(a1.lob_used_page_count * 8.0 / 1024 as decimal(15,3)) as [Used, Mb]
,       a1.row_count AS [Row Count]
from sys.dm_db_partition_stats a1
inner join sys.all_objects a2  on ( a1.object_id = a2.object_id )
inner join sys.schemas a5 on (a5.schema_id = a2.schema_id)
left outer join  sys.indexes a3  on ( (a1.object_id = a3.object_id) and (a1.index_id = a3.index_id) )
OUTER APPLY (SELECT DS.name FROM sys.destination_data_spaces AS DD INNER JOIN
                      sys.data_spaces AS DS ON DD.data_space_id = DS.data_space_id 
                      WHERE DD.partition_scheme_id = a3.data_space_id AND DD.destination_id = a1.partition_number) AS FG
OUTER APPLY (SELECT T.lob_data_space_id FROM sys.tables AS T WHERE T.object_id = a1.object_id
AND a3.type IN (0, 1, 2) AND ISNULL(lob_data_space_id, 0) > 0) AS LD
where a2.type NOT IN (N'S', N'IT')
AND a2.is_ms_shipped = 0
AND a1.lob_reserved_page_count > 0
ORDER BY 1, 2, 3, 4, 5, 6