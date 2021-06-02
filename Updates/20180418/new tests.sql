USE RegisterCases
GO
/*
alter PROC [dbo].[usp_Test413]
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
			  INNER JOIN dbo.t_CombinationOfSchema m ON
		c.id=m.rf_idCase			  
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprV024 WHERE IDDKK=m.rf_idV024 AND IDDKK LIKE 'sh%')
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
			  INNER JOIN dbo.t_CombinationOfSchema m ON
		c.id=m.rf_idCase			  
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.t_Diagnosis WHERE rf_idCase=c.id AND DiagnosisGroup in ('C00','C01','C02', 'C03','C04', 'C05', 'C06', 'C07', 'C08', 'C09', 'C10', 'C11', 'C12', 'C13', 'C14', 'C15', 'C16', 'C17', 'C18', 'C19', 'C20', 'C21', 'C22', 'C23', 'C24', 'C25', 'C26', 'C30', 'C31', 'C32', 'C33', 'C34', 'C37', 'C38', 'C39', 'C40', 'C41', 'C43', 'C44', 'C45', 'C46', 'C47', 'C48', 'C49', 'C50', 'C51', 'C52', 'C53', 'C54', 'C55', 'C56', 'C57', 'C58', 'C60', 'C61', 'C62', 'C63', 'C64', 'C65', 'C66', 'C67', 'C68', 'C69', 'C70', 'C71', 'C72', 'C73', 'C74', 'C75', 'C76', 'C77', 'C78', 'C79', 'C80','C97') AND TypeDiagnosis IN(1,3))

go
GRANT EXEC ON usp_Test413 TO db_RegisterCase
GO
*/
------------------------------------------------------------------------------------------------
alter PROC [dbo].[usp_Test414]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--проверка корректности заполнени€ пол€ - провер€етс€ соответствие указанного значени€ значению цели посещени€, 
--установленному в Ќ—» дл€ кодов (кода «—) ненулевых тарифов из этого случа€
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
			  INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase            			
				INNER JOIN dbo.vw_sprMU_CEL cc ON
		m.MES=cc.MU
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.t_PurposeOfVisit WHERE rf_idCase=c.id AND cc.IsNextVisit=rf_idV025)

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
			  INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase            			
				INNER JOIN dbo.vw_sprMU_CEL cc ON
		m.MUCode=cc.MU
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND f.TypeFile='H' AND m.Price>0 AND NOT EXISTS(SELECT 1 FROM dbo.t_PurposeOfVisit WHERE rf_idCase=c.id AND cc.IsNextVisit=rf_idV025)

---об€зательно должна присутствовать при амбулаторных услови€х
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

go
-------------------------------------------------------------
GRANT EXEC ON usp_Test414 TO db_RegisterCase
GO
alter PROC [dbo].[usp_Test415]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--об€зательно заполнено при USL_OK=1,2
INSERT #tError
SELECT DISTINCT c.id,415
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180501'		
where a.rf_idFiles=@idFile AND c.rf_idV006<3 AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.t_ProfileOfBed WHERE rf_idCase=c.id)
--проверка на соответствие профил€ медицинской помощи и прокил€ койки
INSERT #tError
SELECT DISTINCT c.id,415
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180501'		
				INNER JOIN dbo.t_ProfileOfBed p ON
		c.id=p.rf_idCase
where a.rf_idFiles=@idFile AND c.rf_idV006<3 AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.vw_Profil_ProfileK WHERE Profil=c.rf_idV002 AND Profil_K=p.rf_idV020 AND c.DateEnd>=dateBeg AND c.DateEnd<=dateEnd)
go 
GRANT EXEC ON usp_Test415 TO db_RegisterCase
GO
alter PROC [dbo].[usp_Test416]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

INSERT #tError
SELECT DISTINCT c.id,416
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180501'
			  INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase            			
				INNER JOIN dbo.vw_sprMU_CEL cc ON
		m.MES=cc.MU
				INNER JOIN dbo.t_PurposeOfVisit pp ON
		c.id=pp.rf_idCase              
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND f.TypeFile='H' AND pp.rf_idV025='1.3' AND cc.IsNextVisit='1.3' AND EXISTS(SELECT 1 FROM dbo.t_PurposeOfVisit WHERE rf_idCase=c.id AND ISNULL(DN,9)>6 AND ISNULL(DN,9)<1)

INSERT #tError
SELECT DISTINCT c.id,416
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180501'
			  INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase            			
				INNER JOIN dbo.vw_sprMU_CEL cc ON
		m.MUCode=cc.MU
				INNER JOIN dbo.t_PurposeOfVisit pp ON
		c.id=pp.rf_idCase              
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND f.TypeFile='H' AND m.Price>0 AND pp.rf_idV025='1.3' AND cc.IsNextVisit='1.3' AND EXISTS(SELECT 1 FROM dbo.t_PurposeOfVisit WHERE rf_idCase=c.id AND ISNULL(DN,9)>6 AND ISNULL(DN,9)<1 )

INSERT #tError
SELECT DISTINCT c.id,416
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180501'
			  INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase            			
				INNER JOIN dbo.t_PurposeOfVisit p ON
		c.id=p.rf_idCase		
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND f.TypeFile='H' AND p.DN IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMU_CEL WHERE MU=m.MES AND IsNextVisit='1.3' )

INSERT #tError
SELECT DISTINCT c.id,416
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180501'			             			
				INNER JOIN dbo.t_PurposeOfVisit p ON
		c.id=p.rf_idCase		
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND f.TypeFile='H' AND p.DN IS NOT NULL AND NOT EXISTS(SELECT 1 
																									FROM dbo.vw_sprMU_CEL cc INNER JOIN dbo.t_Meduslugi m ON 
																													cc.mu=m.MUCode
																								    WHERE m.rf_idCase=c.id AND cc.IsNextVisit='1.3' 
																									)

go 
GRANT EXEC ON usp_Test416 TO db_RegisterCase
