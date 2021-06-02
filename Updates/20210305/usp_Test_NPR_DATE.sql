USE RegisterCases
GO
if(OBJECT_ID('usp_Test_NPR_DATE',N'P')) is not null
	drop PROCEDURE dbo.usp_Test_NPR_DATE
go
CREATE PROC dbo.usp_Test_NPR_DATE
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
----------------------NPR_DATE--------------------------
INSERT #tError
SELECT DISTINCT c.id,'006F.00.0311'
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  JOIN t_RefRegisterPatientRecordCase ref on
		r.id=ref.rf_idRecordCase
			   JOIN t_RegisterPatient p on
		ref.rf_idRegisterPatient=p.id
		and p.rf_idFiles=@idFile
			  join t_Case c on
		r.id=c.rf_idRecordCase					  		
		AND c.DateEnd>='20210101'			
				JOIN dbo.t_DirectionDate s on
		c.id=s.rf_idCase
where a.rf_idFiles=@idFile AND DATEDIFF(DAY,s.DirectionDate,p.BirthDay)>0

INSERT #tError
SELECT DISTINCT c.id,'006F.00.0310'
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase			  
			  join t_Case c on
		r.id=c.rf_idRecordCase					  		
		AND c.DateEnd>='20210101'
				JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase			
				JOIN dbo.t_DirectionDate s on
		c.id=s.rf_idCase
where a.rf_idFiles=@idFile AND DATEDIFF(DAY,s.DirectionDate,cc.DateEnd)<0


GO
GRANT EXECUTE ON usp_Test_NPR_DATE TO db_RegisterCase