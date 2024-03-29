USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test562]    Script Date: 04.01.2019 10:07:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test562]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	
insert #tError
select distinct c.id,562
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			and c.IsCompletedCase=0	
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
						inner join t_Meduslugi m on
			c.id=m.rf_idCase						
						left join vw_sprMuPRVSAge v on
			m.rf_idV004=v.rf_idV015
			and c.IsChild=v.IsChildTariff
			and m.MUCode=v.MUCode
			AND c.DateEnd BETWEEN v.DateBegin AND v.DateEnd
where m.Price>0 and v.MUCode is NULL
---------------------------Dental MU-----------------
insert #tError
select distinct c.id,562
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			and c.IsCompletedCase=0	
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
						inner join t_Meduslugi m on
			c.id=m.rf_idCase						
						INNER join oms_nsi.dbo.vw_sprDentalMuPRVSAge v on			
			m.MUSurgery=v.Code
where NOT EXISTS(SELECT * FROM oms_nsi.dbo.vw_sprDentalMuPRVSAge v WHERE v.code=m.MUSurgery AND v.rf_AgeGroupId=c.IsChild AND v.rf_sprV015RecId=m.rf_idV004)
-----------------------------------------------------

insert #tError
select distinct c.id,562
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
						inner join t_Mes m on
			c.id=m.rf_idCase
			--			inner join vw_sprMUCompletedCase mu on
			--m.MES=mu.MU
						left join vw_sprMuPRVSAge v on
			c.rf_idV004=v.rf_idV015
			and c.IsChild=v.IsChildTariff
			and m.MES=v.MUCode
			AND c.DateEnd BETWEEN v.DateBegin AND v.DateEnd
WHERE m.IsCSGTag=1 and v.MUCode is null
