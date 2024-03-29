USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test414]    Script Date: 21.05.2018 16:40:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test414]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
INSERT #tError
SELECT DISTINCT c.id,414
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180501'
			  INNER JOIN dbo.t_PurposeOfVisit m ON
		c.id=m.rf_idCase			  
where a.rf_idFiles=@idFile AND m.rf_idV025 IS NOT NULL AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprV025 WHERE IDPC=m.rf_idV025)

--INSERT #tError
--SELECT DISTINCT c.id,414
--from t_File f INNER JOIN t_RegistersCase a ON
--		f.id=a.rf_idFiles
--		AND a.ReportMonth=@month
--		AND a.ReportYear=@year
--			  inner join t_RecordCase r on
--		a.id=r.rf_idRegistersCase
--			  inner join t_Case c on
--		r.id=c.rf_idRecordCase						
--		AND c.DateEnd>='20180501'
--			  INNER JOIN dbo.t_PurposeOfVisit m ON
--		c.id=m.rf_idCase			  
--where a.rf_idFiles=@idFile AND f.TypeFile='H' AND m.rf_idV025='1.3' AND ISNULL(m.DN,0)<>6

---обязательно должна присутствовать при амбулаторных условиях
INSERT #tError
SELECT DISTINCT c.id,414
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180501'			  
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006=3 AND NOT EXISTS(SELECT * FROM dbo.t_PurposeOfVisit WHERE rf_idCase=c.id AND rf_idV025 IS NOT NULL)


--INSERT #tError
--SELECT DISTINCT c.id,414
--from t_File f INNER JOIN t_RegistersCase a ON
--		f.id=a.rf_idFiles
--		AND a.ReportMonth=@month
--		AND a.ReportYear=@year
--			  inner join t_RecordCase r on
--		a.id=r.rf_idRegistersCase
--			  inner join t_Case c on
--		r.id=c.rf_idRecordCase						
--		AND c.DateEnd>='20180501'
--			  INNER JOIN dbo.t_PurposeOfVisit m ON
--		c.id=m.rf_idCase			  
--where a.rf_idFiles=@idFile AND f.TypeFile='H' AND m.DN IS NOT NULL AND m.DN>6 
