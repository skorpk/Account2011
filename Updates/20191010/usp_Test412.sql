USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test412]    Script Date: 11.10.2019 10:09:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test412]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

INSERT #tError
SELECT DISTINCT c.id,412
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180401'			  
			  INNER JOIN t_PurposeOfVisit p ON
		c.id=p.rf_idCase          
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND p.rf_idV025='1.3' AND p.DN IN(1,2) AND NOT EXISTS(SELECT 1 FROM dbo.t_NextVisitDate WHERE rf_idCase=c.id)

DECLARE @period INT
SET @period=CAST(CAST(@year AS CHAR(4)) + RIGHT('0'+CAST(@month AS VARCHAR(2)),2) AS INT)

INSERT #tError
SELECT DISTINCT c.id,412
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180401'		
			INNER JOIN dbo.t_NextVisitDate d ON
		c.id=d.rf_idCase          
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.DateVizit IS NOT null AND @period>d.Period 
