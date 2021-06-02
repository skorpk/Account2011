USE RegisterCases
GO
DECLARE @idFile INT

SELECT @idFile=id FROM dbo.vw_getIdFileNumber WHERE ReportYear=2017  AND CodeM='125901' AND NumberRegister=2

SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile

create table #tError (rf_idCase bigint,ErrorNumber smallint)

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

EXEC dbo.usp_Test591 @idFile , @month , @year ,  @codeLPU 


go

DROP TABLE #tError


