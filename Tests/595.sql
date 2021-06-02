USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='391001' AND ReportYear=2018 AND NumberRegister=100010


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


--if EXISTS(SELECT * FROM dbo.t_File WHERE id=@idFile AND TypeFile='H')
--begin
--;WITH Case_CTE(id,AccountParam)
--AS
--(
--select DISTINCT c.id,l.AccountParam
--from t_RegistersCase a inner join t_RecordCase r on
--						a.id=r.rf_idRegistersCase
--						and a.rf_idFiles=@idFile
--								inner join t_Case c on
--						r.id=c.rf_idRecordCase	
--						AND c.IsCompletedCase=0
--						AND c.DateEnd>=@dateStart 
--								inner join dbo.t_Meduslugi m on
--						c.id=m.rf_idCase  						
--								INNER JOIN dbo.vw_sprMuWithParamAccount l ON
--						m.MUCode=l.MU
--WHERE m.Price>0 and l.AccountParam IS NOT NULL			
--)
--SELECT c1.id,595
--FROM Case_CTE c1 INNER JOIN Case_CTE c2 ON
--		c1.id=c2.id
--		AND c1.AccountParam<>c2.AccountParam
--END
;WITH cteMU
AS(
select  c.id,COUNT(DISTINCT m.GUID_MU) AS TotalMU,l.AccountParam
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
GROUP BY  c.id, l.AccountParam	
),
cteMU1 AS
(
SELECT TOP 1 WITH TIES TotalMU,id FROM cteMU ORDER BY ROW_NUMBER() OVER(PARTITION BY id ORDER BY TotalMU desc) 
)
,cteEnd AS (
SELECT rf_idCase,COUNT(distinct GUID_MU) AS total, TotalMU
FROM dbo.t_Meduslugi m INNER JOIN  cteMU1 c ON
		m.rf_idCase=c.id
WHERE Price>0  
GROUP BY rf_idCase, TotalMU
)
SELECT rf_idCase,595 FROM cteEnd WHERE total<>TotalMU

