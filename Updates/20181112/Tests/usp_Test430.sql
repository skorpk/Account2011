USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test430]    Script Date: 05.01.2019 10:16:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test430]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
SELECT DISTINCT c.id,430
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'
		AND c.DateEnd<'20190101'
			INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase
		 	  INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
			  INNER JOIN dbo.vw_sprMKB10 m ON
		d.DS1=m.DiagnosisCode					
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase  		
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN005 WHERE (DS_M=m.DiagnosisCode OR DS_M=m.MainDS OR ISNULL(DS_M,m.MainDS)=m.MainDS ) AND ID_M=sl.rf_idN005
		AND cc.DateBegin BETWEEN DATEBEG AND DATEEND)

insert #tError
SELECT DISTINCT c.id,430
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
		 	  INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
			  INNER JOIN dbo.vw_sprMKB10 m ON
		d.DS1=m.DiagnosisCode					
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase  		
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.DS1_T=0 AND c.Age>17
AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN005 WHERE (DS_M=m.DiagnosisCode OR DS_M=m.MainDS OR ISNULL(DS_M,m.MainDS)=m.MainDS ) AND ID_M=sl.rf_idN005 AND DATEBEG<=cc.DateEnd AND cc.DateEnd<=DATEEND) 
go
