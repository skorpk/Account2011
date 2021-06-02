USE [AccountOMS]
GO

/****** Object:  View [dbo].[vw_CaseDispInAccountWithoutFin]    Script Date: 16.12.2020 8:36:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER VIEW [dbo].[vw_CaseDispInAccountWithoutFin]
AS
SELECT f.CodeM,a.NumberRegister,ps.ENP,a.ReportYear,v.TypeDisp, c.id
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts		
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					 INNER JOIN dbo.t_DispInfo d ON
					c.id=d.rf_idCase
					INNER JOIN (VALUES('ÄÂ2','ÄÂ2'),('ÄÂ1','ÄÂ'),('ÄÂ4','ÄÂ'),('ÎÏÂ','ÄÂ'),('ÄÑ1','ÄC'),('ÄÑ2','ÄC'),('ÄÓ1','ÄC'),('ÄÓ2','ÄC'),('ÎÍ1','ÎÍ'),('ÎÍ2','ÎÍ')) v(id,TypeDisp) ON
            d.TypeDisp=v.id
WHERE f.DateRegistration>'20200101' AND c.DateEnd>'20191231' 
		AND NOT	EXISTS(SELECT 1
						FROM dbo.t_PaymentAcceptedCase2	f
						WHERE f.DateRegistration>='20200101' AND f.DateRegistration<=GETDATE() AND f.rf_idCase=c.id)

GO


