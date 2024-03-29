USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test578]    Script Date: 13.01.2020 11:35:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test578]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--FAM
--Проверка того что не запонено фамилия сопровождающего при NOVOR=0
insert #tError 
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

insert #tError 
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
where p.Fam like '%[^-а-яА-Я"''. ]%'

insert #tError 
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
where p.Fam IS NOT NULL AND  RTRIM(LTRIM(p.Fam)) like '[-"'']%'
--------------------
insert #tError 
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
where r.IsChild=0 and p.Fam IS NULL AND NOT EXISTS(SELECT * FROM dbo.t_ReliabilityPatient WHERE rf_idRegisterPatient=p.id AND TypeReliability=2 AND IsAttendant=1)

insert #tError 
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
where p.Fam IS NOT NULL and p.Fam ='НЕТ' AND a.ReportYear>2016

--IM
--Проверка того что не запонено имя сопровождающего при NOVOR=0
insert #tError 
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
where p.IM IS NOT NULL and p.Im like '%[^-а-яА-Я"''. ]%'

insert #tError 
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
where p.Im IS NOT NULL AND RTRIM(LTRIM(p.Im)) like '[-"'']%'

insert #tError 
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
where r.IsChild=0 and p.Im IS NULL AND NOT EXISTS(SELECT * FROM dbo.t_ReliabilityPatient WHERE rf_idRegisterPatient=p.id AND TypeReliability=3 AND IsAttendant=1)

--OT
--Проверка того что не запонено отчество сопровождающего при NOVOR=0
insert #tError 
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
where p.Ot IS NOT null and p.Ot like '%[^-а-яА-Я"''. ]%'
--------проверка отчества.т.к отчество может не содержать кирилицу
insert #tError 
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
where p.Ot IS NOT NULL AND RTRIM(LTRIM(p.Ot)) like '[-"'']%'

insert #tError 
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
where r.IsChild=0 and p.Ot IS NULL AND NOT EXISTS(SELECT * FROM dbo.t_ReliabilityPatient WHERE rf_idRegisterPatient=p.id AND TypeReliability=1 AND IsAttendant=1)

/*
Если в соответствующей записи случая оказания Реестра случаев NOVOR<>0, 
то проверяется обязательное заполнение этого элемента. 
Проверяется корректность представленного значения, а именно: 
в качестве символов могут быть использованы только буквы кириллицы, знаки: дефис, тире, двойные кавычки, апостроф и пробел. 
Причем FAM_P не может быть равным значению «НЕТ». Если NOVOR=0,  то элемент должен отсутствовать или быть пустым.
*/
insert #tError 
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
where pa.Fam IS NOT NULL AND pa.Fam like '%[^-а-яА-Я"'' ]%'

-------появились пустые фамилии и фамилии начинающиеся с -'"
insert #tError 
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
where  pa.Fam IS NOT NULL AND  RTRIM(LTRIM(pa.Fam)) like '[-"'']%'

insert #tError 
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
where r.IsChild=0 and pa.Fam IS NOT NULL

insert #tError 
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
where r.IsChild<>0 and pa.Fam IS NULL AND NOT EXISTS(SELECT * FROM dbo.t_ReliabilityPatient WHERE rf_idRegisterPatient=p.id AND TypeReliability=2 AND IsAttendant=2)

/*
Если в соответствующей записи случая оказания Реестра случаев NOVOR<>0, 
то проверяется обязательное заполнение этого элемента. 
Проверяется корректность представленного значения, а именно: 
в качестве символов могут быть использованы только буквы кириллицы, знаки: дефис, тире, двойные кавычки, апостроф и пробел. 
Причем IM_P не может быть равным значению «НЕТ». 
Если NOVOR=0,  то элемент должен отсутствовать или быть пустым.
*/
insert #tError 
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
where r.IsChild<>0 and pa.Im IS NULL AND NOT EXISTS(SELECT * FROM dbo.t_ReliabilityPatient WHERE rf_idRegisterPatient=p.id AND TypeReliability=3 AND IsAttendant=2)

insert #tError 
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
WHERE pa.Im IS NOT NULL AND pa.Im like '%[^-а-яА-Я"'' ]%'

insert #tError 
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
where r.IsChild=0 and pa.Im IS NOT NULL

/*
Если в соответствующей записи случая оказания Реестра случаев NOVOR<>0, то проверяется обязательное заполнение этого элемента. 
Проверяется корректность представленного значения, а именно: в качестве символов могут быть использованы только буквы кириллицы,
знаки: дефис, тире, двойные кавычки, апостроф и пробел. Кроме того, в этом случае проверяется  выполнение равенства OT_P=НЕТ, 
если равенство выполняется, то проверяется наличие элемента OS_SLUCH  в соответствующей записи файла Реестра случаев. Причем  OS_SLUCH =2
*/

insert #tError 
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
where r.IsChild<>0 and pa.Ot IS NULL AND NOT EXISTS(SELECT * FROM dbo.t_ReliabilityPatient WHERE rf_idRegisterPatient=p.id AND TypeReliability=1 AND IsAttendant=2)

insert #tError 
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
where r.IsChild=0 and pa.Ot IS NOT NULL

insert #tError 
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

insert #tError 
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
where pa.Ot IS NOT NULL and pa.Ot like '%[^-а-яА-Я"'' ]%'
--W
--Проводится проверка соответствия представленного значения классификатору V005
insert #tError
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
insert #tError
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
--DR
insert #tError
select distinct c.id,579
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.Age<0

insert #tError
select distinct c.id,579
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.Age>115

insert #tError
select distinct c.id,579
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join vw_RegisterPatient p on
			r.id=p.rf_idRecordCase
			and p.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where p.BirthDay>=GETDATE() OR p.BirthDay<'19000101'

--FAM_P
insert #tError 
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
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and pa.Fam like '%[^-а-яА-Я"'' ]%' and pa.Fam<>'НЕТ'
--IM_P
insert #tError 
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
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and pa.Im like '%[^-а-яА-Я"'' ]%' and pa.Im<>'НЕТ'

--OT_P
insert #tError 
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
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and pa.Ot like '%[^-а-яА-Я"'' ]%' 
insert #tError 
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
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and pa.Ot='НЕТ' and c.IsSpecialCase<>2
--W_P
insert #tError 
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
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and pa.rf_idV005>2 and pa.rf_idV005<1
--Дата рождения у сопровождающего не может быть младше 14 лет
DECLARE @drMin DATE=DATEADD(YEAR,-14,GETDATE())
insert #tError 
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
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where pa.BirthDay>@drMin
