USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT	

select @idFile=id from vw_getIdFileNumber where CodeM='101001' and NumberRegister=224 and ReportYear=2019

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

SELECT DiagnosisCode INTO #tDS1 FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C[0-7][0-9]'
INSERT #tDS1( DiagnosisCode ) 
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0[0-9]'
UNION ALL
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS IN('C80','C97')

CREATE TABLE #tCSG(CSG VARCHAR(20),ReportYear SMALLINT)

INSERT #tCSG(CSG,ReportYear) 
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code LIKE 'st19.02[7-9]'
UNION ALL
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code LIKE 'st19.03[0-6]'
UNION ALL
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code LIKE 'ds19.01[8,9]'
UNION ALL
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code LIKE 'ds19.02[0-7]'

/*
ƒл€ случаев c:  (ReportYear =2019)  и (N_KSG like Тst19.0[27-36]Т or N_KSG like Сds19.0[18-27]Т) 
должно выполн€тьс€: Age>17 -- ѕ–ќ¬≈–я≈ћ данное условие
 and CRIT like Сsh%Т(других CRIT не должно быть)
 and (DS1 like СC[0-7][0-9]%Т or DS1 like СC97%Т or DS1 like СC80%Т or DS1 like СD0[0-9]%Т)
and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2
and ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2) 
*/

SELECT DISTINCT c.id,486
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'							 
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id
				INNER JOIN #tCSG cc ON
        m.MES=cc.CSG
		AND cc.ReportYear=@year
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS1 dd ON
		d.DS2=dd.DiagnosisCode  
				INNER JOIN dbo.t_AdditionalCriterion ad ON
		c.id=ad.rf_idCase            
				INNER JOIN dbo.t_ONK_USL u ON
         c.id=u.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age<18 AND EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND ad.rf_idAddCretiria LIKE 'sh%' AND u.rf_idN013=2
/*
ƒл€ случаев c:  (ReportYear =2019)  и (N_KSG like Тst19.0[27-36]Т or N_KSG like Сds19.0[18-27]Т) должно выполн€тьс€: Age>17
 and CRIT like Сsh%Т(других CRIT не должно быть)
 and (DS1 like СC[0-7][0-9]%Т or DS1 like СC97%Т or DS1 like СC80%Т or DS1 like СD0[0-9]%Т)
and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2
and ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2) - ѕ–ќ¬≈–я≈ћ данное условие
*/

SELECT DISTINCT c.id,486
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'							 
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id
				INNER JOIN #tCSG cc ON
        m.MES=cc.CSG
		AND cc.ReportYear=@year
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS1 dd ON
		d.DS2=dd.DiagnosisCode  
				INNER JOIN dbo.t_AdditionalCriterion ad ON
		c.id=ad.rf_idCase            
				INNER JOIN dbo.t_ONK_USL u ON
         c.id=u.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age>17 AND NOT EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND ad.rf_idAddCretiria LIKE 'sh%' AND u.rf_idN013=2

		/*
ƒл€ случаев c:  (ReportYear =2019)  и (N_KSG like Тst19.0[27-36]Т or N_KSG like Сds19.0[18-27]Т) должно выполн€тьс€: Age>17
 and CRIT like Сsh%Т(других CRIT не должно быть)
 and (DS1 like СC[0-7][0-9]%Т or DS1 like СC97%Т or DS1 like СC80%Т or DS1 like СD0[0-9]%Т)
and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2- ѕ–ќ¬≈–я≈ћ данное условие
and ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2) 
*/

SELECT DISTINCT c.id,486
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'							 
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id
				INNER JOIN #tCSG cc ON
        m.MES=cc.CSG
		AND cc.ReportYear=@year
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS1 dd ON
		d.DS2=dd.DiagnosisCode  
				INNER JOIN dbo.t_AdditionalCriterion ad ON
		c.id=ad.rf_idCase            				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age>17 AND EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND ad.rf_idAddCretiria LIKE 'sh%' AND NOT EXISTS(SELECT * FROM dbo.t_ONK_USL u WHERE u.rf_idN013=2 AND u.rf_idCase=c.id)

/*
ƒл€ случаев c:  (ReportYear =2019)  и (N_KSG like Тst19.0[27-36]Т or N_KSG like Сds19.0[18-27]Т) должно выполн€тьс€: Age>17
 and CRIT like Сsh%Т(других CRIT не должно быть)- ѕ–ќ¬≈–я≈ћ данное условие
 and (DS1 like СC[0-7][0-9]%Т or DS1 like СC97%Т or DS1 like СC80%Т or DS1 like СD0[0-9]%Т)
and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2
and ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2) 
*/

SELECT DISTINCT c.id,486
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'							 
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id
				INNER JOIN #tCSG cc ON
        m.MES=cc.CSG
		AND cc.ReportYear=@year
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS1 dd ON
		d.DS2=dd.DiagnosisCode  
				INNER JOIN dbo.t_AdditionalCriterion ad ON
		c.id=ad.rf_idCase   				
				INNER JOIN dbo.t_ONK_USL u ON
         c.id=u.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age>17 AND EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND ad.rf_idAddCretiria LIKE 'sh%' AND u.rf_idN013=2 AND EXISTS(SELECT 1 FROM dbo.t_AdditionalCriterion aa WHERE aa.rf_idCase=c.id AND aa.rf_idAddCretiria NOT LIKE 'sh%')

SELECT DISTINCT c.id,486
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'							 
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id
				INNER JOIN #tCSG cc ON
        m.MES=cc.CSG
		AND cc.ReportYear=@year
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS1 dd ON
		d.DS2=dd.DiagnosisCode  				 				
				INNER JOIN dbo.t_ONK_USL u ON
         c.id=u.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age>17 AND EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND u.rf_idN013=2 AND NOT NOT EXISTS(SELECT 1 FROM dbo.t_AdditionalCriterion aa WHERE aa.rf_idCase=c.id AND aa.rf_idAddCretiria NOT LIKE 'sh%')

go
DROP TABLE #tDS1
DROP TABLE #tCSG

