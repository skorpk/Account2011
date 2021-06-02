USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT	

select @idFile=id from vw_getIdFileNumber where CodeM='141023' and NumberRegister=429 and ReportYear=2019

select * from vw_getIdFileNumber where id=@idFile

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

DECLARE @idMax INT
select row_num from sa_rowgenerator( 1, 100 )
SELECT @idMax=MAX(cc.idRecordCase)
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase			  
			 INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase	 	  				     
where a.rf_idFiles=@idFile 

;WITH idRow(id) AS
(
 SELECT 1
 UNION ALL
 SELECT id+1 FROM idRow WHERE id < @idMax
)
SELECT * INTO #idRow FROM idRow
OPTION(MAXRECURSION 32000);


SELECT c.id, 539
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'	
			 INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase	 	  				     
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT * FROM #idRow WHERE id=cc.idRecordCase)
  --если повторяется значения в IDCASE
;WITH cteID
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY cc.idRecordCase ORDER BY cc.id) AS idRow, cc.id,cc.rf_idRecordCase
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase		
			 INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase	 	  				     
where a.rf_idFiles=@idFile 
)

SELECT c.id,539
FROM cteID cc INNER JOIN dbo.t_Case c ON
		cc.rf_idRecordCase = c.rf_idRecordCase
WHERE cc.idRow>1

GO
DROP TABLE #idRow