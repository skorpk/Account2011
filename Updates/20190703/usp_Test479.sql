USE [RegisterCases]
GO

/****** Object:  StoredProcedure [dbo].[usp_Test477]    Script Date: 10.06.2019 15:32:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

alter PROC [dbo].[usp_Test479]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
SELECT DISTINCT c.id,479
from t_file f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190501'	
				INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase	
				INNER JOIN (SELECT rf_idCase,MIN(DateHelpBegin) AS DateHelpBegin FROM dbo.t_Meduslugi	GROUP BY rf_idCase) m ON
		c.id=m.rf_idCase              
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND (m.DateHelpBegin<>c.DateBegin OR c.DateBegin<>cc.DateBegin) AND f.TypeFile='H'

GO
GRANT EXECUTE ON usp_Test479 TO db_RegisterCase
go

