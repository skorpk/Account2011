USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='184512' AND ReportYear=2018 AND NumberRegister=3657


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

select DISTINCT c.id,528
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								
				INNER JOIN dbo.t_DispInfo d ON
		c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND d.TypeFailure NOT IN (0,1)


select DISTINCT c.id,528,d.TypeDisp
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								
				INNER JOIN dbo.t_DispInfo d ON
		c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND d.TypeFailure=1 AND d.TypeDisp NOT IN('ÄÂ1','ÄÂ3','ÎÍ1')