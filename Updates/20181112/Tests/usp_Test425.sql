USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test425]    Script Date: 05.01.2019 9:57:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test425]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
SELECT DISTINCT c.id,425
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'
				INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase					
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN018 WHERE DATEBEG<=cc.DateEnd AND DATEEND>=cc.DateEnd AND sl.DS1_T=ID_REAS)


