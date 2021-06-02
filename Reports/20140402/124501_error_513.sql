USE RegisterCases
GO

DECLARE @tWrongCase AS TABLE(GUID_Case UNIQUEIDENTIFIER,rf_idCase bigint)
DECLARE @tRightCase AS TABLE(GUID_Case UNIQUEIDENTIFIER)

INSERT @tWrongCase( GUID_Case,rf_idCase )
SELECT DISTINCT c.GUID_Case,c.id
from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
					r.id=c.rf_idRecordCase					
			  inner join dbo.t_Meduslugi m on
						c.id=m.rf_idCase  						
			  INNER JOIN dbo.vw_sprMuWithParamAccount l ON
						m.MUCode=l.MU	   						
			  INNER JOIN t_ErrorProcessControl e ON
						c.id=e.rf_idCase
WHERE f.CodeM='124501' AND f.DateRegistration>'20140101' AND f.DateRegistration<GETDATE() AND a.ReportYear=2014 AND e.ErrorNumber=513
	AND l.AccountParam IN ('O','R')

INSERT @tWrongCase( GUID_Case,rf_idCase )
SELECT DISTINCT c.GUID_Case,c.id
from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
					r.id=c.rf_idRecordCase					
			  inner join dbo.t_MES m on
						c.id=m.rf_idCase  						
			  INNER JOIN dbo.vw_sprMuWithParamAccount l ON
						m.MES=l.MU	   						
			  INNER JOIN t_ErrorProcessControl e ON
						c.id=e.rf_idCase
WHERE f.CodeM='124501' AND f.DateRegistration>'20140101' AND f.DateRegistration<GETDATE() AND a.ReportYear=2014 AND e.ErrorNumber=513
	AND l.AccountParam IN ('O','R')
------------------------------------------------------------------------
INSERT @tRightCase( GUID_Case )
SELECT DISTINCT c.GUID_Case
from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
					r.id=c.rf_idRecordCase					
			  inner join dbo.t_Meduslugi m on
						c.id=m.rf_idCase  						
			  INNER JOIN dbo.vw_sprMuWithParamAccount l ON
						m.MUCode=l.MU
			  INNER JOIN dbo.t_RecordCaseBack rb ON
						c.id=rb.rf_idCase
			  INNER JOIN dbo.t_CaseBack cb ON
						rb.id=cb.rf_idRecordCaseBack	   									  
WHERE f.CodeM='124501' AND f.DateRegistration>'20140101' AND f.DateRegistration<GETDATE() AND a.ReportYear=2014 AND l.AccountParam IN ('O','R') AND cb.TypePay=1

INSERT @tRightCase( GUID_Case )
SELECT DISTINCT c.GUID_Case
from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
					r.id=c.rf_idRecordCase					
			  inner join dbo.t_MES m on
						c.id=m.rf_idCase  						
			  INNER JOIN dbo.vw_sprMuWithParamAccount l ON
						m.MES=l.MU	   		
			  INNER JOIN dbo.t_RecordCaseBack rb ON
						c.id=rb.rf_idCase
			  INNER JOIN dbo.t_CaseBack cb ON
						rb.id=cb.rf_idRecordCaseBack	   									  
WHERE f.CodeM='124501' AND f.DateRegistration>'20140101' AND f.DateRegistration<GETDATE() AND a.ReportYear=2014 AND l.AccountParam IN ('O','R') AND cb.TypePay=1


SELECT FIO,BirthDay,NumberRegister,DateRegister,Numbercase,rf_idSMO,s.sNameS,DateBegin,DateEnd
FROM (
SELECT TOP 1 WITH TIES f.DateRegistration,c.GUID_Case,p.Fam+' '+p.Im+' '+p.Ot AS FIO,p.BirthDay,a.NumberRegister,a.DateRegister,c.idRecordCase AS Numbercase,s.rf_idSMO,c.DateBegin,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
				  INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase	
				  INNER JOIN dbo.t_PatientSMO s ON
			r.id=s.ref_idRecordCase		
				  INNER JOIN dbo.t_RefRegisterPatientRecordCase rp ON
			r.id=rp.rf_idRecordCase
				  INNER JOIN dbo.t_RegisterPatient p ON
			rp.rf_idRegisterPatient=p.id
				  INNER JOIN dbo.t_Case c ON					
			r.id=c.rf_idRecordCase
				  INNER JOIN @tWrongCase t1 ON
			c.id=t1.rf_idCase				  				
WHERE NOT EXISTS(select * FROM @tRightCase WHERE GUID_Case=t1.GUID_Case)
ORDER BY ROW_NUMBER() OVER(PARTITION BY c.GUID_Case ORDER BY f.DateRegistration DESC)
) t INNER JOIN dbo.vw_sprSMO s ON
		t.rf_idSMO=s.smocod
ORDER BY FIO