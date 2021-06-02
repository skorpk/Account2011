USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='103001' AND ReportYear=2020 AND NumberRegister=81


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


select DISTINCT c.id,407
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
where a.rf_idFiles=@idFile AND c.rf_idSubMO IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMOMP_OMP v WHERE c.rf_idMO=v.CodeM AND c.rf_idV006=ISNULL(v.UslOk,c.rf_idV006) 
				AND c.DateEnd>=ISNULL(v.PlaceDateB,c.DateEnd) AND c.DateEnd<=ISNULL(v.PlaceDateE,c.DateEnd) AND c.DateEnd>=ISNULL(v.DeptDateB,c.DateEnd)
				AND c.DateEnd<=ISNULL(v.DeptDateE,c.DateEnd) )

select DISTINCT c.id,407,c.rf_idSubMO, c.rf_idv006
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
		INNER JOIN 	vw_sprMOMP_OMP v ON
		c.rf_idMO=v.CodeM 
		AND c.rf_idV006=v.UslOk
		AND c.DateEnd>=v.PlaceDateB
		AND c.DateEnd<=v.PlaceDateE
		AND c.DateEnd>=v.DeptDateB
		AND c.DateEnd<=v.DeptDateE
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMOMP_OMP v WHERE c.rf_idMO=v.CodeM AND c.rf_idV006=ISNULL(v.UslOk,c.rf_idV006) 
				AND c.DateEnd>=ISNULL(v.PlaceDateB,c.DateEnd) AND c.DateEnd<=ISNULL(v.PlaceDateE,c.DateEnd) AND c.DateEnd>=ISNULL(v.DeptDateB,c.DateEnd)
				AND c.DateEnd<=ISNULL(v.DeptDateE,c.DateEnd) AND ISNULL(c.rf_idSubMO,'bla-bla')=ISNULL(v.LPU1,'bla-bla'))

SELECT * FROM vw_sprMOMP_OMP WHERE CodeM='103001' AND UslOk=1