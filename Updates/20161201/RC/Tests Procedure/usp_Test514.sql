USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test514]    Script Date: 30.01.2017 15:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test514]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
-------------------------18.01.2016-----------------------------------------------------
--Поле заполняется 0 в одном из следующих случаев:
--•	в поле P_OTK на уровне медуслуги указано 1 
--•	в поле COMENTU указано ОТКАЗ,
--•	DATE_IN< DATE_1


INSERT #tError
select distinct c.id,514
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
WHERE m.rf_idDoctor IS NULL AND m.DateHelpBegin>=c.DateBegin AND m.rf_idMO=c.rf_idMO AND UPPER(ISNULL(m.Comments,'bla-bla'))<>'ОТКАЗ' AND m.IsNeedUsl NOT IN(1,2)


--•	Значение в поле LPU на уровне случая не равно значению в теге LPU для услуги.
IF @CodeLPU<>'125901'
BEGIN 
	INSERT #tError
	select distinct c.id,514
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile 						
							inner join t_Case c on
				r.id=c.rf_idRecordCase										
	WHERE c.rf_idDoctor IS NULL 
end 
