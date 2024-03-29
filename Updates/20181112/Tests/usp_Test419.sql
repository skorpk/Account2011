USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test419]    Script Date: 22.11.2018 13:46:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test419]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
SELECT DiagnosisCode into #tDiag FROM vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #tDiag( DiagnosisCode ) SELECT DiagnosisCode FROM vw_sprMKB10 WHERE MainDS LIKE 'D0_' 
INSERT #tDiag( DiagnosisCode ) SELECT DiagnosisCode FROM vw_sprMKB10 WHERE MainDS ='D70' 


--Если тег присутствует, то его значение должно быть равно 1 и (DS1=Z03.1 или DS2=Z03.1).
insert #tError
SELECT DISTINCT c.id,419
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'				
			 INNER JOIN dbo.t_DS_ONK_REAB d ON
		c.id=d.rf_idCase 
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.DS_ONK=1 AND NOT EXISTS(SELECT * FROM dbo.t_Diagnosis dd WHERE dd.rf_idCase=c.id AND dd.DiagnosisCode='Z03.1' AND dd.TypeDiagnosis =1
																			UNION ALL 
																			SELECT * FROM dbo.vw_Diagnosis dd WHERE dd.rf_idCase=c.id AND DS2 IS NOT NULL AND dd.DS2='Z03.1' 
																					AND NOT EXISTS(SELECT 1 FROM #tDiag WHERE DiagnosisCode=dd.DS1)
																			)




--если (DS1=Z03.1 или DS2=Z03.1), то DS_ONK=1
insert #tError
SELECT DISTINCT c.id,419
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'				
			 INNER JOIN dbo.t_DS_ONK_REAB d ON
		c.id=d.rf_idCase 
			 INNER JOIN dbo.t_Diagnosis dd ON
		c.id=dd.rf_idCase           
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.DS_ONK<>1 AND dd.DiagnosisCode='Z03.1' AND dd.TypeDiagnosis IN(1,3)

insert #tError
SELECT DISTINCT c.id,419
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'						
			 INNER JOIN dbo.t_Diagnosis dd ON
		c.id=dd.rf_idCase           
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND dd.DiagnosisCode='Z03.1' AND dd.TypeDiagnosis IN(1,3) AND NOT EXISTS(SELECT * FROM dbo.t_DS_ONK_REAB WHERE rf_idCase=c.id)

DROP TABLE #tDiag
go