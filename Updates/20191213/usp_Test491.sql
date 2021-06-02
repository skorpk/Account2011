USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test491',N'P')) is not null
	drop PROCEDURE dbo.usp_Test491
go
CREATE PROC [dbo].[usp_Test491]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

CREATE TABLE #tCSG(CSG VARCHAR(20),ReportYear SMALLINT)

INSERT #tCSG(CSG,ReportYear) 
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code LIKE 'st19.0[0,1][0-9]'
UNION all
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code LIKE 'st19.02[0-6]'

insert #tError
SELECT DISTINCT c.id,491
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.DS1_T<3 AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_USL u WHERE u.rf_idCase=c.id AND u.rf_idN013=1)

insert #tError
SELECT DISTINCT c.id,491
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
				INNER JOIN dbo.t_ONK_USL sl ON
        c.id=sl.rf_idCase				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.rf_idN013=1 AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_SL u WHERE u.rf_idCase=c.id AND u.DS1_T<3)
GO
GRANT EXECUTE ON usp_Test491 TO db_RegisterCase
go


