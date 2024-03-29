USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test570]    Script Date: 26.01.2017 13:42:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test570]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	
--услуг  из  Номенклатуры медицинских услуг (V001) при условиях оказания = 1 
--insert #tError
--select distinct c.id,570
--from t_RegistersCase a inner join t_RecordCase r on
--			a.id=r.rf_idRegistersCase
--			and a.rf_idFiles=@idFile 			
--						inner join t_Case c on
--			r.id=c.rf_idRecordCase				
--						inner join t_Meduslugi m on
--			c.id=m.rf_idCase			
--						left join vw_sprV002 v on
--			m.rf_idV002=v.id
--where c.rf_idV006>2 and v.id is null	
--2016-08-10 
insert #tError
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
---------------2014-02-04---------------
--insert #tError
--select distinct c.id,570
--from t_RegistersCase a inner join t_RecordCase r on
--			a.id=r.rf_idRegistersCase
--			and a.rf_idFiles=@idFile 
--						inner join t_Case c on
--			r.id=c.rf_idRecordCase			
--			--			INNER JOIN dbo.vw_IsSpecialCase s ON
--			--c.IsSpecialCase=s.OS_SLUCH
--			--AND s.IsClinincalExamination=0
--						inner join t_Meduslugi m on
--			c.id=m.rf_idCase
--						LEFT JOIN vw_idCaseWithOutPRVSandProfilCompare ce ON
--			c.id=ce.id
--			AND ce.rf_idFiles=@idFile				
--where ce.id IS NULL and c.rf_idV002<>m.rf_idV002
--16.12.2013 добавил в представлени vw_idCaseWithOutPRVSandProfilCompare что проверка не производиться по КСГ
insert #tError
select distinct c.id,570
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

--2014-02-27
INSERT #tError
select distinct c.id,570
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join (SELECT rf_idRecordCase,id,rf_idV002,IsSpecialCase from t_Case WHERE rf_idV010<>33 AND DateEnd>=@dateStart AND DateEnd<@dateEnd) c on
			r.id=c.rf_idRecordCase
			and c.rf_idV002!=158
			AND c.IsSpecialCase IS null	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase			
where c.rf_idV002<>m.rf_idV002 AND NOT EXISTS(SELECT * from vw_idCaseWithOutPRVSandProfilCompare 
											  WHERE rf_idFiles=@idFile AND DateEnd>=@dateStart AND DateEnd<@dateEnd AND id=c.id)  
											  AND NOT EXISTS(SELECT * FROM OMS_NSI.dbo.V001 WHERE IDRB=m.MUCode)
