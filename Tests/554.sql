USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='103001' and NumberRegister=1027 and ReportYear=2020

select * from vw_getIdFileNumber where id=@idFile
declare @month tinyint,
		@year smallint,
		@codeLPU char(6)

SELECT * FROM dbo.t_ErrorProcessControl WHERE rf_idCase=104882212
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--������������� ���� ������ � ���� ��������� ��������� �������
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	


select rf_idCase,554
from (
		select mes.rf_idCase,mes.MES as MUCode
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
							inner join t_Case c on
						r.id=c.rf_idRecordCase	
							inner join t_MES mes on
						c.id=mes.rf_idCase
		WHERE mes.IsCSGTag=1							
	  ) t 
where NOT EXISTS(SELECT * FROM vw_CompletedMUAndCSG WHERE MU=t.MUCode AND IsTypeCase=1)

--�������� 5: ��� � ������� �������� ���� ����� ���������� �������
--16.12.2013 ������� ���

select rf_idCase,554
from (
		select m.rf_idCase,m.MUCode
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
							inner join t_Case c on
					r.id=c.rf_idRecordCase
							inner join t_Meduslugi m on
					c.id=m.rf_idCase							
	  ) t inner join vw_CompletedMUAndCSG t1 on
			t.MUCode=t1.MU

			
--���� � ���� USL ��� ������������ ������ ������������ ������ �������� �� A16 
--04.01.2014 ��� �� ������������� ��������� � ������� t_Meduslugi

select c.id,554
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						INNER JOIN(VALUES(1),(2)) v(idV006) ON
				c.rf_idV006=v.idV006                      
						inner join t_MES mes on
				c.id=mes.rf_idCase		
							INNER JOIN t_Meduslugi m on									
				mes.rf_idCase=m.rf_idCase
				AND m.MUCode NOT IN (SELECT IDRB FROM OMS_NSI.dbo.V001)
WHERE NOT EXISTS(SELECT * FROM vw_CompletedMUAndCSG WHERE MU=mes.MES) 
--���� ��� ����������� ������  �� ������������� ����� �� ����������� ����������� ����� � �� ������� � ������ �������, �� ������ ������ 554
--2016-09-28 ������ �� ������� ������� c.IsSpecialCase NOT IN(3,4,23,24) � ����� ������� �� ������ ��������(������)

select distinct c.id,554,c.IsChild,m.rf_idV002,m.MUCode,c.rf_idV010
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
			AND c.IsCompletedCase=0	
						inner join dbo.t_Meduslugi m on
			c.id=m.rf_idCase	
						INNER JOIN dbo.vw_sprMU sm ON					
			m.MUCode=sm.MU
where m.Price>0 AND NOT EXISTS(SELECT * FROM dbo.vw_sprMuProfilPaymentByAge WHERE Age=c.IsChild AND ProfileCode=m.rf_idV002 AND MUCode=m.MUCode AND PaymentMethodCode=c.rf_idV010)

SELECT * FROM dbo.vw_sprMuProfilPaymentByAge WHERE MUCode='60.4.565'
SELECT * FROM dbo.vw_sprV002 WHERE id IN(76,78)
--SELECT * FROM dbo.vw_sprMuProfilPaymentByAge WHERE MUCode='2.80.10'

--SELECT * FROM dbo.vw_sprV010 WHERE id IN(41,29)
--SELECT * FROM dbo.vw_sprV002 WHERE id=90

--SELECT * FROM dbo.vw_sprV08 WHERE id=13
--2016-08-10
--���������� ����� �� �������������� ����������������� �����(���) ��������� ��������� ������ ��� ������������ ������� � ������������� ���������� � ���� PROFIL �� ������ ������
--08.11.2016 ����������, ��� ���� ����� ���������� ������.������������� � �������� �������

select distinct c.id,554,'Error'
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
						inner join dbo.t_Meduslugi m on
			c.id=m.rf_idCase				
						INNER JOIN OMS_NSI.dbo.sprDentalMU dm ON
			m.MUCode=dm.code
WHERE c.rf_idV006=3 AND c.rf_idV008>10 AND c.rf_idV008<14 AND c.rf_idV002 NOT IN(63,85,86,87,88,89,90,140,171) 
		
--������� � ��������� ������� ������ 2016, �� ������� � ���� USL ���� �� ����� ������ �� �������������� ����������������� �����
select distinct c.id,554,'error',c.rf_idV002,rf_idV008
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd						
WHERE  c.rf_idV006=3 AND c.rf_idV008>10 AND c.rf_idV008<14 AND c.DateEnd>='20160801' AND c.rf_idV002 IN(63,85,86,87,88,89,90,140,171) AND NOT EXISTS
   (SELECT * 
   FROM OMS_NSI.dbo.sprDentalMU dm inner join dbo.t_Meduslugi m on
			 m.MUCode=dm.code
   WHERE m.rf_idCase=c.id) 



   --SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=121690160
----------------------------------------------------------------

select distinct c.id,554,m.MUSurgery,c.GUID_Case,m.rf_idV002,m.rf_idV004,c.rf_idV006
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
						inner join dbo.t_Meduslugi m on
			c.id=m.rf_idCase				
						INNER JOIN OMS_NSI.dbo.sprDentalMU dm ON
			m.MUCode=dm.code
WHERE c.rf_idV006=3 AND c.rf_idV008>10 AND c.rf_idV008<14 AND c.rf_idV002 IN(63,85,86,87,88,89,90,140,171) 
		AND  NOT EXISTS(SELECT * FROM dbo.vw_sprDentalMUProfilConditionPRVS WHERE MUCode=m.MUSurgery AND rf_idV006=c.rf_idV006 AND rf_idV002=m.rf_idV002 AND rf_idV015=m.rf_idV004)

--��� USL_OK=4 ���������� ����� �� ��� �� ����������.

select distinct c.id,554
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
						inner join dbo.t_Meduslugi m on
			c.id=m.rf_idCase				
						INNER JOIN OMS_NSI.dbo.sprDentalMU dm ON
			m.MUCode=dm.code
WHERE c.rf_idV006=4
--���� USL_OK =1 ��� 2, �� ������ �� ��� ������ ���� � ����������� ����������� ����������� �����

select distinct c.id,554
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
						INNER JOIN (VALUES(1),(2)) v(idV006) ON
			c.rf_idV006=v.idV006                      
						inner join dbo.t_Meduslugi m on
			c.id=m.rf_idCase				
						INNER JOIN OMS_NSI.dbo.sprDentalMU dm ON
			m.MUCode=dm.code
WHERE NOT EXISTS(SELECT * FROM OMS_NSI.dbo.V001 WHERE IDRB=m.MUCode)
