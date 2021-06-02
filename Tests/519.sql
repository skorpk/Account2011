USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='145516' AND ReportYear=2021 AND NumberRegister=1612


SELECT ErrorNumber,COUNT(rf_idCase) AS CountCase FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber ORDER BY countCase desc
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

select f.CountSluch,COUNT(DISTINCT c.id) 
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
							inner join t_Case c on
			r.id=c.rf_idRecordCase
	where a.rf_idFiles=@idFile 
	GROUP BY f.CountSluch


IF(select f.CountSluch-COUNT(DISTINCT r.id) 
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
							inner join t_Case c on
			r.id=c.rf_idRecordCase
	where a.rf_idFiles=@idFile 
	GROUP BY f.CountSluch
	)!=0
BEGIN
	select DISTINCT c.id,519
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
							inner join t_Case c on
			r.id=c.rf_idRecordCase								
	where a.rf_idFiles=@idFile 
END