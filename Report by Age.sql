use AccountOMS
go
select 'Волгоградская область' as Region,		
		cast(sum(case when c.Age>=0 and c.Age<5 and p.rf_idV005=1 then c.AmountPayment else 0 end) as money) as [0-4M]
		,cast(sum(case when c.Age>=0 and c.Age<5 and p.rf_idV005=2 then c.AmountPayment else 0 end) as money) as [0-4W]
		---------------------------------------------------------------------------------------------------
		,cast(sum(case when c.Age>4 and c.Age<18 and p.rf_idV005=1 then c.AmountPayment else 0 end) as money) as [5-17M]
		,cast(sum(case when c.Age>4 and c.Age<18 and p.rf_idV005=2 then c.AmountPayment else 0 end) as money) as [5-17W]
		---------------------------------------------------------------------------------------------------
		,cast(sum(case when c.Age>17 and c.Age<60 and p.rf_idV005=1 then c.AmountPayment else 0 end) as money) as [18-59M]
		,cast(sum(case when c.Age>17 and c.Age<55 and p.rf_idV005=2 then c.AmountPayment else 0 end) as money) as [18-54W]
		---------------------------------------------------------------------------------------------------
		,cast(sum(case when c.Age>60 and p.rf_idV005=1 then c.AmountPayment else 0 end) as money) as [60M]
		,cast(sum(case when c.Age>55 and p.rf_idV005=2 then c.AmountPayment else 0 end) as money) as [55W]
from t_File f inner join t_RegistersAccounts a on
		f.id=a.rf_idFiles
		and f.DateRegistration>'20111201'
		and a.ReportYear=2011
		and a.ReportMonth=12
		and a.PrefixNumberRegister!='34'
			inner join t_RecordCasePatient r on
		a.id=r.rf_idRegistersAccounts
			inner join (select distinct rf_idRecordCase,rf_idV005 from t_RegisterPatient) p on
		r.id=p.rf_idRecordCase
			inner join t_Case c on
		r.id=c.rf_idRecordCasePatient			