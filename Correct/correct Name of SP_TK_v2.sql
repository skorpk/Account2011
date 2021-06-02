use RegisterCases
go
--alter table t_FileBack add MM as cast(substring([FileNameHRBack],16,2) as tinyint)
--go
--alter table t_FileBack add PackID as cast(substring([FileNameHRBack],18,2) as tinyint)
--go
declare @codeLPU char(6)='175603'
update t_FileBack
set FileNameHRBack=t.NeFileName
from t_FileBack fb inner join (
								select top 300 f.id,f.FileNameHRBack
										,substring([FileNameHRBack],0,16)+right('0'+CAST(MM as varchar(2)),2)+right('0'+cast(NTILE(99) OVER(PARTITION BY MM ORDER BY DateCreate) as varchar(2)),2) as NeFileName
										--,NTILE(99) OVER(PARTITION BY MM ORDER BY DateCreate)
								from t_FileBack f 		
								where CodeM=@codeLPU
								order by MM,PackID 
								) t on 
						fb.id=t.id
						
select FileNameHRBack
from t_FileBack f where CodeM=@codeLPU
group by FileNameHRBack
having COUNT(*)>1
