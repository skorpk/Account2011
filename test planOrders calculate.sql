USE RegisterCases
go
declare @idFile int=null,
		@idFileBack int

select @idFile=rf_idFiles,@idFileBack=idFileBack
from vw_getFileBack where CodeM='471001' and ReportYear=2013 and NumberRegister=13030

declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@number varchar(15),
		@dateCreate datetime
--присваеваю параметрам данные из таблиц реестра СП и ТК
select @number=cast(rc.NumberRegister as varchar(13))+'-'+cast(rc.PropertyNumberRegister as CHAR(1))
		,@dateCreate=fb.DateCreate
		,@month=rc.ReportMonth
		,@year=rc.ReportYear
		,@codeLPU=fb.CodeM
from t_RegisterCaseBack rc inner join t_FileBack fb on
			rc.rf_idFilesBack=fb.id
where fb.id=@idFileBack

declare @plan1 TABLE(
						CodeLPU varchar(6),
						UnitCode int,
						Vm int,
						Vdm int,
						Spred decimal(11,2)
					)
--план заказов расчитывается по новому с 2012-02-24. В качестве отчетного месяца берем данные за квартал 
-------------------------------------------------------------------------------------
declare @monthMax tinyint,
		@monthMin tinyint
-------------------------------------------------------------------------------------
declare @t as table
(
		MonthID tinyint
		,QuarterID tinyint
		,partitionQuarterID tinyint
		,QuarterName as (case when QuarterID=1 then 'первый квартал'
								when QuarterID=2 then 'второй квартал' 
								when QuarterID=3 then 'третий квартал' else 'четвертый квартал' end)
)
insert @t values(1,1,1),(2,1,2),(3,1,3),
				(4,2,1),(5,2,2),(6,2,3),
				(7,3,1),(8,3,2),(9,3,3),
				(10,4,1),(11,4,2),(12,4,3)
				
select @monthMin=MIN(t1.MonthID),@monthMax=MAX(t1.MonthID)
from @t t inner join @t t1 on
		t.QuarterID=t1.QuarterID
where t.MonthID=@month				


declare @p as table(id int)
insert @p
SELECT distinct p.rf_idRecordCaseBack
FROM t_FileBack f INNER JOIN t_RegisterCaseBack r ON
			f.id=r.rf_idFilesBack		
			and f.CodeM=@codeLPU
				  INNER JOIN t_RecordCaseBack cb ON
	        cb.rf_idRegisterCaseBack=r.id AND
			r.ReportMonth>=@monthMin AND r.ReportMonth<=@monthMax AND
			r.ReportYear=@year
			inner join t_PatientBack p ON 
			cb.id=p.rf_idRecordCaseBack
			and p.rf_idSMO<>'00000'
						INNER JOIN vw_sprSMO s ON 
			p.rf_idSMO=s.smocod	

--берутся все случаи представленные в реестрах СП и ТК с типом оплаты 1 и если данный случай не является иногородним
select  c.rf_idMO						
		,t1.unitCode
		,cast(SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as money) as Quantity
		from t_FileBack f inner join t_RegisterCaseBack r on
				f.id=r.rf_idFilesBack		
				and f.DateCreate<=@dateCreate
						  inner join t_RecordCaseBack cb on
				cb.rf_idRegisterCaseBack=r.id and
				r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
				r.ReportYear=@year
				and cb.TypePay=1
						inner join t_Case c on
				c.id=cb.rf_idCase
						inner join t_Meduslugi m on
				c.id=m.rf_idCase and c.rf_idMO=@codeLPU
						left join dbo.vw_sprMU t1 on
				m.MUCode=t1.MU			
				and t1.unitCode is not null
						inner join @p p on
				cb.id=p.id											
group by c.rf_idMO,t1.unitCode

select distinct c.id,mes
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
		and f.id=@idFile
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
				inner join t_Case c on
		r.id=c.rf_idRecordCase
				inner join t_MES mes on
		c.id=mes.rf_idCase
				INNER JOIN vw_sprMUCompletedCase m1 ON
		mes.MES=m1.MU
		and m1.MUGroupCode<>2 AND m1.MUUnGroupCode<>78
				left join (select * 
							from t_Meduslugi m inner join vw_sprMU m1 on
									m.MUCode=m1.MU) m on
		c.id=m.rf_idCase
where m.id is null


go