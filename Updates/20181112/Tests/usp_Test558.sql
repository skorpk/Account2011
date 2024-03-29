USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test558]    Script Date: 04.01.2019 10:54:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test558]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--проверка по медицинским услугам
--Date enable is 08.02.2013
--Изменил т.к. в справочнике ТФОМС может и не быть значения.Хотя считаю что это неправильно.

INSERT #tError
select distinct c.id,558
from t_RegistersCase a inner join t_RecordCase r on
   a.id=r.rf_idRegistersCase
   and a.rf_idFiles=@idFile 
      inner join t_PatientSMO s on
   r.id=s.ref_idRecordCase
      inner join t_Case c on
   r.id=c.rf_idRecordCase 
   and c.DateEnd>='20121101'
      inner join t_Meduslugi m on
   c.id=m.rf_idCase
   and c.IsCompletedCase=0
   AND m.Price>0
      inner join vw_sprMUAll mu on
   m.MUCode=mu.MU      
where NOT EXISTS(SELECT * FROM vw_sprMU_CSG_Payment WHERE MUCode=m.MUCode AND PaymentMethodCode IS NOT null AND PaymentMethodCode=c.rf_idV010 )

--проверка по законченным случаям

insert #tError
select distinct c.id,558
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			and c.DateEnd>='20121101'
			and c.IsCompletedCase=1
						inner join t_MES m on
			c.id=m.rf_idCase
			--			inner join vw_sprMUAll mu on
			--m.MES=mu.MU			
where NOT EXISTS(SELECT * FROM vw_sprMU_CSG_Payment WHERE MUCode=m.MES AND PaymentMethodCode IS NOT null AND PaymentMethodCode=c.rf_idV010 )
