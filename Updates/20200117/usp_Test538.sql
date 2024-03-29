USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test538]    Script Date: 17.01.2020 10:25:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test538]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--NOVOR
--Проверка 11:если новорожденный то поле NOVOR заполняется по шаблону ПДДММГГН
insert #tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and LEN(r.NewBorn) NOT IN(8,9)
--	значение в теге DR файла Реестра пациентов должно соответствовать фасетте ДДММГГ в значении поля NOVOR,
INSERT #tError 
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

INSERT #tError
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
INSERT #tError
SELECT c.id,538
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

INSERT #tError
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
insert #tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=0 and r.NewBorn<>'0'		
---проверка пола
insert #tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and left(r.NewBorn,1) not in ('1','2')

----Проверка 12: если NOVOR=0 то недолжно быть записей в t_RegisterPatientAttendant. Изменена.
--insert #tError 
--select t.rf_idCase,538
--from (
--	  select c.id as rf_idCase, p.id as ID_Patient
--	  from t_RegistersCase a inner join t_RecordCase r on
--				a.id=r.rf_idRegistersCase
--				and a.rf_idFiles=@idFile
--							inner join vw_RegisterPatient p on
--				r.id=p.rf_idRecordCase
--				and p.rf_idFiles=@idFile
--							inner join t_Case c on
--				r.id=c.rf_idRecordCase								
--	  where r.IsChild=0 
--	  ) t inner join t_RegisterPatientAttendant pa on
--		t.ID_Patient=pa.rf_idRegisterPatient

insert #tError 
select DISTINCT c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join dbo.t_RegisterPatient p on
			r.id=p.rf_idRecordCase
			and p.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase														
where r.IsChild=0 AND NOT EXISTS(SELECT * FROM dbo.t_RegisterPatientAttendant pa WHERE pa.rf_idRegisterPatient=p.id AND pa.BirthDay IS NOT NULL)
--возраст пациента на дату начала лечения должен быть не меньше 0 и не больше 3 (возраст рассчитывается как количество полных лет между значением в поле DR(дата рождения) и DATE_Z_1(дата начала лечения))
--11.01.2019
insert #tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and c.Age<0 and c.Age>3
--значение в теге DET как на уровне случая, так и на уровне медуслуг (если присутствуют) должно быть равно 1
insert #tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and c.IsChildTariff=0

insert #tError 
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
insert #tError 
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

