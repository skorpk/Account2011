USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test572]    Script Date: 26.01.2017 13:39:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test572]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
---------------2013-06-24---------------
--DATE_IN

--Проверка 2: на дату начала услуги
--для не ЗС
insert #tError
select distinct c.id,572
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase						
						inner join t_Meduslugi m on
			c.id=m.rf_idCase 
where c.DateBegin>m.DateHelpBegin
--insert #tError
--select distinct c.id,572
--from t_RegistersCase a inner join t_RecordCase r on
--					a.id=r.rf_idRegistersCase
--					and a.rf_idFiles=@idFile
--						inner join t_Case c on
--					r.id=c.rf_idRecordCase	
--						INNER JOIN dbo.vw_IsSpecialCase s ON
--					c.IsSpecialCase=s.OS_SLUCH
--					AND s.IsClinincalExamination=0
--					AND c.IsCompletedCase=0
--						inner join t_Meduslugi m on
--			c.id=m.rf_idCase 
--where c.DateBegin>m.DateHelpBegin
----для ЗС
/*
insert #tError
select distinct c.id,572
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.IsSpecialCase IS NULL
					AND c.IsCompletedCase=1
						INNER JOIN dbo.t_Mes mes ON
					c.id=mes.rf_idCase
						inner join t_Meduslugi m on
					c.id=m.rf_idCase 
						LEFT JOIN vw_idCaseWithOutPRVSandProfilCompare ce ON
					c.id=ce.id
					AND ce.rf_idFiles=@idFile				
where ce.id IS NULL AND c.DateBegin>m.DateHelpBegin

insert #tError
select distinct c.id,572
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase	
						INNER JOIN dbo.vw_IsSpecialCase s ON
					c.IsSpecialCase=s.OS_SLUCH
					AND s.IsClinincalExamination=0
					AND c.IsCompletedCase=1
						INNER JOIN dbo.t_Mes mes ON
					c.id=mes.rf_idCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase 
						LEFT JOIN vw_idCaseWithOutPRVSandProfilCompare ce ON
					c.id=ce.id
					AND ce.rf_idFiles=@idFile				
where ce.id IS NULL AND c.DateBegin>m.DateHelpBegin	
*/