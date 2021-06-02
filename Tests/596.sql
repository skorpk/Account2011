USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='124530' AND ReportYear=2019 AND NumberRegister=155

SELECT * from vw_getIdFileNumber WHERE id=@idFile

declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6),
		@typeFile char(1)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO, @typeFile=UPPER(f.TypeFile)
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))



;WITH cteMU
AS(
select  c.id,COUNT(DISTINCT m.GUID_MU) AS TotalMU,l.AccountParam,l.AccountTypeId,c.rf_idV009
from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
						AND c.IsCompletedCase=0
						AND c.DateEnd>=@dateStart 
								inner join dbo.t_Meduslugi m on
						c.id=m.rf_idCase  						
								INNER JOIN dbo.vw_sprMuWithParamAccount l ON
						m.MUCode=l.MU
WHERE m.Price>0 and l.AccountParam IS NOT NULL	
GROUP BY  c.id, l.AccountParam,l.AccountTypeId,c.rf_idV009	
),
cteMU1 AS
(
SELECT TOP 1 WITH TIES TotalMU,id,AccountParam,AccountTypeId,rf_idV009 FROM cteMU ORDER BY ROW_NUMBER() OVER(PARTITION BY id ORDER BY TotalMU desc) 
)
SELECT id,596  
FROM cteMU1 l 
WHERE NOT EXISTS (SELECT 1 FROM OMS_NSI.dbo.sprRefAccountLetterV009 v WHERE v.AccountTypeId=l.AccountTypeId  AND v.rf_idV009=l.rf_idV009 )


select DISTINCT c.id,596,m.MES,l.AccountParam,c.rf_idV009
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

