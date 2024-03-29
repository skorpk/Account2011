USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test404]    Script Date: 16.01.2018 8:52:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[usp_Test405]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
select DISTINCT c.id,405
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
				INNER JOIN dbo.t_AdditionalCriterion ac ON
		c.id=ac.rf_idCase						
where a.rf_idFiles=@idFile AND LEN(ac.rf_idAddCretiria)>0 AND c.rf_idV006 >2

insert #tError
select DISTINCT c.id,405
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
				INNER JOIN dbo.t_AdditionalCriterion ac ON
		c.id=ac.rf_idCase	
where a.rf_idFiles=@idFile AND LEN(ac.rf_idAddCretiria)>0 AND NOT EXISTS(SELECT * FROM dbo.vw_sprAddCriterion WHERE code=ac.rf_idAddCretiria) 							

go
GRANT EXECUTE ON usp_Test405 TO db_RegisterCase;

