USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test486]    Script Date: 14.01.2021 10:47:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test486]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
SELECT DiagnosisCode INTO #tDS1 FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C[0-7][0-9]'
INSERT #tDS1( DiagnosisCode ) 
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0[0-9]'
UNION ALL
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS IN('C80','C97')

CREATE TABLE #tCSG(CSG VARCHAR(20),ReportYear SMALLINT)

INSERT #tCSG(CSG,ReportYear) 
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code LIKE 'st19.02[7-9]'
UNION ALL
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code LIKE 'st19.05[6-8]'
UNION ALL
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code LIKE 'st19.03[0-6]'
UNION ALL
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code LIKE 'ds19.01[8,9]'
UNION ALL
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code LIKE 'ds19.02[0-7]'
UNION ALL
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code LIKE 'ds19.03[0-2]'

/*
Для случаев c:  (ReportYear =2019)  и (N_KSG like ’st19.0[27-36]’ or N_KSG like ‘ds19.0[18-27]’) 
должно выполняться: Age>17 -- ПРОВЕРЯЕМ данное условие
 and CRIT like ‘sh%’(других CRIT не должно быть)
 and (DS1 like ‘C[0-7][0-9]%’ or DS1 like ‘C97%’ or DS1 like ‘C80%’ or DS1 like ‘D0[0-9]%’)
and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2
and ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2) 
*/
insert #tError
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
		AND c.DateEnd<'20210101'						 
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id
				INNER JOIN #tCSG cc ON
        m.MES=cc.CSG
		AND cc.ReportYear>2018
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
Для случаев c:  (ReportYear =2019)  и (N_KSG like ’st19.0[27-36]’ or N_KSG like ‘ds19.0[18-27]’) должно выполняться: Age>17
 and CRIT like ‘sh%’(других CRIT не должно быть)
 and (DS1 like ‘C[0-7][0-9]%’ or DS1 like ‘C97%’ or DS1 like ‘C80%’ or DS1 like ‘D0[0-9]%’)
and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2
and ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2) - ПРОВЕРЯЕМ данное условие
*/
insert #tError
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
		AND c.DateEnd<'20210101'					 
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id
				INNER JOIN #tCSG cc ON
        m.MES=cc.CSG
		AND cc.ReportYear>2018
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
Для случаев c:  (ReportYear =2019)  и (N_KSG like ’st19.0[27-36]’ or N_KSG like ‘ds19.0[18-27]’) должно выполняться: Age>17
 and CRIT like ‘sh%’(других CRIT не должно быть)
 and (DS1 like ‘C[0-7][0-9]%’ or DS1 like ‘C97%’ or DS1 like ‘C80%’ or DS1 like ‘D0[0-9]%’)
and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2- ПРОВЕРЯЕМ данное условие
and ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2) 
*/
insert #tError
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
		AND c.DateEnd<'20210101'		 
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id
				INNER JOIN #tCSG cc ON
        m.MES=cc.CSG
		AND cc.ReportYear>2018
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS1 dd ON
		d.DS2=dd.DiagnosisCode  
				INNER JOIN dbo.t_AdditionalCriterion ad ON
		c.id=ad.rf_idCase            				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age>17 AND EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND ad.rf_idAddCretiria LIKE 'sh%' AND NOT EXISTS(SELECT * FROM dbo.t_ONK_USL u WHERE u.rf_idN013=2 AND u.rf_idCase=c.id)

/*
Для случаев c:  (ReportYear =2019)  и (N_KSG like ’st19.0[27-36]’ or N_KSG like ‘ds19.0[18-27]’) должно выполняться: Age>17
 and CRIT like ‘sh%’(других CRIT не должно быть)- ПРОВЕРЯЕМ данное условие
 and (DS1 like ‘C[0-7][0-9]%’ or DS1 like ‘C97%’ or DS1 like ‘C80%’ or DS1 like ‘D0[0-9]%’)
and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2
and ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2) 
*/
insert #tError
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
		AND c.DateEnd<'20210101'						 
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id
				INNER JOIN #tCSG cc ON
        m.MES=cc.CSG
		AND cc.ReportYear>2018
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

insert #tError
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
		AND c.DateEnd<'20210101'					 
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id
				INNER JOIN #tCSG cc ON
        m.MES=cc.CSG
		AND cc.ReportYear>2018
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS1 dd ON
		d.DS2=dd.DiagnosisCode  				 				
				INNER JOIN dbo.t_ONK_USL u ON
         c.id=u.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age>17 AND EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND u.rf_idN013=2 AND NOT NOT EXISTS(SELECT 1 FROM dbo.t_AdditionalCriterion aa WHERE aa.rf_idCase=c.id AND aa.rf_idAddCretiria NOT LIKE 'sh%')


DROP TABLE #tDS1
DROP TABLE #tCSG

