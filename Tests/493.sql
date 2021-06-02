USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT	

select @idFile=id from vw_getIdFileNumber where CodeM='101001' and NumberRegister=290 and ReportYear=2020

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


SELECT DiagnosisCode INTO #tDS1 FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'

INSERT #tDS1( DiagnosisCode ) 
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0[0-9]'

SELECT DISTINCT c.id,493,c.GUID_Case,c.rf_idV006,sl.DS1_T
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'							 				
				INNER JOIN	dbo.vw_Diagnosis d ON
         c.id=d.rf_idCase
				INNER JOIN #tDS1 dd ON
         d.DS1=dd.DiagnosisCode
				left JOIN dbo.t_ONK_SL sl ON
        c.id=sl.rf_idCase				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.DS1_T IN (3,5,6) AND c.rf_idv006<3 AND c.rf_idV010<>32
		AND EXISTS(SELECT 1 FROM dbo.t_ONK_USL WHERE rf_idCase=c.id)
		
DROP TABLE #tDS1
