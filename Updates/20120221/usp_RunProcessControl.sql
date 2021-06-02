USE [RegisterCases]
GO

/****** Object:  StoredProcedure [dbo].[usp_RunProcessControl]    Script Date: 02/21/2012 11:12:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_RunProcessControl]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_RunProcessControl]
GO

USE [RegisterCases]
GO

/****** Object:  StoredProcedure [dbo].[usp_RunProcessControl]    Script Date: 02/21/2012 11:12:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[usp_RunProcessControl]
			@CaseDefined TVP_CasePatient READONLY,		
			@idFile int
	
as
declare @tError as table(rf_idCase bigint,ErrorNumber smallint)
declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
	
	
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

--Проверка 1: на даты окончания лечений
insert @tError
select c1.rf_idCase,55
from (
	  select c1.rf_idCase 
	  from @CaseDefined  c1 left join @tError e on
					c1.rf_idCase=e.rf_idCase
	  where e.rf_idCase is null
     ) c1 inner join t_Case c2 on
		c1.rf_idCase=c2.id
where c2.DateEnd<@dateStart or c2.DateEnd>=@dateEnd
     
--Проверка 2: на даты оказания услуг
insert @tError
select c1.rf_idCase,55
from (
	  select c1.rf_idCase 
	  from @CaseDefined  c1 left join @tError e on
					c1.rf_idCase=e.rf_idCase
	  where e.rf_idCase is null
     ) c1 inner join (
						select c.id
						from @CaseDefined cd inner join t_Case c on
								cd.rf_idCase=c.id
										inner join t_Meduslugi m on
								c.id=m.rf_idCase 
						where c.DateBegin>m.DateHelpBegin or m.DateHelpBegin>m.DateHelpEnd or m.DateHelpEnd>c.DateEnd
						group by c.id
						) c2 on
		c1.rf_idCase=c2.id
where c2.id is null


--Проверка 3: проверка кодов из медуслуг и кодов МЕС на справочник Мед.услуг
insert @tError
select rf_idCase,64
from vw_sprMU vwC right join (
								select c1.rf_idCase,m.MUCode
								from (
									  select c1.rf_idCase 
									  from @CaseDefined  c1 left join @tError e on
												c1.rf_idCase=e.rf_idCase
									  where e.rf_idCase is null
									 ) c1 inner join t_Meduslugi m on
										c1.rf_idCase=m.rf_idCase																		
								) t on vwc.MU=t.MUCode
where vwC.MU is null
--------------------------------------------------
insert @tError
select rf_idCase,64
from vw_sprMUAll vwC right join (
									select c1.rf_idCase,mes.MES as MUCode
									from (
										  select c1.rf_idCase 
										  from @CaseDefined  c1 left join @tError e on
														c1.rf_idCase=e.rf_idCase
										  where e.rf_idCase is null
										 ) c1 inner join t_MES mes on
									c1.rf_idCase=mes.rf_idCase
								) t on vwc.MU=t.MUCode
where vwC.MU is null

--Проверка 4: проверка того что в таблице МЕС лежат только коды законченных случаев
insert @tError
select rf_idCase,53
from (
		select mes.rf_idCase,mes.MES as MUCode
		from (
			  select c1.rf_idCase 
			  from @CaseDefined  c1 left join @tError e on
							c1.rf_idCase=e.rf_idCase
			  where e.rf_idCase is null
		     ) c1
					inner join t_MES mes on
			c1.rf_idCase=mes.rf_idCase							
	  ) t left join dbo.vw_sprMUCompletedCase t1 on
			t.MUCode=t1.MU
where t1.MU is null

--Проверка 5: что в таблице медуслуг нету кодов законченых случаев
insert @tError
select rf_idCase,53
from (
		select m.rf_idCase,m.MUCode
		from (
			  select c1.rf_idCase 
			  from @CaseDefined  c1 left join @tError e on
							c1.rf_idCase=e.rf_idCase
			  where e.rf_idCase is null
		     ) c1
					inner join t_Meduslugi m on
			c1.rf_idCase=m.rf_idCase							
	  ) t inner join dbo.vw_sprMUCompletedCase t1 on
			t.MUCode=t1.MU
			
--Проверка 8: один случай - одна единица учета
insert @tError
select rf_idCase,53
from (
		select m.rf_idCase,t1.unitCode
		from (
			  select c1.rf_idCase 
			  from @CaseDefined  c1 left join @tError e on
						c1.rf_idCase=e.rf_idCase
			  where e.rf_idCase is null
			 ) c1
						inner join t_Meduslugi m on
				c1.rf_idCase=m.rf_idCase							
						inner join dbo.vw_sprMUCompletedCase t1 on
				m.MUCode=t1.MU	
		group by m.rf_idCase,t1.unitCode
	) t
 group by rf_idCase
 having COUNT(*)>1
--Проверка 6: количество законченных случаев должно быть равно 1
insert @tError
select mes.rf_idCase,53
from (
	  select c1.rf_idCase 
	  from @CaseDefined  c1 left join @tError e on
					c1.rf_idCase=e.rf_idCase
	  where e.rf_idCase is null
	 ) c1 inner join t_MES mes on
		c1.rf_idCase=mes.rf_idCase
where mes.Quantity<>1		

--Проверка 7: поиск дубликатов в поле ID_C
insert @tError
select c.id,71
from (
		  select c.GUID_Case
		  from t_Case c inner join @CaseDefined  c1 on
				c.id=c1.rf_idCase
						left join @tError e on
						c1.rf_idCase=e.rf_idCase
		  where e.rf_idCase is null
		  group by c.GUID_Case
		  having COUNT(*)>1
	  ) t inner join t_Case c on
	  t.GUID_Case=c.GUID_Case
		  inner join @CaseDefined  c1 on
				c.id=c1.rf_idCase
	
		
--Проверка 8: поиск дубликатов в поле ID_Case 30.12.2011
insert @tError
select c.id,71
from (
		  select c.idRecordCase
		  from t_Case c inner join @CaseDefined  c1 on
				c.id=c1.rf_idCase
						left join @tError e on
						c1.rf_idCase=e.rf_idCase
		  where e.rf_idCase is null
		  group by c.idRecordCase
		  having COUNT(*)>1
	  ) t inner join t_Case c on
	  t.idRecordCase=c.idRecordCase
		  inner join @CaseDefined  c1 on
				c.id=c1.rf_idCase
----------------------------------изменения от 06.01.2012----------------------------------------------------------------------
--Проверка 9: поиск Случаев без людей. сопоставление идет по ID_Pacient
insert @tError
select t.rf_idCase,59
from (
	  select c1.rf_idCase,c1.ID_Patient
	  from @CaseDefined  c1 left join @tError e on
					c1.rf_idCase=e.rf_idCase
	  where e.rf_idCase is null
	  ) t
where ID_Patient is null

--Проверка 10: поиск не корректных номеров полисов
insert @tError
select t.rf_idCase,59
from (
	  select c1.rf_idCase,c1.ID_Patient
	  from @CaseDefined  c1 left join @tError e on
					c1.rf_idCase=e.rf_idCase
	  where e.rf_idCase is null
	  ) t inner join t_Case c on
	  t.rf_idCase=c.id
			inner join t_RecordCase r on
		c.rf_idRecordCase=r.id
where r.rf_idF008=2 and r.NPolisLen>9

insert @tError 
select t.rf_idCase,59
from (
	  select c1.rf_idCase,c1.ID_Patient
	  from @CaseDefined  c1 left join @tError e on
					c1.rf_idCase=e.rf_idCase
	  where e.rf_idCase is null
	  ) t inner join t_Case c on
	  t.rf_idCase=c.id
			inner join t_RecordCase r on
		c.rf_idRecordCase=r.id
where r.rf_idF008=3 and r.NPolisLen>16

--Проверка 11:если новорожденный то поле NOVOR заполняется по шаблону ПДДММГГН
insert @tError 
select t.rf_idCase,59
from (
	  select c1.rf_idCase,c1.ID_Patient
	  from @CaseDefined  c1 left join @tError e on
					c1.rf_idCase=e.rf_idCase
	  where e.rf_idCase is null
	  ) t inner join t_Case c on
	  t.rf_idCase=c.id
			inner join t_RecordCase r on
		c.rf_idRecordCase=r.id
where r.IsChild=1 and LEN(r.NewBorn)<>9
--если не новорожденный то кроме
insert @tError 
select t.rf_idCase,59
from (
	  select c1.rf_idCase,c1.ID_Patient
	  from @CaseDefined  c1 left join @tError e on
					c1.rf_idCase=e.rf_idCase
	  where e.rf_idCase is null
	  ) t inner join t_Case c on
	  t.rf_idCase=c.id
			inner join t_RecordCase r on
		c.rf_idRecordCase=r.id
where r.IsChild=0 and r.NewBorn<>'0'		
---проверка пола
insert @tError 
select t.rf_idCase,59
from (
	  select c1.rf_idCase,c1.ID_Patient
	  from @CaseDefined  c1 left join @tError e on
					c1.rf_idCase=e.rf_idCase
	  where e.rf_idCase is null
	  ) t inner join t_Case c on
	  t.rf_idCase=c.id
			inner join t_RecordCase r on
		c.rf_idRecordCase=r.id
where r.IsChild=1 and left(r.NewBorn,1) not in ('1','2')

--insert @tError 
--select t.rf_idCase,59
--from (
--	  select c1.rf_idCase,c1.ID_Patient
--	  from @CaseDefined  c1 left join @tError e on
--					c1.rf_idCase=e.rf_idCase
--	  where e.rf_idCase is null
--	  ) t inner join t_Case c on
--	  t.rf_idCase=c.id
--			inner join t_RecordCase r on
--		c.rf_idRecordCase=r.id
--where r.IsChild=1 and left(r.NewBorn,1) not in ('1','2')

--Проверка 12: если NOVOR=0 то недолжно быть записей в t_RegisterPatientAttendant
insert @tError 
select t.rf_idCase,59
from (
	  select c1.rf_idCase,c1.ID_Patient
	  from @CaseDefined  c1 left join @tError e on
					c1.rf_idCase=e.rf_idCase
	  where e.rf_idCase is null
	  ) t inner join t_Case c on
	  t.rf_idCase=c.id
			inner join t_RecordCase r on
		c.rf_idRecordCase=r.id
			inner join vw_RegisterPatient p on
		r.id=p.rf_idRecordCase
			inner join t_RegisterPatientAttendant pa on
		p.id=pa.rf_idRegisterPatient
where r.IsChild=0 

--insert @tError 
--select t.rf_idCase,59
--from (
--	  select c1.rf_idCase,c1.ID_Patient
--	  from @CaseDefined  c1 left join @tError e on
--					c1.rf_idCase=e.rf_idCase
--	  where e.rf_idCase is null
--	  ) t inner join t_Case c on
--	  t.rf_idCase=c.id
--			inner join t_RecordCase r on
--		c.rf_idRecordCase=r.id
--			inner join vw_RegisterPatient p on
--		r.id=p.rf_idRecordCase
--		--	inner join t_RegisterPatientAttendant pa on
--		--p.id=pa.rf_idRegisterPatient
--where r.IsChild=1 and p.Fam<>'НЕТ'


--insert @tError 
--select t.rf_idCase,59
--from (
--	  select c1.rf_idCase,c1.ID_Patient
--	  from @CaseDefined  c1 left join @tError e on
--					c1.rf_idCase=e.rf_idCase
--	  where e.rf_idCase is null
--	  ) t inner join t_Case c on
--	  t.rf_idCase=c.id
--			inner join t_RecordCase r on
--		c.rf_idRecordCase=r.id
--			inner join vw_RegisterPatient p on
--		r.id=p.rf_idRecordCase		
--where r.IsChild=1 and p.Im<>'НЕТ'


--insert @tError 
--select t.rf_idCase,59
--from (
--	  select c1.rf_idCase,c1.ID_Patient
--	  from @CaseDefined  c1 left join @tError e on
--					c1.rf_idCase=e.rf_idCase
--	  where e.rf_idCase is null
--	  ) t inner join t_Case c on
--	  t.rf_idCase=c.id
--			inner join t_RecordCase r on
--		c.rf_idRecordCase=r.id
--			inner join vw_RegisterPatient p on
--		r.id=p.rf_idRecordCase
--		--	inner join t_RegisterPatientAttendant pa on
--		--p.id=pa.rf_idRegisterPatient
--where r.IsChild=1 and (p.Ot is not null)

/* данную проверку отключил т.к. требуется более тщательное тестирование
insert @tError 
select t.rf_idCase,59
from (
	  select c1.rf_idCase,c1.ID_Patient
	  from @CaseDefined  c1 left join @tError e on
					c1.rf_idCase=e.rf_idCase
	  where e.rf_idCase is null
	  ) t inner join t_Case c on
	  t.rf_idCase=c.id
			inner join t_RecordCase r on
		c.rf_idRecordCase=r.id
			inner join t_RegisterPatient p on
		r.id=p.rf_idRecordCase
			left join t_RegisterPatientAttendant pa on
		p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and pa.rf_idRegisterPatient is null
*/
----------------------------------изменения от 06.01.2012----------------------------------------------------------------------
----------------------------------изменения от 17.01.2012----------------------------------------------------------------------
--Проверка 13: поиск дубликатов ID_Pac
insert @tError
select c.rf_idCase,71
from ( select c1.rf_idCase,c1.ID_Patient
	   from @CaseDefined  c1 left join @tError e on
					c1.rf_idCase=e.rf_idCase
	   where e.rf_idCase is null
	  ) c inner join (
						select p.id,p.ID_Patient
						from (
								select ID_Patient  from t_RegisterPatient where rf_idFiles=@idFile
								group by ID_Patient having COUNT(*)>1 
							  ) t inner join t_RegisterPatient p on
							  t.ID_Patient=p.ID_Patient
							  and p.rf_idFiles=@idFile
						) c1 on
		c.ID_Patient=c1.id
order by c.rf_idCase
----------------------------------изменения от 17.01.2012----------------------------------------------------------------------

--Проверка N: проверка плана-заказа. Всегда должна быть последней
declare @t1 as table(rf_idCase bigint,Quantity decimal(11,2),unitCode int,TotalRest int)
------------------------------------------------------

insert @t1(rf_idCase,Quantity,unitCode)
select rf_idCase,cast(SUM(Quantity) as decimal(11,2)),unitCode
from (
		select top 1000000 m.rf_idCase,m.id
							,cast((case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as decimal(11,2)) as Quantity/*m.Quantity*/
							,t1.unitCode
		from (
			  select c1.rf_idCase 
			  from @CaseDefined  c1 left join @tError e on
							c1.rf_idCase=e.rf_idCase
			  where e.rf_idCase is null
		     ) c1
					inner join t_Meduslugi m on
			c1.rf_idCase=m.rf_idCase							
					inner join dbo.vw_sprMU t1 on
					m.MUCode=t1.MU	
		order by m.id	
		) t
group by rf_idCase,unitCode
--использую курсор т.к. на данный момент это проще всего, но его потом следует заменить
declare cPlan cursor for
	select f.UnitCode,f.Vdm,f.Vm,f.Spred
	from dbo.fn_PlanOrders(@codeLPU,@month,@year) f
	declare @unit int,@vdm decimal(11,2), @vm decimal(11,2), @spred decimal(11,2)
open cPlan
fetch next from cPlan into @unit,@vdm,@vm,@spred
while @@FETCH_STATUS = 0
begin		
	--select @unit,@vdm,@vm
	--update @t1 set @vm= Totalrest=@vm+@vdm-@spred-ISNULL(Quantity, 0) where unitCode=@unit
	declare cCase cursor for
		select t.rf_idCase,t.Quantity from @t1 t where unitCode=@unit
		declare @idCase bigint, @Quantity decimal(11,2)
	open cCase
	fetch next from cCase into @idCase,@Quantity
	while @@FETCH_STATUS=0
	begin			
		--select @idCase,@vm+@vdm-@Quantity-@spred
		update @t1 set TotalRest=@vm+@vdm-@Quantity-@spred where rf_idCase=@idCase
		set @spred=@spred+@Quantity
		
		fetch next from cCase into @idCase,@Quantity
	end
	close cCase
	deallocate cCase
	fetch next from cPlan into @unit,@vdm,@vm,@spred
end
close cPlan
deallocate cPlan

insert @tError
select rf_idCase,62 from @t1 where TotalRest<0

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

GO

