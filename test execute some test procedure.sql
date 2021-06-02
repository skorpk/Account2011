USE RegisterCases
GO
DECLARE @idFile INT
SELECT @idFile=id FROM dbo.vw_getIdFileNumber WHERE ReportYear=2017 AND CountSluch>1000	ORDER BY NEWID()

declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6),
		@typeFile char(1)


create table #tError (rf_idCase bigint,ErrorNumber smallint)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO, @typeFile=UPPER(f.TypeFile)
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile


SET STATISTICS IO ON
SET STATISTICS TIME ON
	EXEC dbo.usp_Test50 @idFile, @month,@year ,@codeLPU 
SET STATISTICS IO OFF
SET STATISTICS TIME on
GO 
DROP TABLE #tError