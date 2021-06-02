USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test531]    Script Date: 25.01.2017 14:45:19 ******/

CREATE PROC [dbo].[usp_Test526]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
select DISTINCT c.id,526
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								
				INNER JOIN dbo.t_DispInfo d ON
		c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprV016TFOMS WHERE Code=d.TypeDisp)
GO
GRANT EXECUTE ON usp_Test526 TO db_RegisterCase