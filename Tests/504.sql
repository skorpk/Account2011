USE RegisterCases
GO
DECLARE @idFile INT


select @idFile=id FROM dbo.vw_getIdFileNumber WHERE CodeM='151005' AND ReportYear=2018 AND NumberRegister=5
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6)
		
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod=rc.rf_idMO
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--������������� ���� ������ � ���� ��������� ��������� �������
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))


select distinct c.id,504,mu.Quantity,mu.CSGQuantity, DateHelpBegin, DateHelpEnd
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase							
						INNER JOIN dbo.t_Meduslugi mu ON
			c.id=mu.rf_idCase
			AND mu.MUCode='1.11.1'	
WHERE c.rf_idV010=33  AND mu.Quantity<>mu.CSGQuantity
--���������� �������� ������������ ������������� ���������� �� ������ ������: ����� ���������� ���� �������� � ����� 1.11.1, 
--�������������� � ������ ������,  ������ ����  ����� �������� ����� ����� ��������� ������� (DATE_2 � ��������� ���� SLUCH) 
--� ����� ������ ������� (DATE_1 � ��������� ���� SLUCH). ���� DATE_1=DATE_2, �� �������� ����������� ������ 1. 
SELECT c.id,504
FROM (
		select c.id,(CASE WHEN c.DateBegin=c.Dateend THEN 1 ELSE DATEDIFF(d,c.DateBegin,c.DateEnd) END) AS QuantityCase,SUM(mu.CSGQuantity) AS CSGQuantity
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 								
								inner join t_Case c on
					r.id=c.rf_idRecordCase									
								INNER JOIN dbo.t_Meduslugi mu ON
					c.id=mu.rf_idCase
					AND mu.MUCode='1.11.1'	
		WHERE c.rf_idV010=33
		GROUP BY c.id,(CASE WHEN c.DateBegin=c.Dateend THEN 1 ELSE DATEDIFF(d,c.DateBegin,c.DateEnd) END)
	) c
WHERE c.QuantityCase<>c.CSGQuantity
----23.01.2015 ��������� ����� ������ ������
/*
���������� �������� ������������ �������������� ���������� � ����������� ���������� ��������� ��������-���� ��� ������. 
�������� ���������� ������� �� ������ ������� ���������� ���� USL, � ������� ������������ �������� ������ �� ������� �� ������ 55.1.* 
���� � ��������� ���� USL  CODE_USL �� ������ 55.1.* , 
�� �������� � ���� KOL_USL ������ ���� �� ������ �������� ����� ����� ��������� �������� ������ (DATE_OUT) 
� ����� ������ �������� ������ (DATE_IN) ���� 1, ��� 1, ���� ���� ����� (DATE_IN=DATE_OUT). 
����� ���������� �������� �� ������ ��������� ����� USL, � ������� ������������ �������� � ���������� �� ������ 55.1.*, 
���������� �������� ������������ ������������� ���������� �� ������ ������: ����� ���������� ���� �������� �� ������ 55.1.*, 
�������������� � ������ ������,  ������ ����  �� ������ �������� ����� ����� ��������� ������� (DATE_2 � ��������� ���� SLUCH) 
� ����� ������ ������� (DATE_1 � ��������� ���� SLUCH) ���� 1. ���� DATE_1=DATE_2, �� �������� ����������� ������ 1
*/
select distinct c.id,504
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase							
						INNER JOIN dbo.t_Meduslugi mu ON
			c.id=mu.rf_idCase
			AND mu.MUCode LIKE '55.1.%'
WHERE c.rf_idV010=43  AND mu.Quantity>mu.PacientQuantity

SELECT c.id,504
FROM (
		select c.id
				,(CASE WHEN c.DateBegin=c.Dateend THEN 1 ELSE DATEDIFF(d,c.DateBegin,c.DateEnd)+1 END ) AS QuantityCase
				,SUM(mu.PacientQuantity) AS MUQuantity
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 								
								inner join t_Case c on
					r.id=c.rf_idRecordCase									
								INNER JOIN dbo.t_Meduslugi mu ON
					c.id=mu.rf_idCase
					AND mu.MUCode LIKE '55.1.%'
		WHERE c.rf_idV010=43
		GROUP BY c.id,(CASE WHEN c.DateBegin=c.Dateend THEN 1 ELSE DATEDIFF(d,c.DateBegin,c.DateEnd)+1 END ) 
	) c
WHERE c.QuantityCase<c.MUQuantity
/*
���� � �������� IDSP=32
���������� �������� ������������ �������������� ���������� � ����������� ���������� ��������� �����-���� ��� ������. 
�������� ���������� ������� �� ������ ������� ���������� ���� USL, � ������� ������������ �������� ������ �� ������� 1.11.*. 
���� � ��������� ���� USL  CODE_USL=1.11.* , �� �������� � ���� KOL_USL ������ ���� ����� �������� ����� ����� ��������� �������� ������ (DATE_OUT) � 
����� ������ �������� ������ (DATE_IN), ��� 1, ���� ���� ����� (DATE_IN=DATE_OUT). ����� ���������� �������� �� ������ ��������� ����� USL, 
� ������� ������������ �������� � ���������� � ����� 1.11.*, ���������� �������� ������������ ������������� ���������� �� ������ ������: 
����� ���������� ���� �������� � ����� 1.11.*, �������������� � ������ ������,  ������ ����  ����� �������� ����� ����� ��������� 
������� (DATE_2 � ��������� ���� SLUCH) � ����� ������ ������� (DATE_1 � ��������� ���� SLUCH). ���� DATE_1=DATE_2, �� �������� ����������� ������ 1. 
*/
select distinct c.id,504
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase							
						INNER JOIN dbo.t_Meduslugi mu ON
			c.id=mu.rf_idCase
			AND mu.MUCode LIKE '1.11.%'	
WHERE c.rf_idV010=32  AND mu.Quantity<>mu.CSGQuantity
--���������� �������� ������������ ������������� ���������� �� ������ ������: ����� ���������� ���� �������� � ����� 1.11.1, 
--�������������� � ������ ������,  ������ ����  ����� �������� ����� ����� ��������� ������� (DATE_2 � ��������� ���� SLUCH) 
--� ����� ������ ������� (DATE_1 � ��������� ���� SLUCH). ���� DATE_1=DATE_2, �� �������� ����������� ������ 1. 
SELECT c.id,504
FROM (
		select c.id,(CASE WHEN c.DateBegin=c.Dateend THEN 1 ELSE DATEDIFF(d,c.DateBegin,c.DateEnd) END) AS QuantityCase,SUM(mu.CSGQuantity) AS CSGQuantity
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 
								inner join t_PatientSMO s on
					r.id=s.ref_idRecordCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>=@dateStart AND c.DateEnd<@dateEnd								
								INNER JOIN dbo.t_Meduslugi mu ON
					c.id=mu.rf_idCase
					AND mu.MUCode LIKE '1.11.%'	
		WHERE c.rf_idV010=32
		GROUP BY c.id,(CASE WHEN c.DateBegin=c.Dateend THEN 1 ELSE DATEDIFF(d,c.DateBegin,c.DateEnd) END)
	) c
WHERE c.QuantityCase<>c.CSGQuantity