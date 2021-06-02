USE RegisterCases
GO
DECLARE @idFile INT


select @idFile=id FROM dbo.vw_getIdFileNumber WHERE ReportYear=2016 AND DateRegistration>'20160425' AND CountSluch>1000
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6)
		
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod=rc.rf_idMO
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

select c.id,517
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>'20160430'
						INNER JOIN vw_CSLP_Coefficient co ON
			c.id=co.rf_idCase
WHERE c.IT_SL<>co.Sum_CSLP