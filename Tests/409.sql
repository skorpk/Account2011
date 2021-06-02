USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='251001' AND ReportYear=2020 AND NumberRegister=125


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

select DISTINCT c.id,409,c.rf_idDepartmentMO,c.rf_idSubMO
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
where a.rf_idFiles=@idFile AND c.rf_idDepartmentMO IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMOMP_OMP v WHERE c.rf_idMO=v.CodeM 
																			AND ISNULL(c.rf_idDepartmentMO,0)=ISNULL(v.PODR,0)
																			AND ISNULL(c.rf_idSubMO,'bla-bla')=ISNULL(v.LPU1,'bla-bla')
																			)
SELECT * FROM dbo.vw_sprMOMP_OMP WHERE CodeM=@codeLPU 

select DISTINCT c.id,409
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
			INNER JOIN dbo.t_Meduslugi m ON 
		c.id=m.rf_idCase
where a.rf_idFiles=@idFile AND c.rf_idDepartmentMO IS NOT NULL AND m.rf_idDepartmentMO IS null
go

