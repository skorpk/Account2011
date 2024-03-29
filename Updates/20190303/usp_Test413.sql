USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test413]    Script Date: 03.03.2020 10:09:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test413]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
----проверка DKK2 на соответствие справочнику
INSERT #tError
SELECT DISTINCT c.id,413
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180501'
		AND c.DateEnd<='20190101'
			  INNER JOIN dbo.t_CombinationOfSchema m ON
		c.id=m.rf_idCase			  
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprV024 WHERE IDDKK=m.rf_idV024 AND IDDKK LIKE 'sh%'  and  DATEBEG<=c.DateEnd AND DATEEND>=c.DateEnd)
--DKK2 может быть заполнен только при условии что заполен DKK1
INSERT #tError
SELECT DISTINCT c.id,413
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180501'
		AND c.DateEnd<='20190101'
			  INNER JOIN dbo.t_CombinationOfSchema m ON
		c.id=m.rf_idCase			  
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.t_AdditionalCriterion WHERE rf_idCase=c.id)

INSERT #tError
SELECT DISTINCT c.id,413
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180501'
		AND c.DateEnd<='20190101'
			  INNER JOIN dbo.t_CombinationOfSchema m ON
		c.id=m.rf_idCase			  
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.t_Diagnosis WHERE rf_idCase=c.id AND DiagnosisGroup in ('C00','C01','C02', 'C03','C04', 'C05', 'C06', 'C07', 'C08', 'C09', 'C10', 'C11', 'C12', 'C13', 'C14', 'C15', 'C16', 'C17', 'C18', 'C19', 'C20', 'C21', 'C22', 'C23', 'C24', 'C25', 'C26', 'C30', 'C31', 'C32', 'C33', 'C34', 'C37', 'C38', 'C39', 'C40', 'C41', 'C43', 'C44', 'C45', 'C46', 'C47', 'C48', 'C49', 'C50', 'C51', 'C52', 'C53', 'C54', 'C55', 'C56', 'C57', 'C58', 'C60', 'C61', 'C62', 'C63', 'C64', 'C65', 'C66', 'C67', 'C68', 'C69', 'C70', 'C71', 'C72', 'C73', 'C74', 'C75', 'C76', 'C77', 'C78', 'C79', 'C80','C97') AND TypeDiagnosis IN(1,3))

