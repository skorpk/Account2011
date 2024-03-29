USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test410]    Script Date: 28.02.2018 11:31:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--CREATE PROC usp_Test411
--		@idFile INT,
--		@month tinyint,
--		@year smallint,
--		@codeLPU char(6)		
--AS
DECLARE @idfile INT=124154

declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6),
		@typeFile char(1)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO, @typeFile=UPPER(f.TypeFile)
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

CREATE TABLE #tmpMU(MU VARCHAR(16), CodeMU TINYINT)
INSERT #tmpMU( MU, CodeMU ) SELECT DISTINCT MU,91 FROM dbo.vw_sprMU WHERE mu LIKE '2.91.%'
INSERT #tmpMU( MU, CodeMU ) SELECT DISTINCT MU,85 FROM dbo.vw_sprMU WHERE mu LIKE '2.85.%'


SELECT DISTINCT c.id,411
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
				INNER JOIN dbo.t_DispInfo d2 ON
		c.id=d2.rf_idCase   				
where a.rf_idFiles=@idFile AND d2.TypeDisp='ОН2'  AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi m INNER JOIN #tmpMU mm ON m.MUCode=mm.MU WHERE rf_idCase=c.id)
---для ОН2 2.91.* и 2.85. * должны идти вместе
;WITH cte
AS(
select DISTINCT c.id,COUNT(DISTINCT mm.CodeMU) AS CountMU
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
				INNER JOIN dbo.t_DispInfo d2 ON
		c.id=d2.rf_idCase   
				INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase      
				INNER JOIN #tmpMU mm ON
		m.MUCode=mm.MU     
where a.rf_idFiles=@idFile AND d2.TypeDisp='ОН2'
GROUP BY c.id 
)
SELECT id,411 FROM cte WHERE CountMU<>2
DROP TABLE #tmpMU

