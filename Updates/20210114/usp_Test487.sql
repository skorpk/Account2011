USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test487]    Script Date: 14.01.2021 9:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test487]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
SELECT DiagnosisCode INTO #tDS1 FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C[0-9][0-9]'
INSERT #tDS1( DiagnosisCode ) 
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0[0-9]'

SELECT DiagnosisCode INTO #tDS2 FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C81' AND 'C96'


CREATE TABLE #tCSG(CSG VARCHAR(20),ReportYear SMALLINT)




INSERT #tCSG(CSG) 
VALUES ('st05.006'), ('st05.007'),('st05.010'), ('st05.011'),('st08.001'),('st08.001'),('st08.002'),('st08.003'),('st19.059'),('st19.060')
		,('ds05.003'),('ds05.004'), ('ds05.007'), ('ds05.008'), ('ds08.001'),('ds08.002'),('ds08.003'),('ds19.034'),('ds19.035')


/*
(AGE<18 and DS1=ЗНО and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2 
And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2) and существует USL, 
в котором VID_VME=A25.30.014- Проверяем это)
*/
insert #tError
SELECT DISTINCT c.id,487
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
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS1 dd ON
		d.DS1=dd.DiagnosisCode  				
				INNER JOIN dbo.t_ONK_USL u ON
         c.id=u.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age<18 AND EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND u.rf_idN013=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.rf_idCase=c.id AND mm.MUSurgery='A25.30.014')
/*
(AGE<18 and DS1=ЗНО and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2 
And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2) Проверяем это
and существует USL, в котором VID_VME=A25.30.014)
*/
insert #tError
SELECT DISTINCT c.id,487
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
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS1 dd ON
		d.DS1=dd.DiagnosisCode  				
				INNER JOIN dbo.t_ONK_USL u ON
         c.id=u.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age<18 AND NOT EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND u.rf_idN013=2 

		/*
(AGE<18 and DS1=ЗНО and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2  Проверяем это
And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2)
and существует USL, в котором VID_VME=A25.30.014)
*/
insert #tError
SELECT DISTINCT c.id,487
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
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS1 dd ON
		d.DS1=dd.DiagnosisCode 				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age<18 AND EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_USL u WHERE c.id=u.rf_idCase AND u.rf_idN013=2)
/*
(AGE<18 and DS1=ЗНО Проверяем это
and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2  
And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2)
and существует USL, в котором VID_VME=A25.30.014)
*/
insert #tError
SELECT DISTINCT c.id,487
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
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase    
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase         				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age<18 AND sl.DS1_T <3		
		AND NOT EXISTS(SELECT 1 FROM #tDS1 dd where	d.DS1=dd.DiagnosisCode )

		/*
(AGE<18 and DS1=ЗНО Проверяем это
and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2  
And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2)
and существует USL, в котором VID_VME=A25.30.014)
*/
insert #tError
SELECT DISTINCT c.id,487
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
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase    
			INNER JOIN #tDS1 dd ON
		d.DS1=dd.DiagnosisCode 
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase      
				INNER JOIN dbo.t_ONK_USL usl ON
		c.id=usl.rf_idCase      	   				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age>18 AND sl.DS1_T <3 AND usl.rf_idN013=2	
	AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.rf_idCase=c.id AND mm.MUSurgery='A25.30.014')	

DROP TABLE #tDS1

---------------------------------Adulte------------------------------------
/*
(AGE>17 and (DS1 between C81 and C96)  and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2 
And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2) and существует USL, в котором VID_VME=A25.30.033 -Проверяем)
*/
insert #tError
SELECT DISTINCT c.id,487
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
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS2 dd ON
		d.DS1=dd.DiagnosisCode  				
				INNER JOIN dbo.t_ONK_USL u ON
         c.id=u.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age>17 AND EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND u.rf_idN013=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.rf_idCase=c.id AND mm.MUSurgery='A25.30.033')

/*
(AGE>17 and (DS1 between C81 and C96)  and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2 
And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2) -Проверяем
and существует USL, в котором VID_VME=A25.30.033 )
*/
insert #tError
SELECT DISTINCT c.id,487
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
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS2 dd ON
		d.DS1=dd.DiagnosisCode  				
				INNER JOIN dbo.t_ONK_USL u ON
         c.id=u.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age>17 AND NOT EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND u.rf_idN013=2 

/*
(AGE>17 and (DS1 between C81 and C96)  and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2  -Проверяем
And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2)
and существует USL, в котором VID_VME=A25.30.033 )
*/
insert #tError
SELECT DISTINCT c.id,487
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
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS2 dd ON
		d.DS1=dd.DiagnosisCode 				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age>17 AND EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_USL u WHERE c.id=u.rf_idCase AND u.rf_idN013=2)
/*
(AGE>17 and (DS1 between C81 and C96)  and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2  -Проверяем
And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2)
and существует USL, в котором VID_VME=A25.30.033 )
*/
insert #tError
SELECT DISTINCT c.id,487
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
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase    
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase         			
				INNER JOIN dbo.t_Meduslugi mm ON
		c.id=mm.rf_idCase	
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age>17 AND sl.DS1_T <3	AND mm.MUSurgery='A25.30.033'
		AND NOT EXISTS(SELECT 1 FROM #tDS2 dd where	d.DS1=dd.DiagnosisCode )

/*
(AGE>17 and (DS1 between C81 and C96)  and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2  -Проверяем
And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2)
and существует USL, в котором VID_VME=A25.30.033 )
*/
insert #tError
SELECT DISTINCT c.id,487
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
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase    
			INNER JOIN #tDS2 dd ON
		d.DS1=dd.DiagnosisCode 
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase      
				INNER JOIN dbo.t_ONK_USL usl ON
		c.id=usl.rf_idCase      	   				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age<18 AND sl.DS1_T <3 AND usl.rf_idN013=2	
	AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.rf_idCase=c.id AND mm.MUSurgery='A25.30.033')	

DROP TABLE #tDS2
DROP TABLE #tCSG
---------------------------------------------------2021---------------------------
SELECT DiagnosisCode INTO #tDS2021 FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C00' AND 'C80'
INSERT #tDS2021( DiagnosisCode ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0[0-9]'
INSERT #tDS2021( DiagnosisCode ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS ='C97'
SELECT code INTO #tCSGAdult2021 FROM dbo.vw_sprCSG WHERE code  BETWEEN 'st19.062' AND 'st19.074' AND dateBeg>='20210101'
INSERT #tCSGAdult2021 SELECT code FROM dbo.vw_sprCSG WHERE code  BETWEEN 'ds19.037' AND 'ds19.049' AND dateBeg>='20210101'

SELECT code INTO #tCSGChild2021 FROM dbo.vw_sprCSG WHERE code  like 'st08.00[1-3]'AND dateBeg>='20210101'
INSERT #tCSGChild2021 SELECT code FROM dbo.vw_sprCSG WHERE code  like 'st08.00[1-3]'AND dateBeg>='20210101'
insert #tError
SELECT DISTINCT c.id,487
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20210101'		
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id
				INNER JOIN #tCSGAdult2021 cc ON
        m.MES=cc.code		
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS2021 dd ON
		d.DS1=dd.DiagnosisCode  				
				INNER JOIN dbo.t_ONK_USL u ON
         c.id=u.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age>17 AND EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND u.rf_idN013=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_AdditionalCriterion mm WHERE mm.rf_idCase=c.id AND mm.rf_idAddCretiria LIKE 'sh%')

		insert #tError
SELECT DISTINCT c.id,487
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20210101'					
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id
				INNER JOIN #tCSGChild2021 cc ON  
        m.MES=cc.code
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS2021 dd ON
		d.DS1=dd.DiagnosisCode  				
				INNER JOIN dbo.t_ONK_USL u ON
         c.id=u.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age<18 AND EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND u.rf_idN013=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.rf_idCase=c.id AND mm.MUSurgery='A25.30.014')

drop table #tCSGChild2021
drop table #tCSGAdult2021
DROP TABLE #tDS2021
go