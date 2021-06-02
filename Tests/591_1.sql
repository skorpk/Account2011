USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT,
	@month TINYINT=1,
	@year SMALLINT=2019,
	@codeLPU VARCHAR(6)

select @idFile=id, @month=ReportMonth, @year=ReportYear from vw_getIdFileNumber where CodeM='151005' and NumberRegister=263 and ReportYear=2019

select * from vw_getIdFileNumber where id=@idFile

select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--������������� ���� ������ � ���� ��������� ��������� �������
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72										
										) mc on
				mes.MES=mc.MU
							left join t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
where m.id is NULL
--��� ������������ ������� � ����� �� �� ����� 70.*, 72.* ����� ���� ������������ ������ �� ������  �� ������ 2.3,
--�� ���� �� ���� �� ����� ������ ���� �� ������ 2.3.*,
-- �� �� ����� ���� ������������ ������ �� ������ 2.60.*

select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72										
										) mc on
				mes.MES=mc.MU
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
where m.MUCode LIKE '2.60.%'

--�������� ���������� (��� ������� � ��������� ����� ��� ���� ���, ������� ����� �������������� � N_KSG) ���������� �������� �� ������������ ������� ���� USL
--04.01.2019

select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
WHERE c.rf_idV006=2 AND mes.IsCSGTag=2 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=c.id)


select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase													
							INNER JOIN t_Meduslugi m on
				c.id=m.rf_idCase				 				
where m.MUCode LIKE '2.60.%' AND c.rf_idV006=3	AND EXISTS(SELECT * FROM dbo.t_MES WHERE MES NOT LIKE '2.78.%' AND rf_idcase=c.id)
--��������� ���� �� ������ �� ����� 2.3.*
--���������� ����� �������� 01.02.2014
--������� �������� 17.10.2014

select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72										
										) mc on
				mes.MES=mc.MU			
where NOT EXISTS (SELECT DISTINCT rf_idCase from t_Meduslugi m1 WHERE m1.MUCode LIKE '2.3.%' AND m1.rf_idCase=c.id)


--------------------------------------------------09/04/2013--------------------------------------------------
-------�������� �� ������� �������� 2.3.* ��� ��=2.78.* 
-------c 2014 ����� ���� ������ ������ 2.60.*

select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				AND a.ReportYear<2014
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78																	
										) mc on
				mes.MES=mc.MU
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase							
WHERE m.MUCode NOT LIKE '2.3.%'


select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				AND a.ReportYear>2013 AND a.ReportYear<2016
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78																	
										) mc on
				mes.MES=mc.MU
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
WHERE m.MUCode NOT LIKE '2.60.%'
 --Since 2016-0-18 We can use 57.* with 2.78.*
--��� ��� � �� �� ������ 2.78.* �� �������� ������ 2016 � ����� � ��� ������ ����� 2.60 ��� ������ ����� 57.*,  
 --��� ������ ��������� �� �������������� ����������������� �����

select c.id,591,8
from t_RegistersCase a inner join t_RecordCase r on
    a.id=r.rf_idRegistersCase
    and a.rf_idFiles=@idFile
    AND a.ReportYear>2015
      inner join t_Case c on
    r.id=c.rf_idRecordCase 
      inner join t_MES mes on
    c.id=mes.rf_idCase       
    AND mes.MES LIKE '2.78.%'
       INNER JOIN t_Meduslugi m on
    mes.rf_idCase=m.rf_idCase
WHERE NOT EXISTS(SELECT * FROM vw_DentalMU WHERE MU=m.MUCode UNION ALL SELECT MU FROM dbo.vw_sprMU WHERE MUGroupCode=4)

 

select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				AND a.ReportYear>2015
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
				AND mes.MES LIKE '2.78.%'
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
WHERE m.MUCode LIKE '57.%' AND EXISTS(SELECT MUCode FROM dbo.t_Meduslugi m1 WHERE m1.MUCode NOT LIKE '57.%' AND m1.rf_idCase=c.id)
---��������---------------------------

CREATE TABLE #tMU(MU VARCHAR(20))
INSERT #tMU( MU )
SELECT MU
FROM dbo.vw_sprMU_20170801 WHERE MUGroupCode=2 AND MUUnGroupCode=60
UNION ALL
SELECT MU
FROM dbo.vw_sprMU_20170801 WHERE MUGroupCode=4
UNION ALL 
SELECT DISTINCT code FROM OMS_NSI.dbo.sprDentalMU 

CREATE UNIQUE NONCLUSTERED INDEX TMP_MU ON #tMU(MU)


select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				AND a.ReportYear>2015
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
				AND mes.MES LIKE '2.78.%'
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
WHERE c.rf_idV006=3 AND m.MUCode LIKE '2.60.%' AND c.DateEnd<'20170801'  AND EXISTS(SELECT MUCode FROM dbo.t_Meduslugi m1 WHERE m1.MUCode NOT LIKE '2.60.%' AND m1.rf_idCase=c.id)


select c.id,591	,11	,m.MUCode,mes.MES
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				AND a.ReportYear>2015
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
						INNER JOIN dbo.vw_sprMU_20170801 sm ON
				mes.MES=sm.MU                      
						INNER JOIN dbo.t_Meduslugi m ON
				mes.rf_idCase=m.rf_idCase							
WHERE sm.MUGroupCode=2 AND MUUnGroupCode=78 and c.DateEnd>'20170831' and c.rf_idV006=3 AND NOT EXISTS(SELECT 1 FROM #tMU WHERE MU=m.MUCode)
		AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprDentalMU WHERE code=m.MUSurgery)

SELECT * FROM oms_nsi.dbo.sprDentalMU WHERE code='B01.003.004'

SELECT * FROM oms_nsi.dbo.V001 WHERE IDRB='B01.003.004'
																																			 
DROP TABLE #tMU
---��������---------------------------

select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				AND a.ReportYear>2015
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
				AND mes.MES LIKE '2.78.%'
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
							INNER JOIN OMS_NSI.dbo.sprDentalMU d ON
														m.MUCode=d.code
WHERE EXISTS(SELECT MUCode FROM dbo.t_Meduslugi m1 WHERE m1.rf_idCase=c.id AND NOT EXISTS(SELECT 1 FROM OMS_NSI.dbo.sprDentalMU d where m1.MUCode=d.code) )
--------

-----���� ������������ ������ �� ������ 2.3.*, 2.60.*  � �� ������ ������ ����������� ��� ������������ ������ �� ��������������� �������� �������� 
----� 13.05.2015 ������ 2.3.* ��� ��. ���� ���������, ���� ���� ������ 2.90.* �� ����� ���� � 2.3.*

SELECT DISTINCT c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase				
							INNER JOIN t_Meduslugi m on
				c.id=m.rf_idCase
							INNER JOIN vw_sprMU mu ON
				m.MUCode=mu.MU
									LEFT JOIN t_MES mes ON 
							c.id=mes.rf_idCase
WHERE mu.MUGroupCode=2 AND mu.MUUnGroupCode=60 /*IN (3,60)*/ AND mes.rf_idCase IS NULL	--AND c.rf_idV006=3
UNION ALL 
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase				
							INNER JOIN t_Meduslugi m on
				c.id=m.rf_idCase
							INNER JOIN vw_sprMU mu ON
				m.MUCode=mu.MU
									LEFT JOIN t_MES mes ON 
							c.id=mes.rf_idCase
WHERE mu.MUGroupCode=2 AND mu.MUUnGroupCode=60 /*IN (3,60)*/  AND mes.rf_idCase IS NULL	AND c.rf_idV006<>3

---11.04.2017 ������ 2.90.* �� ����� ���� ��� 2.3.*
--������ �������� ���� �� ��������

select c.id,591
FROM t_File f INNER join t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND f.id=@idFile
			  inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				
						inner join t_Case c on
				r.id=c.rf_idRecordCase				
							INNER JOIN t_Meduslugi m on
				c.id=m.rf_idCase
WHERE m.MUCode LIKE '2.90.%' and NOT EXISTS(SELECT * FROM dbo.t_Meduslugi t where t.rf_idCase=m.rf_idCase AND t.MUCode LIKE '2.3.%')
---��� ������� ���������� ����������� ������ ���� ������ �� 55.1.*  � c 2019 ���� ����� ���� ������������ ������ �� ������ 60.3.* � ����� �������������� ������ �� V001

select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase				
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
WHERE c.DateEnd>='20130401' AND c.rf_idV006=2 AND NOT EXISTS(SELECT * FROM dbo.vw_sprMUUnionV001 WHERE MU=m.MUCode)

--��� ������� ���� �� 6 ������� ��� ����� �������, �� �������� ��� �� �����������

select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase																	
						INNER JOIN dbo.t_MES mm ON
				c.id=mm.rf_idCase                      
WHERE c.DateEnd>='20130401' AND mm.mes not LIKE '_____9__' AND c.rf_idV006=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi WHERE rf_idCase=c.id AND MUCode LIKE '55.1.%')
-------���� ������������ ������ �� ������ 55.1.*, � �� ������ ������ ����������� ��� ������������ ������ �� ��������������� �������� �������� 

select c.id,591,6
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase							
							INNER JOIN t_Meduslugi m on
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_sprMUUnionV001 v ON
				m.MUCode=v.MU							
WHERE c.rf_idV006=2 and c.DateEnd>='20130401' AND c.rf_idV010<>4 AND NOT EXISTS(SELECT * FROM t_MES mes WHERE rf_idCase=c.id)
--------------------------------����� �������� �� 23.01.2015------------------

--��� ������������ ������ ��� USL ������ ���� ��������. � ��� ������ ����������� ����

select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase			
WHERE c.rf_idV006=1 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=c.id)

-- � 1.11.1 ����������� ������ 1.11.2 � 2015 ����

select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join (SELECT rf_idRecordCase,id,rf_idV010 from t_Case WHERE rf_idV010<>32 AND rf_idV002!=158 AND DateEnd>=@dateStart AND DateEnd<@dateEnd) c on
			r.id=c.rf_idRecordCase	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						INNER JOIN (VALUES('1.11.1'),('1.11.2') ) v(MU) ON
			m.MUCode=v.mu			
WHERE  c.rf_idV010<>33
--23.01.2015

select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 			
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
WHERE m.MUCode='1.11.2' AND c.rf_idV010 NOT IN(32,33) AND c.rf_idV002<>158



select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV010=32 AND c.rf_idV002=58 AND EXISTS(SELECT * FROM dbo.t_Meduslugi m LEFT JOIN oms_nsi.dbo.V001 v ON m.MUCode=v.IDRB
																	  WHERE v.IDRB IS null AND m.rf_idCase=c.id AND MUCode<>'1.11.2')
-------------------------20.09.2016------------------------------------
--����� �������������� (����� �� ������������ ) ������ �� ������������ ����������� �����, � 2019 ���� ����� �������������� ������ �� ������ 60.3.* 

select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase                      
WHERE c.rf_idV006=1 /*AND c.rf_idV010<>4 */AND m.MUCode NOT LIKE '1.11.%' AND NOT EXISTS(select IDRB FROM oms_nsi.dbo.V001 WHERE IDRB=m.MUCode 
																					  UNION ALL
																					  SELECT MU FROM dbo.vw_sprMU WHERE MUGroupCode=60 AND MUUnGroupCode=3 AND mu=m.MUCode)

 --����� ���� ��������� 1.11.1 ��� 1.11.2, ������ � ����� ������ �� �� ����� ����
;WITH cte
AS(
select distinct c.id,m.MUCode
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase                      
WHERE c.rf_idV006=1 AND m.MUCode LIKE '1.11.%' 
)

SELECT id,591 FROM cte GROUP BY id HAVING COUNT(*)>1