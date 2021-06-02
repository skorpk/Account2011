USE RegisterCases
GO
DECLARE @idFile INT

select @idFile=id FROM dbo.vw_getIdFileNumber WHERE CodeM='331001' AND ReportYear=2014 AND NumberRegister=39
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
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))

SELECT e.rf_idCase,rb.* 
FROM dbo.t_ErrorProcessControl e INNER JOIN dbo.t_RecordCaseBack cb ON
			e.rf_idCase=cb.rf_idCase
					INNER JOIN dbo.t_RegisterCaseBack rb ON
			cb.rf_idRegisterCaseBack=rb.id
WHERE rf_idFile=@idFile AND ErrorNumber=589

IF EXISTS(SELECT * 
						  FROM dbo.vw_getIdFileNumber f INNER JOIN OMS_NSI.dbo.vw_sprT001 l ON
										f.CodeM=l.CodeM
						  WHERE f.id=@idFile AND l.pfs=1
						  )
				BEGIN		  
				---------------------------2012-12-20---------------------------------------
					
					select 589,@idFile,c.id,m.MUCode
					from  t_Case c inner join t_Meduslugi m on
									c.id=m.rf_idCase
									AND c.id=42837039
									and c.rf_idV006=4									
										left join vw_sprMUSplitByGroup mu on
									m.MUCode=mu.MU
									and mu.MUGroupCode=71
									and mu.MUUnGroupCode=2
					where mu.MUCode is null --group by c.id
END		
