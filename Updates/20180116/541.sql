USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test541]    Script Date: 16.01.2018 7:56:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test541]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--USL_OK
--Проводится проверка на соответствие представленного значения справочнику V006
insert #tError
select distinct c.id,541
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprV006 f on
			c.rf_idV006=f.ID
where f.ID is null						

--Если код законченного случая в представленном случае не соответствует заявленным условиям оказания, 
--или хотя бы одна из услуг не может быть оказана в заявленных условиях оказания.
--2012-11-14
--2016-08-10 проверка изменилась. отбор только по ЗС(MUType=1)
insert #tError
select distinct c.id,541
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			and c.DateEnd>='20121101'
						inner join vw_MeduslugiMes m  on
			c.id=m.rf_idCase
			--AND m.MUType=1
						left join OMS_NSI.dbo.V_MUCondition con on
			c.rf_idV006=con.ConditionCode
			and m.MUCode=con.MUCode
where con.MUCode is null	
