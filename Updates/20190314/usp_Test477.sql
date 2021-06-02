USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test420]    Script Date: 13.03.2019 15:58:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[usp_Test477]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
-- на соответсвие справочнику V027
insert #tError
SELECT DISTINCT c.id,477
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190901'	
				INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase						 
				INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase              
where a.rf_idFiles=@idFile AND m.Tariff IS NOT NULL AND MES IS null

GO
GRANT EXECUTE ON dbo.usp_Test477 TO db_RegisterCase