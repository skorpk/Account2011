USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test307]    Script Date: 04.02.2021 12:17:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test307]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError 
SELECT DISTINCT c.id,307
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200101'		
			INNER JOIN dbo.t_DrugTherapy0 d ON
		c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND rf_idV020 IN('000895','000903','001652','000764') AND rf_idV024 IN('sh9001','sh9002')
		AND NOT EXISTS(SELECT 1 FROM dbo.t_DrugTherapy0 d0 WHERE d0.rf_idCase=c.id AND d0.rf_idN013=d.rf_idN013 AND d0.rf_idV020 not IN('000895','000903','001652','000764'))
GROUP BY c.id,d.rf_idN013,d.rf_idV020,c.NumberHistoryCase