USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='151005' AND ReportYear=2018 AND NumberRegister=28500


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

SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile

SELECT DISTINCT c.id,416,m.MES , c.GUID_Case
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
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND f.TypeFile='H' AND pp.rf_idV025='1.3' AND EXISTS(SELECT 1 FROM dbo.t_PurposeOfVisit WHERE rf_idCase=c.id AND ISNULL(DN,9)>6 AND ISNULL(DN,9)<1)

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
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND f.TypeFile='H' AND m.Price>0 AND pp.rf_idV025='1.3' AND EXISTS(SELECT 1 FROM dbo.t_PurposeOfVisit WHERE rf_idCase=c.id AND ISNULL(DN,9)>6 AND ISNULL(DN,9)<1 )

SELECT * FROM dbo.vw_sprMU_CEL WHERE MU='2.88.52'

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

SELECT DISTINCT c.id,416,p.*, c.IsCompletedCase
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
				           
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND f.TypeFile='H' AND c.IsCompletedCase=0 AND p.DN IS NOT NULL AND NOT EXISTS(SELECT 1 
																									FROM dbo.vw_sprMU_CEL cc INNER JOIN dbo.t_Meduslugi m ON 
																													cc.mu=m.MUCode
																								    WHERE m.rf_idCase=c.id AND cc.IsNextVisit='1.3' AND m.Price>0
																									)
