USE RegisterCases
GO
if(OBJECT_ID('usp_Test581',N'P')) is not null
	drop PROCEDURE dbo.usp_Test581
go
CREATE PROC dbo.usp_Test581
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

INSERT #tError
SELECT DISTINCT c.id,581
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase			  
			  join t_Case c on
		r.id=c.rf_idRecordCase					  		
		AND c.DateEnd>='20210101'			
				JOIN dbo.t_RefRegisterPatientRecordCase rf ON
         r.id=rf.rf_idRecordCase
				JOIN dbo.t_RegisterPatient p ON
         rf.rf_idRegisterPatient=p.id
		 AND p.rf_idFiles=f.id							
where a.rf_idFiles=@idFile AND EXISTS(SELECT 1 FROM t_RegisterPatientDocument d 
									  WHERE d.rf_idRegisterPatient=p.id AND d.rf_idDocumentType<>'26' 
									  AND (LEN(ISNULL(d.SeriaDocument,''))=0 OR LEN(ISNULL(d.NumberDocument,''))=0)
									  )

GO
GRANT EXECUTE ON usp_Test581 TO db_RegisterCase