USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT	

select @idFile=id from vw_getIdFileNumber where CodeM='103001' and NumberRegister=122 and ReportYear=2020

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
/*
(AGE<18 and DS1=ЗНО and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2 
And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2) Проверяем это
and существует USL, в котором VID_VME=A25.30.014)
*/

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

--SELECT DISTINCT c.id,487,'Error'
--from t_File f INNER JOIN t_RegistersCase a ON
--		f.id=a.rf_idFiles
--		AND a.ReportMonth=@month
--		AND a.ReportYear=@year
--			  inner join t_RecordCase r on
--		a.id=r.rf_idRegistersCase
--			  inner join t_Case c on
--		r.id=c.rf_idRecordCase						
--		AND c.DateEnd>='20190101'							 
--				INNER JOIN dbo.t_MES m ON
--        m.rf_idCase = c.id
--				INNER JOIN #tCSG cc ON
--        m.MES=cc.CSG		
--				INNER JOIN dbo.vw_Diagnosis d ON
--		c.id=d.rf_idCase              				
--				INNER JOIN #tDS1 dd ON
--		d.DS1=dd.DiagnosisCode 				
--where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age<18 AND EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
--		AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_USL u WHERE c.id=u.rf_idCase AND u.rf_idN013=2)
/*
(AGE<18 and DS1=ЗНО Проверяем это
and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2  
And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2)
and существует USL, в котором VID_VME=A25.30.014)
*/

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

SELECT DISTINCT c.id,487,'error'
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
*/
GO

go
DROP TABLE #tDS2
DROP TABLE #tCSG
