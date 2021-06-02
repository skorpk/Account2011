USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT


select @idFile=id from vw_getIdFileNumber where CodeM='103001' and NumberRegister=105 and ReportYear=2021

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

SELECT c.id,307,d.rf_idV020
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200101'		
			INNER JOIN dbo.t_DrugTherapy0 d ON
		c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND rf_idV024 IN('sh9001','sh9002') AND rf_idV020 IN('000895','000903','001652','000764')
		AND NOT EXISTS(SELECT 1 FROM dbo.t_DrugTherapy0 d0 WHERE d0.rf_idCase=c.id AND d0.rf_idN013=d.rf_idN013 AND d0.rf_idV020 not IN('000895','000903','001652','000764'))
GROUP BY c.id,d.rf_idN013,d.rf_idV020,c.NumberHistoryCase


--SELECT * FROM t_DrugTherapy0 WHERE rf_idCase=125509701