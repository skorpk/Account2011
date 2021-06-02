USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test489',N'P')) is not null
	drop PROCEDURE dbo.usp_Test489
go
CREATE PROC [dbo].[usp_Test489]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

CREATE TABLE #tCSG(CSG VARCHAR(20),ReportYear SMALLINT)

INSERT #tCSG(CSG,ReportYear) 
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code IN('st19.039','st19.010')
UNION all
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code LIKE 'st19.04[0-8]'
UNION all
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code LIKE 'ds19.00[1-9]'

/*
ZL_LIST/ZAP/Z_SL/SL/KSG_KPG/CRIT like ‘fr%’ and ZL_LIST/ZAP/Z_SL/SL/ONK_USL/USL_TIP=3 And  ZL_LIST/ZAP/Z_SL/SL/ONK_SL/DS1_T in (0,1,2) 
*/
insert #tError
SELECT DISTINCT c.id,489
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
				INNER JOIN dbo.t_ONK_USL u ON
        c.id=u.rf_idCase
				INNER JOIN dbo.t_ONK_SL sl ON
        c.id=sl.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.t_AdditionalCriterion aa WHERE aa.rf_idCase=c.id AND aa.rf_idAddCretiria LIKE 'fr%')
		AND u.rf_idN013=3 AND sl.DS1_T<3

insert #tError
SELECT DISTINCT c.id,489
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
				INNER JOIN dbo.t_ONK_USL u ON
        c.id=u.rf_idCase				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND EXISTS(SELECT 1 FROM dbo.t_AdditionalCriterion aa WHERE aa.rf_idCase=c.id AND aa.rf_idAddCretiria LIKE 'fr%')
		AND u.rf_idN013=3 AND NOT EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T <3)

insert #tError
SELECT DISTINCT c.id,489
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
				INNER JOIN dbo.t_ONK_SL sl ON
        c.id=sl.rf_idCase				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND EXISTS(SELECT 1 FROM dbo.t_AdditionalCriterion aa WHERE aa.rf_idCase=c.id AND aa.rf_idAddCretiria LIKE 'fr%')
		AND sl.DS1_T<3 AND NOT EXISTS(SELECT * FROM dbo.t_ONK_USL d WHERE d.rf_idCase=c.id AND d.rf_idN013=3)
GO
GRANT EXECUTE ON usp_Test489 TO db_RegisterCase
go

