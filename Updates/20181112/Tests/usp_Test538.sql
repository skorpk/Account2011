USE [RegisterCases]
GO
ALTER PROC [dbo].[usp_Test538]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--NOVOR
--�������� 11:���� ������������� �� ���� NOVOR ����������� �� ������� ��������
insert #tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and LEN(r.NewBorn)<>9

--���� �� ������������� �� �����
insert #tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=0 and r.NewBorn<>'0'		
---�������� ����
insert #tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and left(r.NewBorn,1) not in ('1','2')

----�������� 12: ���� NOVOR=0 �� �������� ���� ������� � t_RegisterPatientAttendant. ��������.
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
--������� �������� �� ���� ������ ������� ������ ���� �� ������ 0 � �� ������ 3 (������� �������������� ��� ���������� ������ ��� ����� ��������� � ���� DR(���� ��������) � DATE_Z_1(���� ������ �������))
--11.01.2019
insert #tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and c.Age<0 and c.Age>3
--�������� � ���� DET ��� �� ������ ������, ��� � �� ������ �������� (���� ������������) ������ ���� ����� 1
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
---���� ���� NOVOR=0, �� �������� ���� �� ����� ���������� � �������������� ����
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

GO


