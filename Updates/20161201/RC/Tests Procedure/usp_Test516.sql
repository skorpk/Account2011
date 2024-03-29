USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test516]    Script Date: 06.02.2017 8:00:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test516]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--error 516
---Проверка на заполненость тегов связанных с КСЛП 

insert #tError
select DISTINCT m.rf_idCase,516
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>'20160430'						
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase		
						INNER JOIN dbo.vw_sprCSG csg ON
			m.MES=csg.code
where c.rf_idV006=1 AND c.rf_idV008=31 AND ISNULL(csg.noKSLP,0)<>1 AND (c.Age>74 OR c.Age<4) AND c.IT_SL IS NULL

insert #tError
SELECT DISTINCT m.rf_idCase,516
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>'20160430'						
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase		
						INNER JOIN dbo.vw_sprCSG csg ON
			m.MES=csg.code
where c.rf_idV006=1 AND c.rf_idV008=31 AND ISNULL(csg.noKSLP,0)<>1 AND (c.Age>74 OR c.Age<4) 
	AND NOT EXISTS(SELECT * FROM dbo.t_Coefficient WHERE rf_idCase=c.id AND Code_SL IS NOT NULL AND Coefficient IS NOT NULL)
GO
GRANT EXECUTE ON [usp_Test516] TO db_RegisterCase 