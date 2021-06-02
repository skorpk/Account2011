USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test495',N'P')) is not null
	drop PROCEDURE dbo.usp_Test495
go
CREATE PROC dbo.usp_Test495
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
SELECT DISTINCT c.id,495
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200101'							 
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id				
				inner JOIN dbo.t_ONK_SL sl ON
        c.id=sl.rf_idCase		
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND m.MES ='ds19.033' AND NOT EXISTS(SELECT * FROM dbo.t_DiagnosticBlock d WHERE d.rf_idONK_SL=sl.id)

insert #tError
SELECT DISTINCT c.id,495
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200101'							 
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id				
				inner JOIN dbo.t_ONK_SL sl ON
        c.id=sl.rf_idCase		
				INNER JOIN dbo.t_DiagnosticBlock db ON
        sl.id=db.rf_idONK_SL
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND m.MES ='ds19.033'  AND (db.DateDiagnostic<c.DateBegin OR db.DateDiagnostic>c.DateEnd)

GO
GRANT EXECUTE ON usp_Test495 TO db_RegisterCase
