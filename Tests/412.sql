USE [RegisterCases]
GO
DECLARE @idfile INT

declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6),
		@typeFile char(1)

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='251001' AND ReportYear=2019 AND NumberRegister=176
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO, @typeFile=UPPER(f.TypeFile)
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

--CREATE TABLE #tMU(MU VARCHAR(20))
--INSERT #tMU( MU )
--SELECT DISTINCT MU FROM dbo.vw_sprMU mm WHERE mm.IsNextVisit=1
--CREATE UNIQUE NONCLUSTERED INDEX IX_TMPMU ON #tMU(MU)



SELECT DISTINCT c.id,412
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180401'			  
			  INNER JOIN t_PurposeOfVisit p ON
		c.id=p.rf_idCase          
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND p.rf_idV025='1.3' AND p.DN IN(1,2) AND NOT EXISTS(SELECT 1 FROM dbo.t_NextVisitDate WHERE rf_idCase=c.id)

DECLARE @period INT
SET @period=CAST(CAST(@year AS CHAR(4)) + RIGHT('0'+CAST(@month AS VARCHAR(2)),2) AS INT)

SELECT DISTINCT c.id,412,d.DateVizit,d.Period,@period
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180401'		
			INNER JOIN dbo.t_NextVisitDate d ON
		c.id=d.rf_idCase          
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.DateVizit IS NOT null AND @period>d.Period 


