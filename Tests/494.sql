USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT	

select @idFile=id from vw_getIdFileNumber where CodeM='103001' and NumberRegister=200 and ReportYear=2020

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

SELECT DiagnosisCode INTO #tDS1 FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C00' AND 'C97'

INSERT #tDS1( DiagnosisCode ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0[0-9]'
INSERT #tDS1( DiagnosisCode ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS ='C97'

--VID_VME

SELECT DISTINCT c.id,494
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								
		AND c.DateEnd>='20190101'							 				
				INNER JOIN t_mes m ON
        c.id=m.rf_idCase
				INNER JOIN	dbo.vw_Diagnosis d ON
         c.id=d.rf_idCase
				INNER JOIN #tDS1 dd ON
         d.DS1=dd.DiagnosisCode
				inner JOIN dbo.t_ONK_SL sl ON
        c.id=sl.rf_idCase	
				INNER JOIN dbo.t_ONK_USL u ON
        u.rf_idCase = c.id
		AND u.rf_idN013=5		
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.DS1_T<3 AND m.mes IN('st19.038','ds19.028')
		AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi WHERE rf_idCase=c.id AND MUSurgery='A11.12.001.002')
--DS1

SELECT DISTINCT c.id,494,d.DS1
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								
		AND c.DateEnd>='20190101'							 				
				INNER JOIN t_mes m ON
        c.id=m.rf_idCase
				INNER JOIN	dbo.vw_Diagnosis d ON
         c.id=d.rf_idCase		
				INNER JOIN dbo.t_ONK_SL sl ON
        c.id=sl.rf_idCase				
				INNER JOIN dbo.t_ONK_USL u ON
        u.rf_idCase = c.id
		AND u.rf_idN013=5
				INNER JOIN dbo.t_Meduslugi mm ON
        mm.rf_idCase = c.id
		AND mm.MUSurgery='A11.12.001.002'
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.DS1_T <3 AND m.mes IN('st19.038','ds19.028')
		AND NOT EXISTS(SELECT 1 FROM #tDS1 WHERE DiagnosisCode=d.DS1)
--USL_TIP

SELECT DISTINCT c.id,494
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								
		AND c.DateEnd>='20190101'							 				
				INNER JOIN t_mes m ON
        c.id=m.rf_idCase
				INNER JOIN	dbo.vw_Diagnosis d ON
         c.id=d.rf_idCase
				INNER JOIN #tDS1 dd ON
         d.DS1=dd.DiagnosisCode		
				INNER JOIN dbo.t_ONK_SL sl ON
        c.id=sl.rf_idCase							
				INNER JOIN dbo.t_Meduslugi mm ON
        mm.rf_idCase = c.id
		AND mm.MUSurgery='A11.12.001.002'
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.DS1_T <3 AND m.mes IN('st19.038','ds19.028')		
		AND NOT EXISTS(SELECT 1 FROM t_ONK_USL WHERE rf_idCase=c.id AND rf_idN013=5)

SELECT * FROM oms_nsi.dbo.sprN013 WHERE ID_TLech=5

--DS1_T

SELECT DISTINCT c.id,494
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								
		AND c.DateEnd>='20190101'							 				
				INNER JOIN t_mes m ON
        c.id=m.rf_idCase
				INNER JOIN	dbo.vw_Diagnosis d ON
         c.id=d.rf_idCase
				INNER JOIN #tDS1 dd ON
         d.DS1=dd.DiagnosisCode		
				INNER JOIN dbo.t_ONK_USL u ON
        u.rf_idCase = c.id
		AND u.rf_idN013=5						
				INNER JOIN dbo.t_Meduslugi mm ON
        mm.rf_idCase = c.id
		AND mm.MUSurgery='A11.12.001.002'
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND m.mes IN('st19.038','ds19.028')		
		AND NOT EXISTS(SELECT 1 FROM t_ONK_SL sl WHERE rf_idCase=c.id AND sl.DS1_T<3)
		
go


DROP TABLE #tDS1