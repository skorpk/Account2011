USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='165531' and NumberRegister=1649 and ReportYear=2014

select * from vw_getIdFileNumber where id=@idFile
declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

select c.id as rf_idCase, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
						inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase
						inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient								
where r.IsChild=0 

 
select c.id as rf_idCase,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=0 and p.Fam like '%[^-а-яА-Я"''. ]%'

 
select c.id as rf_idCase,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=0 and p.Fam IS NOT NULL AND  RTRIM(LTRIM(p.Fam)) like '[-"'']%'

--Проверка того что не запонено фамилия пациента при NOVOR=1
 
select c.id,578,r.IsChild,p.Fam,c.GUID_Case,r.NewBorn
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=1 and p.Fam!='НЕТ'
--IM
--Проверка того что не запонено имя сопровождающего при NOVOR=0
 
select c.id,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=0 and p.Im like '%[^-а-яА-Я"''. ]%'

 
select c.id as rf_idCase,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=0 and p.Im IS NOT NULL AND RTRIM(LTRIM(p.Im)) like '[-"'']%'
--Проверка того что не запонено имя пациента при NOVOR=1
 
select c.id,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=1 and p.Im!='НЕТ'
--OT
--Проверка того что не запонено отчество сопровождающего при NOVOR=0
 
select c.id,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=0 and p.Ot like '%[^-а-яА-Я"''. ]%'
--------проверка отчества.т.к отчество может не содержать кирилицу
 
select c.id as rf_idCase,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=0 and p.Ot IS NOT NULL AND RTRIM(LTRIM(p.Ot)) like '[-"'']%'

--Проверка того что не запонено отчество пациента при NOVOR=1
 
select c.id,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=1 and p.Ot!='НЕТ'
--Кроме того, в этом случае проверяется выполнение равенства OT=НЕТ, если равенство выполняется, 
--то проверяется наличие элемента OS_SLUCH  в соответствующей записи файла Реестра случаев. Причем  OS_SLUCH =2
 
select c.id,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=0 and p.Ot='НЕТ' and c.IsSpecialCase<>2
/*
Если в соответствующей записи случая оказания Реестра случаев NOVOR<>0, 
то проверяется обязательное заполнение этого элемента. 
Проверяется корректность представленного значения, а именно: 
в качестве символов могут быть использованы только буквы кириллицы, знаки: дефис, тире, двойные кавычки, апостроф и пробел. 
Причем FAM_P не может быть равным значению «НЕТ». Если NOVOR=0,  то элемент должен отсутствовать или быть пустым.
*/
 
select c.id, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_RefRegisterPatientRecordCase rp on
				r.id=rp.rf_idRecordCase
							inner join t_RegisterPatient p on
				rp.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile														
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and ISNULL(pa.Fam,'bla-bla') like '%[^-а-яА-Я"'' ]%'

-------появились пустые фамилии и фамилии начинающиеся с -'"
 
select c.id, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_RefRegisterPatientRecordCase rp on
				r.id=rp.rf_idRecordCase
							inner join t_RegisterPatient p on
				rp.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile														
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and pa.Fam IS NOT NULL AND  RTRIM(LTRIM(pa.Fam)) like '[-"'']%'

 
select c.id, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_RefRegisterPatientRecordCase rp on
				r.id=rp.rf_idRecordCase
							inner join t_RegisterPatient p on
				rp.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile														
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and UPPER(pa.Fam)='НЕТ'
/*
Если в соответствующей записи случая оказания Реестра случаев NOVOR<>0, 
то проверяется обязательное заполнение этого элемента. 
Проверяется корректность представленного значения, а именно: 
в качестве символов могут быть использованы только буквы кириллицы, знаки: дефис, тире, двойные кавычки, апостроф и пробел. 
Причем IM_P не может быть равным значению «НЕТ». 
Если NOVOR=0,  то элемент должен отсутствовать или быть пустым.
*/
 
select c.id, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_RefRegisterPatientRecordCase rp on
				r.id=rp.rf_idRecordCase
							inner join t_RegisterPatient p on
				rp.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile														
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and ISNULL(pa.Im,'bla-bla') like '%[^-а-яА-Я"'' ]%'

 
select c.id, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_RefRegisterPatientRecordCase rp on
				r.id=rp.rf_idRecordCase
							inner join t_RegisterPatient p on
				rp.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile														
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and UPPER(pa.Im)='НЕТ'

/*
Если в соответствующей записи случая оказания Реестра случаев NOVOR<>0, то проверяется обязательное заполнение этого элемента. 
Проверяется корректность представленного значения, а именно: в качестве символов могут быть использованы только буквы кириллицы,
знаки: дефис, тире, двойные кавычки, апостроф и пробел. Кроме того, в этом случае проверяется  выполнение равенства OT_P=НЕТ, 
если равенство выполняется, то проверяется наличие элемента OS_SLUCH  в соответствующей записи файла Реестра случаев. Причем  OS_SLUCH =2
*/
 
select c.id, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_RefRegisterPatientRecordCase rp on
				r.id=rp.rf_idRecordCase
							inner join t_RegisterPatient p on
				rp.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile														
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and pa.Ot='НЕТ' and c.IsSpecialCase<>2

 
select c.id, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_RefRegisterPatientRecordCase rp on
				r.id=rp.rf_idRecordCase
							inner join t_RegisterPatient p on
				rp.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile														
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=0 

 
select c.id, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_RefRegisterPatientRecordCase rp on
				r.id=rp.rf_idRecordCase
							inner join t_RegisterPatient p on
				rp.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile														
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and ISNULL(pa.Ot,'bla-bla') like '%[^-а-яА-Я"'' ]%'
--W
--Проводится проверка соответствия представленного значения классификатору V005

select distinct c.id,578
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join vw_RegisterPatient p on
			r.id=p.rf_idRecordCase
			and p.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where p.rf_idV005<1

select distinct c.id,578
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join vw_RegisterPatient p on
			r.id=p.rf_idRecordCase
			and p.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where p.rf_idV005>2
