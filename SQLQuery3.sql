USE [AccountOMS]
GO
/****** Object:  StoredProcedure [dbo].[usp_ReportCompletedCase]    Script Date: 04/11/2012 13:44:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[usp_ReportCompletedCase]
			@dateBeg datetime,
			@dateEnd datetime,
			@codeFilial tinyint
as
set language Russian
CREATE TABLE #t
(
	id bigint,
	CodeM varchar(6) NULL,
	NameS varchar(250) NULL,
	rf_idSMO char(5) NULL,
	sNameS varchar(250) NULL,
	Account varchar(15) NULL,
	DateAccount char(10) NULL,
	DateRegistration varchar(21) NULL,
	ReportDate nvarchar(30) NULL,
	Summa decimal(11, 2) NULL,
	MES varchar(16) NULL,
	MUName varchar(255) NOT NULL,
	Quantity decimal(38, 2) NULL,
	Tariff decimal(15, 2) NULL,
	MUId bigint NOT NULL,
	DateEnd date NOT NULL,
	unitCode tinyint
)

insert #t
select distinct id,t.CodeM,t001.NameS,t.rf_idSMO,smo.sNameS,
		t.Account,t.DateAccount,t.DateRegistration,t.ReportDate,t.Summa,rtrim(t.MES),vw_MU.MUName,t.Quantity,t.Tariff,vw_MU.MUId,t.DateEnd,vw_MU.unitCode
from (
		select c.id,f.CodeM as CodeM,m.MES,a.rf_idSMO
				,a.Account
				,CONVERT(CHAR(10),a.DateRegister,104) as DateAccount
				,CONVERT(CHAR(10),f.DateRegistration,104)+' '+CONVERT(CHAR(10),f.DateRegistration,108) as DateRegistration
				,dbo.fn_MonthName(a.ReportYear,a.ReportMonth) as ReportDate
				,cast(a.AmountPayment as decimal(11,2)) as Summa
				,m.Quantity
				,m.Tariff
				,c.DateEnd
		from t_File f inner join t_RegistersAccounts a on
				f.id=a.rf_idFiles
						inner join t_RecordCasePatient r on
				a.id=r.rf_idRegistersAccounts
				and a.Letter in ('M','М')
						inner join t_Case c on
				r.id=c.rf_idRecordCasePatient
				--and c.DateEnd>=@dateBeg 
				and c.DateEnd<=@dateEnd
						inner join t_MES m with(INDEX(IX_MES_CASE)) on 
				c.id=m.rf_idCase				
		where f.DateRegistration>=@dateBeg and f.DateRegistration<=@dateEnd
		) t inner join vw_sprMUCompletedCase vw_MU on
		rtrim(t.MES)=rtrim(vw_MU.MU)
				inner join vw_sprT001 t001 on
		t.CodeM=t001.CodeM
				inner join vw_sprSMO smo on
		t.rf_idSMO=smo.smocod
where  t001.FilialId=@codeFilial

select t.CodeM
		,t.NameS
		,t.rf_idSMO
		,t.sNameS
		,t.Account
		,t.DateAccount
		,t.DateRegistration
		,t.ReportDate 
		,t.Summa 
		,t.MES 
		,t.MUName 
		,sum(t.Quantity) as Quantity
		,t.Tariff 
		,isnull(m.Price,0) as FF
		,isnull(SUM(t.Quantity*m.Price),0) as SumFF
		,u.unitName
		,case when m.rf_MUId is null then null else REPLACE(REPLACE(t.Account,'M','F'),'М','F') end as AccountFF
		----------------B-----------------------
		,isnull(mb.Price,0) as FB
		,isnull(SUM(t.Quantity*mb.Price),0) as SumBF
		,case when mb.rf_MUId is null then null else REPLACE(REPLACE(t.Account,'M','B'),'М','B') end as AccountBF
from #t t inner join dbo.vw_unitName u on
		t.unitCode=u.unitCode
			left join oms_NSI.dbo.sprMUPriceModernization m on
		m.rf_MUId=t.MUId 
		and t.DateEnd>=m.MUPriceDateBeg 
		and t.DateEnd<=m.MUPriceDateEnd
			left join oms_NSI.dbo.sprMUPriceAVO mb on
		t.MUId=mb.rf_MUId
		and t.DateEnd>=mb.MUPriceDateBeg 
		and t.DateEnd<=mb.MUPriceDateEnd
group by t.CodeM,t.NameS,t.rf_idSMO,t.sNameS,t.Account,t.DateAccount,t.DateRegistration,t.ReportDate,t.Summa,t.MES,t.MUName,t.Tariff,m.Price,u.unitName,m.rf_MUId,mb.Price,mb.rf_MUId

drop table #t
