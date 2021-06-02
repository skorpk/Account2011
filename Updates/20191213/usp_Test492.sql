USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test492',N'P')) is not null
	drop PROCEDURE dbo.usp_Test492
go
CREATE PROC [dbo].[usp_Test492]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS


SELECT DiagnosisCode INTO #tDS1 FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'

INSERT #tDS1( DiagnosisCode ) 
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0[0-9]'

insert #tError
SELECT DISTINCT c.id,492
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
				INNER JOIN	dbo.vw_Diagnosis d ON
         c.id=d.rf_idCase
				INNER JOIN #tDS1 dd ON
         d.DS1=dd.DiagnosisCode
				left JOIN dbo.t_ONK_SL sl ON
        c.id=sl.rf_idCase				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND m.MES='st27.014' AND sl.DS1_T<>5 

DROP TABLE #tDS1
GO
GRANT EXECUTE ON usp_Test492 TO db_RegisterCase
go


