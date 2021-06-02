use RegisterCases
go
--select *
--from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration i on
--			r.id=i.rf_idRefCaseIteration
--			and r.rf_idCase=8326005

declare @t as table(rf_idRefCaseIteration bigint,rf_idIteration tinyint)
--вставляю данные с максимальным номером итерации	
insert @t
select i.rf_idRefCaseIteration,MAX(rf_idIteration)
from t_CasePatientDefineIteration i inner join (		
												select rf_idRefCaseIteration
												from t_CasePatientDefineIteration
												group by rf_idRefCaseIteration
												having COUNT(*)>1
											   ) i2 on
							i.rf_idRefCaseIteration=i2.rf_idRefCaseIteration
group by i.rf_idRefCaseIteration

--удаляю все дублирующие записи
delete from t_CasePatientDefineIteration where rf_idRefCaseIteration in (
																		 select rf_idRefCaseIteration from t_CasePatientDefineIteration
																		 group by rf_idRefCaseIteration having COUNT(*)>1
																		)
--вставляю	записи который были очищены от дубликатов
insert t_CasePatientDefineIteration select * from @t

create unique nonclustered index UQ_rf_idRefCaseIteration on dbo.t_CasePatientDefineIteration (rf_idRefCaseIteration) with IGNORE_DUP_KEY 
GO
/****** Object:  Index [IX_idRefCaseIteration]    Script Date: 07/24/2012 15:25:19 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[t_CasePatientDefineIteration]') AND name = N'IX_idRefCaseIteration')
DROP INDEX [IX_idRefCaseIteration] ON [dbo].[t_CasePatientDefineIteration] WITH ( ONLINE = OFF )
GO

