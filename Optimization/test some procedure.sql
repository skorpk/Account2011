USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT,
		 @idFileBack int

select @idFile=id from vw_getIdFileNumber where ReportYear=2017 AND DateRegistration>'20170401' AND CountSluch>5000 ORDER BY NEWID()

SELECT  @idFileBack=idFileBack FROM dbo.vw_getFileBack WHERE rf_idFiles=@idFile

select * from vw_getIdFileNumber where id=@idFile
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
------------------------
create table #tError (rf_idCase bigint,ErrorNumber smallint)
------------------------
EXEC dbo.usp_Test518 @idFile, @month,@year,@codeLPU 
--EXEC dbo.usp_RegisterSP_TK @idFileBack 


-----------------------
GO
DROP TABLE #tError