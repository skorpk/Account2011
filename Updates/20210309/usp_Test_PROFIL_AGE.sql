USE RegisterCases
GO
if(OBJECT_ID('usp_Test_PROFIL_AGE',N'P')) is not null
	drop PROCEDURE dbo.usp_Test_PROFIL_AGE
go
CREATE PROC dbo.usp_Test_PROFIL_AGE
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

INSERT #tError
SELECT DISTINCT c.id,CASE WHEN c.rf_idV002=14 AND c.age<60 THEN '003K.00.0760' WHEN c.rf_idV002=55 AND c.age>0 THEN '003K.00.0750' END
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase			  
			  join t_Case c on
		r.id=c.rf_idRecordCase					  		
		AND c.DateEnd>='20210101'	
where a.rf_idFiles=@idFile AND (CASE WHEN c.rf_idV002=14 AND c.age<60 THEN 1 WHEN c.rf_idV002=55 AND c.age>0 THEN 1 ELSE 0 END)=1

GO
GRANT EXECUTE ON usp_Test_PROFIL_AGE TO db_RegisterCase