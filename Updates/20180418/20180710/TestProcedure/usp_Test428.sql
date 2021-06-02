USE [RegisterCases]
GO
create PROC [dbo].[usp_Test428]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
---1 test
insert #tError
SELECT DISTINCT c.id,428
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'
		 	  INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
			  INNER JOIN dbo.vw_sprMKB10 m ON
		d.DS1=m.DiagnosisCode					
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN003 WHERE ISNULL(DS_t,m.MainDS)=m.MainDS AND ID_T=sl.rf_idN003)
go