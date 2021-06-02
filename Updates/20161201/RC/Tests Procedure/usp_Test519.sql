USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test531]    Script Date: 25.01.2017 14:45:19 ******/

CREATE PROC [dbo].[usp_Test519]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
IF(select f.CountSluch-COUNT(c.id) 
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
							inner join t_Case c on
			r.id=c.rf_idRecordCase								
	where a.rf_idFiles=@idFile 
	GROUP BY f.CountSluch)!=0
BEGIN
	insert #tError
	select DISTINCT c.id,519
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
							inner join t_Case c on
			r.id=c.rf_idRecordCase								
	where a.rf_idFiles=@idFile 
END
GO
GRANT EXECUTE ON usp_Test519 TO db_RegisterCase