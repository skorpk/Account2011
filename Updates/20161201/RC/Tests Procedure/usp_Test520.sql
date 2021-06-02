USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test531]    Script Date: 25.01.2017 14:45:19 ******/

CREATE PROC [dbo].[usp_Test520]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
select DISTINCT c.id,520
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
				INNER JOIN dbo.t_PatientSMO ps ON
		r.id=ps.ref_idRecordCase              
						inner join t_Case c on
		r.id=c.rf_idRecordCase								
where a.rf_idFiles=@idFile AND  ps.ENP IS NOT NULL AND ps.ENP NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
GO
GRANT EXECUTE ON usp_Test520 TO db_RegisterCase