USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f where CodeM='391001' and NumberRegister=6 and ReportYear=2020

SELECT * FROM dbo.vw_getFileBack WHERE rf_idFiles=@idFile

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

SELECT DISTINCT c.id,300,c.GUID_Case,r.idRecord
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200101'							 			
where a.rf_idFiles=@idFile AND f.TypeFile='F' AND c.rf_idV009 IN (323, 324,325,334,335,336,349,350,351,355,356,373,374)
	AND NOT EXISTS(SELECT 1 FROM dbo.t_Prescriptions p WHERE p.rf_idCase=c.id )--избыточно т.к. NAZ_R тег обязательный к заполнению