USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test484',N'P')) is not null
	drop PROCEDURE dbo.usp_Test484
go
CREATE PROC [dbo].[usp_Test484]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
SELECT DiagnosisCode INTO #tDS1 FROM dbo.vw_sprMKB10 WHERE DiagnosisCode LIKE 'C%'
INSERT #tDS1( DiagnosisCode ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE DiagnosisCode LIKE 'D0%'

CREATE TABLE #tCSG(CSG VARCHAR(20),ReportYear SMALLINT)

INSERT #tCSG(CSG,ReportYear) VALUES('st36.012',2019),('ds36.006',2019)

insert #tError
SELECT DISTINCT c.id,484
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT * FROM dbo.t_ONK_SL d WHERE d.rf_idCase=c.id AND d.DS1_T=6)

DROP TABLE #tDS1


GO
GRANT EXECUTE ON usp_Test484 TO db_RegisterCase
go

