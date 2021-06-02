USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test488',N'P')) is not null
	drop PROCEDURE dbo.usp_Test488
go
CREATE PROC [dbo].[usp_Test488]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

SELECT DiagnosisCode INTO #tDS2 FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C81' AND 'C96'


CREATE TABLE #tCSG(CSG VARCHAR(20),ReportYear SMALLINT)

INSERT #tCSG(CSG) VALUES ('st05.009'), ('ds05.006')
/*
(AGE>17 and (DS1 between C81 and C96)  and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2 
And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2) and существует USL, в котором VID_VME like СA25.30.033.00[1-2]Т - ѕровер€ем
*/
insert #tError
SELECT DISTINCT c.id,488
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
		d.DS2=dd.DiagnosisCode  				
				INNER JOIN dbo.t_ONK_USL u ON
         c.id=u.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age>17 AND EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND u.rf_idN013=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.rf_idCase=c.id AND mm.MUSurgery LIKE 'A25.30.033.00[1,2]')

/*
(AGE>17 and (DS1 between C81 and C96)  and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2 
And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2)- ѕровер€ем
and существует USL, в котором VID_VME like СA25.30.033.00[1-2]Т 
*/
insert #tError
SELECT DISTINCT c.id,488
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
		d.DS2=dd.DiagnosisCode  				
				INNER JOIN dbo.t_ONK_USL u ON
         c.id=u.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age>18 AND NOT EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND u.rf_idN013=2 AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.rf_idCase=c.id AND mm.MUSurgery LIKE 'A25.30.033.00[1,2]')

/*
(AGE>17 and (DS1 between C81 and C96)  and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2 - ѕровер€ем
And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2)
and существует USL, в котором VID_VME like СA25.30.033.00[1-2]Т 
*/
insert #tError
SELECT DISTINCT c.id,488
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
		d.DS2=dd.DiagnosisCode 				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age>18 AND EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)
		AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_USL u WHERE c.id=u.rf_idCase AND u.rf_idN013=2)
		AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.rf_idCase=c.id AND mm.MUSurgery LIKE 'A25.30.033.00[1,2]')
/*
(AGE>17 and (DS1 between C81 and C96) - ѕровер€ем
and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2
And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2)
and существует USL, в котором VID_VME like СA25.30.033.00[1-2]Т 
*/
insert #tError
SELECT DISTINCT c.id,488
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age<18 AND sl.DS1_T <3	AND mm.MUSurgery LIKE 'A25.30.033.00[1,2]'
		AND NOT EXISTS(SELECT 1 FROM #tDS2 dd where	d.DS2=dd.DiagnosisCode )

/*
(AGE>17 - ѕровер€ем
and (DS1 between C81 and C96) and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=2 And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2)
and существует USL, в котором VID_VME like СA25.30.033.00[1-2]Т 
*/
insert #tError
SELECT DISTINCT c.id,488
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
		d.DS2=dd.DiagnosisCode 
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase      
				INNER JOIN dbo.t_ONK_USL usl ON
		c.id=usl.rf_idCase      	   				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.age<18 AND sl.DS1_T <3 AND usl.rf_idN013=2	
	AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.rf_idCase=c.id AND mm.MUSurgery LIKE 'A25.30.033.00[1,2]')	

DROP TABLE #tDS2
DROP TABLE #tCSG
GO
GRANT EXECUTE ON usp_Test488 TO db_RegisterCase
go

