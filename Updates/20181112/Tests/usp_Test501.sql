USE [RegisterCases]
GO
ALTER PROC [dbo].[usp_Test501]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
-------------------Новые проверки 23.01.2015----------------------		
---тег CODE_MES1 должен быть заполнен обязательно при IDSP=32,33,43
insert #tError
select distinct c.id,501
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd<'20190101'
						INNER JOIN (VALUES (33),(43),(32)) v010(id) ON
			c.rf_idV010=v010.id					
WHERE a.ReportMonth=@month and a.ReportYear=@year AND NOT EXISTS(SELECT * FROM dbo.t_MES m WHERE m.rf_idCase=c.id)


insert #tError
select distinct c.id,501
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20190101'						
WHERE a.ReportMonth=@month and a.ReportYear=@year AND c.rf_idV010=33 AND c.rf_idV006=1 AND NOT EXISTS(SELECT * FROM dbo.t_MES m WHERE m.rf_idCase=c.id)

insert #tError
select distinct c.id,501
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20190101'						
WHERE a.ReportMonth=@month and a.ReportYear=@year AND c.rf_idV010=33 AND c.rf_idV006=1 AND c.rf_idV008=32 AND EXISTS(SELECT * FROM dbo.t_MES m WHERE m.rf_idCase=c.id AND IsCSGTag=2)

insert #tError
select distinct c.id,501
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20190101'						
WHERE a.ReportMonth=@month and a.ReportYear=@year AND c.rf_idV010=33 AND c.rf_idV006=1 AND c.rf_idV008=31 AND EXISTS(SELECT * FROM dbo.t_MES m WHERE m.rf_idCase=c.id AND IsCSGTag=1)

insert #tError
select distinct c.id,501
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20190101'						
WHERE a.ReportMonth=@month and a.ReportYear=@year AND c.rf_idV010=43 AND c.rf_idV006=2 AND NOT EXISTS(SELECT * FROM dbo.t_MES m WHERE m.rf_idCase=c.id AND IsCSGTag=2)

insert #tError
select distinct c.id,501
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20190101'						
WHERE a.ReportMonth=@month and a.ReportYear=@year AND c.rf_idV010=43 AND c.rf_idV006=2 AND c.rf_idV008=31 AND EXISTS(SELECT * FROM dbo.t_MES m WHERE m.rf_idCase=c.id AND IsCSGTag=1)