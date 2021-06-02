USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test411]    Script Date: 23.03.2018 14:51:38 ******/
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
CREATE TABLE #tMU(MU VARCHAR(20))
INSERT #tMU( MU )
SELECT DISTINCT MU FROM dbo.vw_sprMU mm WHERE mm.IsNextVisit=1
CREATE UNIQUE NONCLUSTERED INDEX IX_TMPMU ON #tMU(MU)

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
			  INNER JOIN t_Mes m ON
		c.id=m.rf_idCase 
			  INNER JOIN #tMU mm ON
		m.MES=mm.mu           
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006=3 AND NOT EXISTS(SELECT 1 FROM dbo.t_NextVisitDate WHERE rf_idCase=c.id)

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
			  INNER JOIN t_Mes m ON
		c.id=m.rf_idCase 
			  INNER JOIN #tMU mm ON
		m.MES=mm.mu           
			INNER JOIN dbo.t_NextVisitDate d ON
		c.id=d.rf_idCase          
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006=3 AND a.ReportMonth>d.MonthVisit AND a.ReportYear>d.YearVisit

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
			  INNER JOIN t_Mes m ON
		c.id=m.rf_idCase 			  
			INNER JOIN dbo.t_NextVisitDate d ON
		c.id=d.rf_idCase          
where a.rf_idFiles=@idFile AND d.DateVizit IS NOT NULL AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.#tMU mm WHERE mm.MU=m.MES)
----------------------Meduslugi--------------------------------------------
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
			  INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase 
			  INNER JOIN #tMU mm ON
		m.MUCode=mm.mu           
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006=3 AND NOT EXISTS(SELECT 1 FROM dbo.t_NextVisitDate WHERE rf_idCase=c.id)

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
			  INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase 
			  INNER JOIN #tMU mm ON
		m.MUCode=mm.mu           
			INNER JOIN dbo.t_NextVisitDate d ON
		c.id=d.rf_idCase          
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006=3 AND a.ReportMonth>d.MonthVisit AND a.ReportYear>d.YearVisit

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
			  INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase 			  
			INNER JOIN dbo.t_NextVisitDate d ON
		c.id=d.rf_idCase          
where a.rf_idFiles=@idFile AND d.DateVizit IS NOT NULL AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM #tMU mm WHERE mm.MU=m.MUCode)

DROP TABLE #tMU
GO
GRANT EXECUTE ON dbo.usp_Test412 TO db_RegisterCase