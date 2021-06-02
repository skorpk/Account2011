USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='101201' AND ReportYear=2020 AND NumberRegister=29


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

--select DISTINCT c.id,404
--from t_File f INNER JOIN t_RegistersCase a ON
--		f.id=a.rf_idFiles
--		AND a.ReportMonth=@month
--		AND a.ReportYear=@year
--			  inner join t_RecordCase r on
--		a.id=r.rf_idRegistersCase
--			  inner join t_Case c on
--		r.id=c.rf_idRecordCase				
--			INNER JOIN (VALUES('101003'),('103001'), ('131001'), ('171004') ) v(CodeM) ON
--		f.CodeM=v.CodeM          
--where a.rf_idFiles=@idFile AND c.rf_idV006=1 AND LEN(ISNULL(c.rf_idDepartmentMO ,0))<>6	AND c.DateEnd>='20170801'

/*
поля LPU_1 и PODR должны быть одновременно заполнены или одновременно не заполнены
*/
select DISTINCT c.id,404
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
where a.rf_idFiles=@idFile AND LEN(ISNULL(c.rf_idDepartmentMO ,0))=0 AND LEN(ISNULL(c.rf_idSubMO ,0))>0 AND c.DateEnd>='20180101'

select DISTINCT c.id,404
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
where a.rf_idFiles=@idFile AND LEN(ISNULL(c.rf_idDepartmentMO ,0))>0 AND LEN(ISNULL(c.rf_idSubMO ,0))=0 AND c.DateEnd>='20180101'

select DISTINCT c.id,404,c.GUID_Case,c.rf_idMO,c.rf_idV006,c.DateEnd,c.rf_idDepartmentMO
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
			INNER JOIN vw_sprMOMP_OMP mo ON
		c.rf_idMO=mo.CodeM
		AND c.rf_idV006=mo.UslOk          
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMOMP_OMP v WHERE c.rf_idMO=v.CodeM AND c.rf_idV006=v.UslOk
				AND c.DateEnd>=ISNULL(v.PlaceDateB,c.DateEnd) AND c.DateEnd<=ISNULL(v.PlaceDateE,c.DateEnd) AND c.DateEnd>=ISNULL(v.DeptDateB,c.DateEnd)
				AND c.DateEnd<=ISNULL(v.DeptDateE,c.DateEnd) AND ISNULL(c.rf_idDepartmentMO,0)=ISNULL(v.PODR,0))

SELECT * FROM dbo.vw_sprMOMP_OMP WHERE CodeM=@CodeLPU
go

