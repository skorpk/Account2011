USE [RegisterCases]

GO
ALTER PROC [dbo].[usp_Test423]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
SELECT DISTINCT c.id,423
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'
				INNER JOIN t_DirectionMU d ON
		c.id=d.rf_idCase							 
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.DirectionDate>c.DateEnd  OR d.DirectionDate<c.DateBegin


insert #tError
SELECT DISTINCT c.id,423
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
				INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase              
				INNER JOIN t_DirectionMU d ON
		c.id=d.rf_idCase							 
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprV028 WHERE IDVN=d.TypeDirection AND DATEBEG<=cc.DateEnd AND DATEEND>=cc.DateEnd)
go
