use RegisterCases
go
select f.CodeM,l.NameS,spr.unitCode,u.unitName,COUNT(c.id) as CountCases
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
		and f.DateRegistration>'20120101'
		and f.DateRegistration<'20120711'		
			inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			inner join t_Case c on
		r.id=c.rf_idRecordCase
			inner join t_MES m on
		c.id=m.rf_idCase
			inner join (
						select top 10000 left(cast(lpu10.CodeMO as varchar(8)),6) as CodeMO,lpu10.unitCode,m10.Код
						from sprMU10UnitCode m10 inner join sprCodeMOUnitCode lpu10 on
									m10.unitCode=lpu10.unitCode
						order by CodeMO,unitCode
						) spr on
		f.CodeM=spr.CodeMO
		and m.MES=spr.Код
			inner join t_RecordCaseBack rb on
		c.id=rb.rf_idCase
			inner join t_PatientBack p on
		rb.id=p.rf_idRecordCaseBack
		and p.rf_idSMO in (select smocod from vw_sprSMO)		
			inner join OMS_NSI.dbo.tPlanUnit u on
		spr.unitCode=u.unitCode				
			inner join vw_sprT001 l on
		f.CodeM=l.CodeM
where a.ReportYear=2012	and a.ReportMonth>1	and a.ReportMonth<8	and rb.TypePay=1
group by f.CodeM,l.NameS,spr.unitCode,u.unitName
order by f.CodeM,spr.unitCode
------------------------------------------------------------------------------------------------------------------------
select f.CodeM,spr.unitCode,COUNT(c.id) as CountCases
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
		and f.DateRegistration>'20120101'
		and f.DateRegistration<'20120711'		
			inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			inner join t_Case c on
		r.id=c.rf_idRecordCase
			inner join t_MES m on
		c.id=m.rf_idCase
			inner join (
						select top 10000 left(cast(lpu10.CodeMO as varchar(8)),6) as CodeMO,lpu10.unitCode,m10.Код
						from sprMU10UnitCode m10 inner join sprCodeMOUnitCode lpu10 on
									m10.unitCode=lpu10.unitCode
						order by CodeMO,unitCode
						) spr on
		f.CodeM=spr.CodeMO
		and m.MES=spr.Код
			left join t_RecordCaseBack rb on
		c.id=rb.rf_idCase				
where a.ReportYear=2012	and a.ReportMonth>1	and a.ReportMonth<8	and rb.id is null
group by f.CodeM,spr.unitCode
order by f.CodeM,spr.unitCode
