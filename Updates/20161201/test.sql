USE RegisterCases
GO
declare @idFile INT,
		@idFileBack int

SELECT @idFile=f.id from vw_getIdFileNumber f WHERE CodeM='101004' AND ReportYear=2017 AND TypeFile='H' 
--SELECT @idFile
SELECT DISTINCT ErrorNumber FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile
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

declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

SELECT @idFileBack=id FROM dbo.t_FileBack WHERE rf_idFiles=@idFile
EXEC [dbo].[usp_RegisterSP_TK] @idFileBack 

