use RegisterCases
go
if OBJECT_ID('usp_RunProcessControl2',N'P') is not null
	drop proc usp_RunProcessControl2
go			
create proc usp_RunProcessControl2
			@CaseDefined TVP_CasePatient READONLY,		
			@idFile int
	
as
---проверка для иногородних. здесь не проводится проверка на план заказа
declare @tError as table(rf_idCase bigint,ErrorNumber smallint)
declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
	from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			rc.rf_idMO=v.mcod		
	where f.id=@idFile
	
	
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

--Проверка 1: на даты окончания лечений
insert @tError
select c1.rf_idCase,55
from @CaseDefined c1 inner join t_Case c2 on
		c1.rf_idCase=c2.id
where c2.DateEnd<@dateStart or c2.DateEnd>=@dateEnd
     
--Проверка 2: на даты оказания услуг
insert @tError
select distinct c.id,55
from @CaseDefined cd inner join t_Case c on
			cd.rf_idCase=c.id
					inner join t_Meduslugi m on
			c.id=m.rf_idCase 
where c.DateBegin>m.DateHelpBegin or m.DateHelpBegin>m.DateHelpEnd or m.DateHelpEnd>c.DateEnd


--Проверка 3: проверка кодов из медуслуг и кодов МЕС на справочник Мед.услуг
insert @tError
select rf_idCase,64
from vw_sprMU vwC right join (
								select c1.rf_idCase,m.MUCode
								from @CaseDefined c1 inner join t_Meduslugi m on
										c1.rf_idCase=m.rf_idCase																		
								) t on vwc.MU=t.MUCode
where vwC.MU is null
--------------------------------------------------
insert @tError
select rf_idCase,64
from vw_sprMUAll vwC right join (
									select c1.rf_idCase,mes.MES as MUCode
									from @CaseDefined c1 inner join t_MES mes on
									c1.rf_idCase=mes.rf_idCase
								) t on vwc.MU=t.MUCode
where vwC.MU is null

--Проверка 4: проверка того что в таблице МЕС лежат только коды законченных случаев
insert @tError
select rf_idCase,53
from (
		select mes.rf_idCase,mes.MES as MUCode
		from @CaseDefined c1 inner join t_MES mes on
			c1.rf_idCase=mes.rf_idCase							
	  ) t left join dbo.vw_sprMUCompletedCase t1 on
			t.MUCode=t1.MU
where t1.MU is null

--Проверка 5: что в таблице медуслуг нету кодов законченых случаев
insert @tError
select rf_idCase,53
from (
		select m.rf_idCase,m.MUCode
		from @CaseDefined c1 inner join t_Meduslugi m on
			c1.rf_idCase=m.rf_idCase							
	  ) t inner join dbo.vw_sprMUCompletedCase t1 on
			t.MUCode=t1.MU
			
--Проверка 8: один случай - одна единица учета
insert @tError
select rf_idCase,53
from (
		select m.rf_idCase,t1.unitCode
		from @CaseDefined c1 inner join t_Meduslugi m on
				c1.rf_idCase=m.rf_idCase							
						inner join dbo.vw_sprMUCompletedCase t1 on
				m.MUCode=t1.MU	
		group by m.rf_idCase,t1.unitCode
	) t
 group by rf_idCase
 having COUNT(*)>1
		
--Проверка 7: количество законченных случаев должно быть равно 1
insert @tError
select mes.rf_idCase,53
from @CaseDefined  c1 inner join t_MES mes on
		c1.rf_idCase=mes.rf_idCase
where mes.Quantity<>1

begin transaction
begin try
	insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
	select ErrorNumber,@idFile,rf_idCase from @tError
end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
go
