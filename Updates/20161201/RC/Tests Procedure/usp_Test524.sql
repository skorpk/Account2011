USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test531]    Script Date: 25.01.2017 14:45:19 ******/

create PROC [dbo].[usp_Test524]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
select DISTINCT c.id,524
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
			  INNER JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase						  		
where a.rf_idFiles=@idFile AND d.DiagnosisCode='O04' AND d.TypeDiagnosis=1 AND c.rf_idV002 IN (136,137) AND ISNULL(c.Comments,'9') NOT IN('3','4')

GO
GRANT EXECUTE ON usp_Test524 TO db_RegisterCase