USE [RegisterCases]
GO
DECLARE @idfile INT=137496

declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6),
		@typeFile char(1)

SELECT @idFile=f.id from vw_getIdFileNumber f WHERE CodeM='184603' AND ReportYear=2020 AND NumberRegister=34
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO, @typeFile=UPPER(f.TypeFile)
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile


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
			INNER JOIN dbo.t_MES m1 ON
		c.id=m1.rf_idCase            			
				INNER JOIN dbo.vw_sprMU_CEL cc ON
		m1.MES=cc.MU		  
where a.rf_idFiles=@idFile AND m.rf_idV025 IS NOT NULL AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprV025 WHERE IDPC=m.rf_idV025)

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
			 INNER JOIN dbo.t_Meduslugi m1 ON
		c.id=m1.rf_idCase            			
				INNER JOIN dbo.vw_sprMU_CEL cc ON
		m1.MUCode=cc.MU
where a.rf_idFiles=@idFile AND m.rf_idV025 IS NOT NULL AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprV025 WHERE IDPC=m.rf_idV025)
-----------------------------------------------------------------------
/*
2.	Проверка 2: проверка корректности заполнения поля - проверяется соответствие указанного значения значению цели посещения, установленному в НСИ для кодов (кода ЗС) ненулевых тарифов из этого случая
*/
SELECT DISTINCT c.id,414,m1.MES
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
			INNER JOIN dbo.t_MES m1 ON
		c.id=m1.rf_idCase            			
				INNER JOIN dbo.vw_sprMU_CEL cc ON
		m1.MES=cc.MU		  
where a.rf_idFiles=@idFile AND m.rf_idV025 IS NOT NULL AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMU_CEL ccc WHERE ccc.IsNextVisit=m.rf_idV025 AND ccc.MU=m1.MES)

SELECT DISTINCT c.id,414,m1.MUCode,m.rf_idV025
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
			 INNER JOIN dbo.t_Meduslugi m1 ON
		c.id=m1.rf_idCase            			
				INNER JOIN dbo.vw_sprMU_CEL cc ON
		m1.MUCode=cc.MU
where a.rf_idFiles=@idFile AND m.rf_idV025 IS NOT NULL AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMU_CEL ccc WHERE ccc.IsNextVisit=m.rf_idV025 AND ccc.MU=m1.MUCode)

SELECT * FROM dbo.vw_sprMU_CEL ccc WHERE MU='2.88.115'
--SELECT * FROM dbo.vw_sprMU_CEL ccc WHERE MU LIKE '2.78.10'
SELECT * FROM oms_nsi.dbo.sprV025

---обязательно должна присутствовать при амбулаторных условиях
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

