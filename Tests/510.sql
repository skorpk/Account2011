USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='104401' and NumberRegister=46543 and ReportYear=2021

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
--������������� ���� ������ � ���� ��������� ��������� �������
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	
--510
--���������� �������� 1: ���� VIDPOM=32, �� ���� ������ ���� ��������� ����������� � ��������� �������� ������ ��������������� �������������� ������� ��� V019 
--(���� IDHM) �� ���� ��������� �������(03.02.2016). ���� �������� ������������� �������������� ������� ���, �� ���������� �������� ������������ ���������� ������ ��� ���� ��� 
--(���������� ������������ ����� ��� � ������� ���) � ���������� �������� ������������ ��������� �������� ���������, 
--��� ������� ����������� ��������� ����� ��� (���������� ������������ ������� ��� ���������).
 
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------������������ �������	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase		
WHERE c.rf_idV008=32 AND c.rf_idV019 IS NULL

--���������� �������� 2: ���� ���� ���������, �� VIDPOM ������ ���� ����� 32 � ��������� �������� ������ ��������������� �������������� V019 (���� IDH�).
 
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------������������ �������	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase		
WHERE c.rf_idV008<>32 AND c.rf_idV019 IS NOT NULL
--�� ���� ��������� �������(03.02.2016)
 
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------������������ �������	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase		
WHERE c.rf_idV019 IS NOT NULL AND NOT EXISTS(SELECT * FROM dbo.vw_sprV019_2021 WHERE IDHM=c.rf_idV019 AND IDHVID=c.rf_idV018 AND DateBeg<=c.DateEnd AND c.DateEnd<=DateEnd)

