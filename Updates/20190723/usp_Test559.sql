USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test559]    Script Date: 23.07.2019 9:11:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test559]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg date		
AS
--RSLT
insert #tError
select distinct c.id,559
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprV009 v on
			c.rf_idV009=v.id
			and c.rf_idV006=v.USL_OK
where v.id is NULL
---запись в справочнике V009 должна быть действующей для текущей даты (даты регистрации реестра сведений)
--28.03.2014
insert #tError
select distinct c.id,559
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_CompletedCase z ON
			r.id=z.rf_idRecordCase								
where NOT EXISTS(SELECT * FROM vw_sprV009 WHERE id=c.rf_idV009 AND z.DateEnd>=DateBeg AND ISNULL(DateEnd,z.DateEnd)>=z.DateEnd)

