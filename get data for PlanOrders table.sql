use oms_accounts
go
select left(cast(CodeLPU as CHAR(8)),6) as CodeLPU,YEAR(DateOfRegistration) as YearRate,MONTH(DateOfRegistration) as MonthRate
		,v.rf_planUnitID,SUM(Rate) as Rate
from (
		select a.CodeLPU,a.DateOfRegistrationOfAccount as DateOfRegistration,m.MUGroupCode,m.MUUnGroupCode,m.MUCode,sum(m.UET) as Rate
		from t_Accounts a inner join t_Cases c on
				a.id=c.rf_idAccounts
						inner join t_Meduslugi m on
				c.id=m.rf_idcases
		where a.DateOfRegistrationOfAccount>='20110101' and a.DateOfRegistrationOfAccount<='20111201'
		group by a.CodeLPU,a.DateOfRegistrationOfAccount,m.MUGroupCode,m.MUUnGroupCode,m.MUCode
	 ) t inner join [srvsql1-st2].oms_NSI.dbo.vw_sprMU v on
		t.MUGroupCode=v.MUGroupCode and
		t.MUUnGroupCode=v.MUUnGroupCode and
		t.MUCode=v.MUCode
where v.rf_planUnitID is not null
group by CodeLPU,DateOfRegistration,v.rf_planUnitID