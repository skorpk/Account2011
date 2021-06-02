USE [RegisterCases]
GO
create PROC [dbo].[usp_Test426]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
SELECT DISTINCT c.id,426
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'					
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND isnull(sl.ConsultationInfo,1)>3 


insert #tError
SELECT DISTINCT c.id,426
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'					
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.ConsultationInfo<3 AND sl.DateConsultation IS NULL


insert #tError
SELECT DISTINCT c.id,426
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'					
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.DateConsultation IS NOT NULL AND ISNULL(sl.ConsultationInfo,9)>3

GO