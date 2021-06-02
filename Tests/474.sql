USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT,
	@month TINYINT=1,
	@year SMALLINT=2019

select @idFile=id, @month=ReportMonth, @year=ReportYear from vw_getIdFileNumber where CodeM='103001' and NumberRegister=83 and ReportYear=2020

select * from vw_getIdFileNumber where id=@idFile

SELECT DISTINCT c.id,474, d.DateDiagnostic,c.DateEnd,c.rf_idV006
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				
			INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase 
			INNER JOIN dbo.t_ONK_SL o ON
		c.id=o.rf_idCase
			INNER JOIN dbo.t_DiagnosticBlock d ON
		o.id=d.rf_idONK_SL         
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND (d.DateDiagnostic<'20180901' OR d.DateDiagnostic>cc.DateEnd)