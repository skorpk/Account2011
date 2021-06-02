USE RegisterCases
GO
if(OBJECT_ID('usp_Test_PROFIL_SEX',N'P')) is not null
	drop PROCEDURE dbo.usp_Test_PROFIL_SEX
go
CREATE PROC dbo.usp_Test_PROFIL_SEX
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

INSERT #tError
SELECT DISTINCT c.id,'003K.00.0740'
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase			  
			  JOIN dbo.t_RefRegisterPatientRecordCase rf ON
        r.id=rf.rf_idRecordCase
			  JOIN dbo.t_RegisterPatient p ON
        p.id = rf.rf_idRegisterPatient
		AND p.rf_idFiles=@idFile
			  join t_Case c on
		r.id=c.rf_idRecordCase					  		
		AND c.DateEnd>='20210101'	
where a.rf_idFiles=@idFile AND c.rf_idV002 IN(3, 136, 137, 184) AND p.rf_idV005<>2


GO
GRANT EXECUTE ON usp_Test_PROFIL_SEX TO db_RegisterCase