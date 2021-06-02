USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT	

select @idFile=id from vw_getIdFileNumber where CodeM='255315' and NumberRegister=229 and ReportYear=2020

select * from vw_getIdFileNumber where id=@idFile

declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6),
		@typeFile char(1)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO, @typeFile=UPPER(f.TypeFile)
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

--NOVOR
--Проверка 11:если новорожденный то поле NOVOR заполняется по шаблону ПДДММГГН

select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and LEN(r.NewBorn) NOT IN(8,9)
--	значение в теге DR файла Реестра пациентов должно соответствовать фасетте ДДММГГ в значении поля NOVOR,

select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
					 inner join t_RefRegisterPatientRecordCase rf on
					r.id=rf.rf_idRecordCase
						INNER JOIN dbo.t_RegisterPatient p ON
                    p.id = rf.rf_idRegisterPatient
				and p.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 AND SUBSTRING(r.NewBorn,2,6)<>RIGHT('0'+CAST(DAY(p.BirthDay) AS VARCHAR(2)),2)+RIGHT('0'+CAST(MONTH(p.BirthDay) AS VARCHAR(2)),2)+RIGHT(CAST(YEAR(p.BirthDay) AS VARCHAR(4)),2)


select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
					 inner join t_RefRegisterPatientRecordCase rf on
					r.id=rf.rf_idRecordCase
						INNER JOIN dbo.t_RegisterPatient p ON
                    p.id = rf.rf_idRegisterPatient
				and p.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 AND CAST(LEFT(r.NewBorn,1) AS tinyint) NOT IN(1,2)

--проверяем порядковый номер в поле NOVOR

SELECT c.id,538,r.NewBorn
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
					 inner join t_RefRegisterPatientRecordCase rf on
					r.id=rf.rf_idRecordCase
						INNER JOIN dbo.t_RegisterPatient p ON
                    p.id = rf.rf_idRegisterPatient
				and p.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and LEN(r.NewBorn)=9 AND RIGHT(r.NewBorn,2)  NOT IN('01','02','03','04','05','06')


select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
					 inner join t_RefRegisterPatientRecordCase rf on
					r.id=rf.rf_idRecordCase
						INNER JOIN dbo.t_RegisterPatient p ON
                    p.id = rf.rf_idRegisterPatient
				and p.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and LEN(r.NewBorn)=8 AND RIGHT(r.NewBorn,1)  NOT IN('1','2','3','4','5','6')

--если не новорожденный то кроме

select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=0 and r.NewBorn<>'0'		
---проверка пола

select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and left(r.NewBorn,1) not in ('1','2')

select DISTINCT c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						INNER JOIN dbo.t_RefRegisterPatientRecordCase rf ON
            r.id=rf.rf_idRecordCase
						inner join dbo.t_RegisterPatient p on
			rf.rf_idRegisterPatient=p.id
			and p.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase														
where r.IsChild=1 AND NOT EXISTS(SELECT 1 FROM dbo.t_RegisterPatientAttendant pa WHERE pa.rf_idRegisterPatient=p.id AND pa.rf_idV005 IS NOT null AND pa.BirthDay IS NOT NULL)

select c.id,538,'Ошибка'
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						INNER JOIN dbo.t_RefRegisterPatientRecordCase rf ON
            r.id=rf.rf_idRecordCase
						inner join dbo.t_RegisterPatient p on
			rf.rf_idRegisterPatient=p.id
			and p.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and (p.Fam IS NOT NULL or p.Im IS NOT NULL OR p.Ot IS NOT null)

--возраст пациента на дату начала лечения должен быть не меньше 0 и не больше 3 (возраст рассчитывается как количество полных лет между значением в поле DR(дата рождения) и DATE_Z_1(дата начала лечения))
--11.01.2019

select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and (c.Age<0 or c.Age>3)
--значение в теге DET как на уровне случая, так и на уровне медуслуг (если присутствуют) должно быть равно 1

select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and c.IsChildTariff=0


select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
where r.IsChild=1 and m.IsChildTariff=0
---Если поле NOVOR=0, то недолжно быть ни какой информации о сопровождающем лице

select c.id,538
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
where r.IsChild=0 AND EXISTS(SELECT * FROM t_RegisterPatientAttendant pa WHERE p.id=pa.rf_idRegisterPatient)

