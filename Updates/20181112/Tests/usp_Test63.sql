USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test63]    Script Date: 28.12.2018 14:13:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test63]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--Если сроки лечения не принадлежат ни одному периоду оплаты из средств ОМС заявленных условия оказания
insert #tError
select distinct c.id,63
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCase							                      
						inner join vw_sprV006 f on
			c.rf_idV006=f.ID
where f.DateBeg>cc.DateBegin

insert #tError
select distinct c.id,63
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCase							                      
						inner join vw_sprV006 f on
			c.rf_idV006=f.ID
where f.DateEnd<cc.DateEnd
