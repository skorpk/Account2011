USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test596]    Script Date: 26.01.2017 13:32:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test596]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--Изменения формата. Проверка не работает для файлов типа HR c 22.01.2017

declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	
INSERT #tError
select DISTINCT c.id,596
from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase							
						AND c.DateEnd>=@dateStart 
								inner join dbo.t_Meduslugi m on
						c.id=m.rf_idCase  						
								INNER JOIN dbo.vw_sprMuWithParamAccount l ON
						m.MUCode=l.MU
						AND m.Price>0
						AND l.AccountParam IS NOT NULL
							INNER JOIN OMS_NSI.dbo.sprRefAccountLetterV009 v009 ON
						l.AccounttypeId=v009.AccountTypeId
WHERE c.rf_idV009 NOT in (SELECT rf_idV009 FROM OMS_NSI.dbo.sprRefAccountLetterV009 v WHERE v.AccountTypeId=l.AccountTypeId )
UNION 
select DISTINCT c.id,596
from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase							
						AND c.DateEnd>=@dateStart 
								inner join dbo.t_MES m on
						c.id=m.rf_idCase  						
								INNER JOIN (SELECT MU,AccountParam,AccountTypeId from dbo.vw_sprMuWithParamAccount 
											UNION ALL 
											SELECT MU,AccountParam,AccountTypeId from dbo.vw_sprCSGWithParamAccount) l ON
						m.MES=l.MU
								INNER JOIN OMS_NSI.dbo.sprRefAccountLetterV009 v009 ON
						l.AccounttypeId=v009.AccountTypeId
WHERE c.rf_idV009 NOT in (SELECT rf_idV009 FROM OMS_NSI.dbo.sprRefAccountLetterV009 v WHERE v.AccountTypeId=l.AccountTypeId )
GO