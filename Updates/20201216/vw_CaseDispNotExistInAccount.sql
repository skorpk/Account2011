USE [RegisterCases]
GO

/****** Object:  View [dbo].[vw_CaseDispNotExistInAccount]    Script Date: 16.12.2020 8:38:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [dbo].[vw_CaseDispNotExistInAccount]
AS
SELECT a.rf_idFiles,pb.ENP,v.TypeDisp, a.ReportYear,c.rf_idMO AS CodeM
FROM t_Case c INNER JOIN dbo.t_RecordCase r ON
					c.rf_idRecordCase=r.id
			  INNER JOIN dbo.t_RegistersCase a ON
				  	r.rf_idRegistersCase=a.id
			  INNER JOIN dbo.t_RecordCaseBack rb ON
					c.id=rb.rf_idCase
				 INNER JOIN dbo.t_DispInfo d ON
					c.id=d.rf_idCase           
				INNER JOIN (VALUES('ÄÂ2','ÄÂ2'),('ÄÂ1','ÄÂ'),('ÄÂ4','ÄÂ'),('ÎÏÂ','ÄÂ'),('ÄÑ1','ÄC'),('ÄÑ2','ÄC'),('ÄÓ1','ÄC'),('ÄÓ2','ÄC'),('ÎÍ1','ÎÍ'),('ÎÍ2','ÎÍ')) v(id,TypeDisp) ON
					d.TypeDisp=v.id         
				 INNER JOIN dbo.t_PatientBack pb ON
					rb.id=pb.rf_idRecordCaseBack
				INNER JOIN dbo.t_CaseBack cb ON
					rb.id=cb.rf_idRecordCaseBack								
WHERE c.DateEnd>'20190101' AND cb.TypePay=1 AND a.ReportYear>2019
	AND NOT EXISTS(SELECT * FROM AccountOMS.dbo.t_Case WHERE GUID_Case=c.GUID_Case AND DateEnd>'20190101')

GO


