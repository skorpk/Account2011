use RegisterCases
go
--------------------------------------------------------------------------------------------------------------
if OBJECT_ID('usp_FillBackTablesAfterAllIteration',N'P') is not null
	drop proc usp_FillBackTablesAfterAllIteration
go			
--������ id ����� ������� �������� �� ������� ��������� ����������� ��������� ��������������
--������ ������������ ������ � ��� ������ ���� �� ���� ������� ����������� ������ � t_CasePatientDefineIteration
create proc usp_FillBackTablesAfterAllIteration
			@idFile int
as
declare @property tinyint=2

declare @fileName varchar(29),
		@idFileBack int,
		@idRegisterCaseBack int
declare @idRecordCaseBack as table(rf_idRecordCaseBack int,rf_idCase bigint)

--��� ������� �� � ��
select @fileName=dbo.fn_GetFileNameBack(@idFile)


declare @CaseDefined TVP_CasePatient,--�����
		@CaseDefined1 TVP_CasePatient,--��� �������
		@CaseDefined2 TVP_CasePatient --��� �����������

insert @CaseDefined(rf_idCase,ID_Patient)
select rf_idCase,rf_idRegisterPatient
from t_RefCasePatientDefine
where rf_idFiles=@idFile and (IsUnloadIntoSP_TK is null)
--�� �����������
insert @CaseDefined1(rf_idCase,ID_Patient)
select rf.rf_idCase,rf.rf_idRegisterPatient
from (
		select rf.rf_idCase,rf.rf_idRegisterPatient
		from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
					rf.id=c.rf_idRefCaseIteration
					and c.OKATO ='18000'		
								inner join t_CasePatientDefineIteration i on
					rf.id=i.rf_idRefCaseIteration
					and i.rf_idIteration in (2,4)			  
		where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
		union all
		select rf.rf_idCase,rf.rf_idRegisterPatient
		from t_RefCasePatientDefine rf inner join t_CasePatientDefineIteration i on
					rf.id=i.rf_idRefCaseIteration
					and i.rf_idIteration in (3)			  
		where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
		group by rf.rf_idCase,rf.rf_idRegisterPatient
	 ) rf

---�����������
--���� ���������� �������� ������� ����������� 05.02.2012
insert @CaseDefined2(rf_idCase,ID_Patient)
select rf.rf_idCase,rf.rf_idRegisterPatient
from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
			rf.id=c.rf_idRefCaseIteration
			and c.OKATO is not null
			and c.OKATO!='18000'									  
where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
--��������� ������� ��� ����������� �� ��� � ���� �� ���������� ��������� ��������������, �� ���� ����� �� ������������� �������
insert @CaseDefined2(rf_idCase,ID_Patient)
select rf.rf_idCase,rf.rf_idRegisterPatient
from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
			rf.id=c.rf_idRefCaseIteration
			and c.OGRN_SMO is null	
								inner join t_Case c1 on
			rf.rf_idCase=c1.id											  
								inner join t_RecordCase r on
			c1.rf_idRecordCase=r.id
								inner join t_PatientSMO p on
			r.id=p.ref_idRecordCase
			and p.OKATO!='18000' 
			and p.OKATO is not null
where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)

--������ �� ������� �� ���� ���������� ��������� �� ������������. ������ ������� � ������� ������ � ������� 57
--���� ���������� �������� ������� ����������� 05.02.2012 ��� �� ��� �� �������� � ������
insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
select 57,@idFile,c1.id
from @CaseDefined cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase
					  inner join t_CaseDefineZP1Found c on
			rf.id=c.rf_idRefCaseIteration
					  inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration
			and i.rf_idIteration =4 --������ 57 ����� ���� ���������� ������ �� 4 �����
						inner join t_Case c1 on
			cd.rf_idCase=c1.id
						inner join t_RecordCase rc on
			c1.rf_idRecordCase=rc.id
						inner join t_RegistersCase reg on
			rc.rf_idRegistersCase=reg.id
						left join @CaseDefined2 cd2 on
			cd.rf_idCase=cd.rf_idCase
			and cd.ID_Patient=cd2.ID_Patient					
where (c.OGRN_SMO is null) and (c.NPolcy is null) and (cd2.rf_idCase is null)
group by c1.id

--���������� ��������������� �������� ��� �������������� � ������������� �������
exec usp_RunProcessControl @CaseDefined1,@idFile

--���������� ��������������� �������� ��� �������������� � ������ �����������
exec usp_RunProcessControl2 @CaseDefined2,@idFile

begin transaction
begin try
	--�������� ������ �� ������� ��������, ������� ���� ������ � ������� �� � ��
	update t_RefCasePatientDefine
	set IsUnloadIntoSP_TK=1
	from t_RefCasePatientDefine rf inner join @CaseDefined cd on
				rf.rf_idCase=cd.rf_idCase and
				rf.rf_idRegisterPatient=cd.ID_Patient



 insert t_FileBack(rf_idFiles,FileNameHRBack) values(@idFile,@fileName)
 select @idFileBack=SCOPE_IDENTITY()
 
 insert t_RegisterCaseBack(rf_idFilesBack,ref_idF003,ReportYear,ReportMonth,DateCreate,NumberRegister,PropertyNumberRegister)
 select @idFileBack,c.rf_idMO,c.ReportYear,c.ReportMonth,GETDATE(),NumberRegister,@property
 from t_RegistersCase c
 where c.rf_idFiles=@idFile
 select @idRegisterCaseBack=SCOPE_IDENTITY()
 
 
 insert t_RecordCaseBack(rf_idRecordCase,rf_idRegisterCaseBack,rf_idCase)
	output inserted.id,inserted.rf_idCase into @idRecordCaseBack
 select c.rf_idRecordCase,@idRegisterCaseBack,c.id
 from @CaseDefined cd inner join t_Case c on
		cd.rf_idCase=c.id
		
--�.�. ����������� ��������� ����� ���� ��� � ������� t_CaseDefine ��� t_CaseDefineZP1Found		
--��������� �� 20.01.2012
insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
select rcb.rf_idRecordCaseBack,c.rf_idF008
		,case when c.rf_idF008=3 then null else c.SPolicy end as SPolicy
		,case when c.rf_idF008=3 then c.UniqueNumberPolicy else c.NPolcy end as NPolcy
		,c.SMO,18000
from @CaseDefined cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase
					  inner join t_CaseDefine c on
			rf.id=c.rf_idRefCaseIteration
					  inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration
			and i.rf_idIteration=3
						inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase
group by rcb.rf_idRecordCaseBack,c.rf_idF008,c.SPolicy,c.NPolcy,c.SMO,c.UniqueNumberPolicy
			
--��������� ������ �� ������� ���������� ��������� �������������� �� 2 � 4 ����.
--���� ������� ����������� �� �������� �� �������� �� ���������			
--��������� �� 03.01.2011------------------------------------------------------------------
declare @tPatient as table(
							rf_idRecordCaseBack int NOT NULL,
							rf_idF008 tinyint NOT NULL,
							SeriaPolis varchar(10) NULL,
							NumberPolis varchar(20) NOT NULL,
							SMO char(5) NOT NULL,
							OKATO char(5) NULL,
							Fam nvarchar(40) not null,
							Im nvarchar(40) not null,
							Ot nvarchar(40) null,
							rf_idV005 tinyint not null,
							BirthDay date not null,
							DateEnd date
						  )

--��������� �� 20.01.2012
insert @tPatient	
select rcb.rf_idRecordCaseBack,cast(c.TypePolicy as tinyint)
		,case when c.TypePolicy=3 then null else c.SPolicy end as SPolicy
		,case when c.TypePolicy=3 then c.UniqueNumberPolicy else c.NPolcy end as NPolcy
		,case when isnull(c.OKATO,'00000')='18000' then s.SMOKOD else '34' end,
		isnull(c.OKATO,'00000'),p.Fam,p.Im,p.Ot,p.rf_idV005,p.BirthDay,c1.DateEnd
from @CaseDefined cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase
					  inner join t_CaseDefineZP1Found c on
			rf.id=c.rf_idRefCaseIteration
					  inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration
			and i.rf_idIteration in (2,4)
					inner join t_Case c1 on
			cd.rf_idCase=c1.id
					 inner join vw_RegisterPatient p on
			cd.ID_Patient=p.id
						inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase
						left join dbo.vw_sprSMOGlobal s on
			c.OGRN_SMO=s.OGRN
			and c.OKATO=s.OKATO
where (OGRN_SMO is not null) and (NPolcy is not null)
-----------------------------------------------03.01.2012-----------------------------------------------
insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
select t.rf_idRecordCaseBack,t.rf_idF008,t.SeriaPolis,t.NumberPolis,t.SMO,t.OKATO
from (
		select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO
		from @tPatient p
		where p.SMO='34'
		union all
		select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO
		from @tPatient p left join vw_sprSMODisable s on
							p.SMO=s.SMO
		where p.OKATO='18000' and s.id is null
		union all
		select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO
		from @tPatient p inner join vw_sprSMODisable s on
							p.SMO=s.SMO					
		where p.OKATO='18000' and p.DateEnd<s.DateEnd
		union all
		select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,'00','00000'
		from @tPatient p inner join vw_sprSMODisable s on
							p.SMO=s.SMO					
		where p.OKATO='18000' and p.DateEnd>=s.DateEnd
		union all
		select distinct p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,lp.Q as SMO,p.OKATO
		from @tPatient p inner join vw_sprSMODisable s on
							p.SMO=s.SMO
							--and p.OKATO='18000'
									 inner join PolicyRegister.dbo.ListPeopleFromPlotnikov lp on
							upper(p.Fam)=upper(lp.FAM)
							and upper(p.Im)=upper(lp.IM)
							and ISNULL(upper(p.Ot),'bla-bla')=ISNULL(upper(lp.OT),'bla-bla')
							and p.BirthDay=lp.DR
		where p.OKATO='18000' and p.DateEnd>=s.DateEnd
	) t
group by t.rf_idRecordCaseBack,t.rf_idF008,t.SeriaPolis,t.NumberPolis,t.SMO,t.OKATO
-----------------------------------------------27.01.2012-----------------------------------------------
--����������� ������� �������������� ����� ������� ���������� ������� �� ����������� � ����������� ���.
--������ ������� � ������� ������ � ������� 57
insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
select 57,@idFile,r.rf_idCase
from @tPatient p inner join t_RecordCaseBack r on
					  p.rf_idRecordCaseBack=r.id
					inner join vw_sprSMODisable s on
							p.SMO=s.SMO					
where p.OKATO='18000' and p.DateEnd>=s.DateEnd

--��������� ������ � t_PatientBack  ��� ����������� �� ��� � ���� �� ���������� ��������� ��������������, �� ���� ����� �� ������������� �������
insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
select rcb.rf_idRecordCaseBack,rc.rf_idF008,rc.SeriaPolis,rc.NumberPolis,34,p.OKATO
from @CaseDefined cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase
					  inner join t_CaseDefineZP1Found c on
			rf.id=c.rf_idRefCaseIteration
					  inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration
			and i.rf_idIteration in (2,4)
						inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase	
						inner join t_Case c1 on
			cd.rf_idCase=c1.id
						inner join t_RecordCase rc on
			c1.rf_idRecordCase=rc.id										
						inner join t_PatientSMO p on
			rc.id=p.ref_idRecordCase
			and p.OKATO!='18000' 
			and p.OKATO is not null
where (OGRN_SMO is null) and (NPolcy is null)		


insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
select rcb.rf_idRecordCaseBack,rc.rf_idF008,rc.SeriaPolis,rc.NumberPolis,isnull(reg.rf_idSMO,'00'),'00000'
from @CaseDefined cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase
					  inner join t_CaseDefineZP1Found c on
			rf.id=c.rf_idRefCaseIteration
					  inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration
			and i.rf_idIteration in (2,4)
						inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase	
						inner join t_Case c1 on
			cd.rf_idCase=c1.id
						inner join t_RecordCase rc on
			c1.rf_idRecordCase=rc.id
						inner join t_RegistersCase reg on
			rc.rf_idRegistersCase=reg.id		
						left join @CaseDefined2 cd2 on
			cd.rf_idCase=cd.rf_idCase
			and cd.ID_Patient=cd2.ID_Patient			
where (OGRN_SMO is null) and (NPolcy is null)  and (cd2.rf_idCase is null)			
			
-------------------------------------------------------------------------------------------------------
 insert t_CaseBack(rf_idRecordCaseBack,TypePay)		
 select rcb.rf_idRecordCaseBack,(case when e.ErrorNumber is null then 1 else 2 end) as TypePay
 from @CaseDefined cd inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase
					  left join t_ErrorProcessControl e on
			cd.rf_idCase=e.rf_idCase and
			e.rf_idFile=@idFile
group by rcb.rf_idRecordCaseBack,(case when e.ErrorNumber is null then 1 else 2 end)
			
--------------------------------������ ��� ������ �� ����� �������---------------------------------------------
	declare @month tinyint,
			@year smallint,
			@codeLPU char(6)		
	if @idFileBack is not null		
	begin		
		select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
		from t_FileBack f inner join t_RegisterCaseBack rc on
					f.id=rc.rf_idFilesBack
							inner join oms_nsi.dbo.vw_sprT001 v on
					f.CodeM=v.CodeM		
		where f.id=@idFileBack
		
		insert t_PlanOrdersReport(rf_idFile,rf_idFileBack,CodeLPU,UnitCode,Vm,Vdm,Spred,MonthReport,YearReport)
		select @idFile,@idFileBack,f.CodeLPU,f.UnitCode,f.Vm,f.Vdm,f.Spred,@month,@year
		from dbo.fn_PlanOrders(@codeLPU,@month,@year) f
	end
	------------------------------------------------------------------------------------------------------------------			
			
end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
go