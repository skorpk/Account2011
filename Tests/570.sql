USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='103001' and NumberRegister=4 and ReportYear=2019

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

select distinct c.id,570
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 			
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
						inner join t_Meduslugi m on
			c.id=m.rf_idCase									
where NOT EXISTS(SELECT * FROM vw_sprV002 WHERE id=m.rf_idV002) 

select distinct c.id,570
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 			
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
						inner join t_Meduslugi m on
			c.id=m.rf_idCase			
						left join vw_sprV002 v on
			m.rf_idV002=v.id
where c.rf_idV006 IN(1,2) AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.V001 WHERE IDRB=m.MUCode) and v.id is null						

--16.12.2013 ������� � ������������ vw_idCaseWithOutPRVSandProfilCompare ��� �������� �� ������������� �� ���
select distinct c.id,570,m.MUCode,c.rf_idV010 ,c.rf_idV002,m.rf_idV002,c.GUID_Case
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			and c.rf_idV002!=158
			AND c.IsSpecialCase IS null	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						LEFT JOIN vw_idCaseWithOutPRVSandProfilCompare ce ON
			c.id=ce.id
			AND ce.rf_idFiles=@idFile				
where ce.id IS NULL and c.rf_idV002<>m.rf_idV002 AND NOT EXISTS(SELECT * FROM OMS_NSI.dbo.V001 WHERE IDRB=m.MUCode)

--SELECT * FROM vw_sprV002 WHERE id IN(30,5)
--2014-02-27
select distinct c.id,570,c.rf_idV010
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join (SELECT rf_idRecordCase,id,rf_idV002,IsSpecialCase,rf_idV010 from t_Case WHERE rf_idV010<>33 AND DateEnd>=@dateStart AND DateEnd<@dateEnd) c on
			r.id=c.rf_idRecordCase
			and c.rf_idV002!=158
			AND c.IsSpecialCase IS null	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase			
where c.rf_idV002<>m.rf_idV002 AND NOT EXISTS(SELECT * from vw_idCaseWithOutPRVSandProfilCompare 
											  WHERE rf_idFiles=@idFile AND DateEnd>=@dateStart AND DateEnd<@dateEnd AND id=c.id)  
											  AND NOT EXISTS(SELECT * FROM OMS_NSI.dbo.V001 WHERE IDRB=m.MUCode)
