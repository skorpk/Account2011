USE [RegisterCases]
GO
create PROC [dbo].[usp_Test427]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
---1 test
insert #tError
SELECT DISTINCT c.id,427
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN002 WHERE ISNULL(DS_St,m.MainDS)=m.MainDS AND ID_St=sl.rf_idN002)

---2 test
insert #tError
SELECT DISTINCT c.id,427
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
				INNER JOIN oms_nsi.dbo.sprN006 n6 ON
		m.MainDS=n6.DS_gr          
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN006 WHERE DS_gr=m.MainDS AND ID_St=sl.rf_idN002 AND ID_T=sl.rf_idN003 AND ID_N=sl.rf_idN004 AND ID_M=sl.rf_idN005)
go