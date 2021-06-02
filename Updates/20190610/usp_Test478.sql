USE [RegisterCases]
GO

/****** Object:  StoredProcedure [dbo].[usp_Test477]    Script Date: 10.06.2019 15:32:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create PROC [dbo].[usp_Test478]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
-- for H files
insert #tError
SELECT DISTINCT c.id,478
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190501'	
				INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase						 
				INNER JOIN dbo.t_DirectionMU m ON
		c.id=m.rf_idCase              
where a.rf_idFiles=@idFile AND m.DirectionMO IS NOT NULL AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprMO WHERE MCOD=m.DirectionMO)


-- for F files
insert #tError
SELECT DISTINCT c.id,478
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190501'	
				INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase						 
				INNER JOIN dbo.t_Prescriptions m ON
		c.id=m.rf_idCase              
where a.rf_idFiles=@idFile AND m.DirectionMO IS NOT NULL AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprMO WHERE MCOD=m.DirectionMO)
GO

GRANT EXECUTE ON usp_Test478 TO db_RegisterCase


