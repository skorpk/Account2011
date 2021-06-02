USE [RegisterCases]
GO
alter PROC [dbo].[usp_Test424]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
SELECT DISTINCT c.id,424
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'					
				INNER JOIN dbo.t_DirectionMU dm ON
		c.id=dm.rf_idCase              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND dm.TypeDirection=3 AND dm.MethodStudy NOT IN(1,2,3,4)



insert #tError
SELECT DISTINCT c.id,424
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'					
				INNER JOIN dbo.t_DirectionMU dm ON
		c.id=dm.rf_idCase              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND dm.TypeDirection=3 AND dm.MethodStudy>0 AND dm.MethodStudy<5 
		AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.V001 WHERE IDRB=dm.DirectionMU AND TypeDiagnostic=dm.MethodStudy)

--DROP TABLE #tDiag
GO