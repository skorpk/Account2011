USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test420]    Script Date: 01.06.2020 15:28:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test420]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
-- на соответсвие справочнику V027
insert #tError
SELECT DISTINCT c.id,420
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.C_ZAB IS NOT NULL AND NOT EXISTS(SELECT * FROM  oms_nsi.dbo.sprV027 WHERE IDCZ=c.C_ZAB AND cc.DateEnd BETWEEN DATEBEG AND DATEEND)

--Тег обязательно присутствует, если (USL_OK=3 and DS1 not is like Z%) 
insert #tError
SELECT DISTINCT c.id,420
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'							 
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.C_ZAB IS NULL AND c.rf_idV006=3 AND d.DS1 NOT LIKE 'Z[0-9][0-9]%'

--Тег обязательно присутствует, если (DS1 is like C% or DS1 like D0%)
SELECT DiagnosisCode INTO #tDS1 FROM dbo.vw_sprMKB10 WHERE DiagnosisCode LIKE 'C%'
INSERT #tDS1( DiagnosisCode ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE DiagnosisCode LIKE 'D0%'
insert #tError
SELECT DISTINCT c.id,420
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'							 
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS1 dd ON
		d.DS1=dd.DiagnosisCode              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.C_ZAB IS NULL 

--Тег обязательно присутствует, если (DS1 like D70% and один из сопутствующих DS2 из диапазона (C00-C80,C97))
SELECT DiagnosisCode INTO #tDS2 FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C00' AND 'C80'
INSERT #tDS2 SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS='C97'

--insert #tError
--SELECT DISTINCT c.id,420
--from t_File f INNER JOIN t_RegistersCase a ON
--		f.id=a.rf_idFiles
--		AND a.ReportMonth=@month
--		AND a.ReportYear=@year
--			  inner join t_RecordCase r on
--		a.id=r.rf_idRegistersCase
--			  inner join t_Case c on
--		r.id=c.rf_idRecordCase						
--		AND c.DateEnd>='20180901'							 
--				INNER JOIN dbo.vw_Diagnosis d ON
--		c.id=d.rf_idCase              				
--				INNER JOIN #tDS2 dd ON
--		d.DS2=dd.DiagnosisCode              
--where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.C_ZAB IS NULL AND d.DS1 LIKE 'D70%'

DROP TABLE #tDS1
DROP TABLE #tDS2
