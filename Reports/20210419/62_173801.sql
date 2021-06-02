USE RegisterCases
GO
DECLARE @dtStar DATETIME='20200101',
		@dtEnd DATETIME=GETDATE(),
		@codeM CHAR(6)='173801',
		@year SMALLINT=2020

SELECT DISTINCT p.ENP,m.MES,cs.name,c.DateBegin,c.DateEnd,c.kd
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase								
				INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCase
				JOIN dbo.t_MES m ON
        c.id=m.rf_idCase
				JOIN dbo.vw_sprCSG cs ON
        m.mes=cs.code
				JOIN dbo.t_RecordCaseBack rb ON
		c.id=rb.rf_idCase
				JOIN dbo.t_PatientBack p ON
		rb.id=p.rf_idRecordCaseBack         
				JOIN dbo.t_ErrorProcessControl e ON
        c.id=e.rf_idCase
		AND f.id=e.rf_idFile
WHERE f.DateRegistration>@dtStar AND f.DateRegistration<@dtEnd AND a.ReportYear=@year AND f.CodeM=@codeM AND c.rf_idV006=1
	  AND e.ErrorNumber='62' AND NOT EXISTS(SELECT *
											FROM t_Case cc JOIN dbo.t_RecordCaseBack r ON
													cc.id=r.rf_idCase
															JOIN dbo.t_CaseBack cb ON
													r.id=cb.rf_idRecordCaseBack
											WHERE cc.rf_idMO=@codeM AND cc.GUID_Case=c.GUID_Case AND cb.TypePay=1)


GO
-----------------------------------2021----------------------------
DECLARE @dtStar DATETIME='20210101',
		@dtEnd DATETIME=GETDATE(),
		@codeM CHAR(6)='173801',
		@year SMALLINT=2021

SELECT DISTINCT p.ENP,m.MES,cs.name,c.DateBegin,c.DateEnd,c.kd
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase								
				INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCase
				JOIN dbo.t_MES m ON
        c.id=m.rf_idCase
				JOIN dbo.vw_sprCSG cs ON
        m.mes=cs.code
				JOIN dbo.t_RecordCaseBack rb ON
		c.id=rb.rf_idCase
				JOIN dbo.t_PatientBack p ON
		rb.id=p.rf_idRecordCaseBack         
				JOIN dbo.t_ErrorProcessControl e ON
        c.id=e.rf_idCase
		AND f.id=e.rf_idFile
WHERE f.DateRegistration>@dtStar AND f.DateRegistration<@dtEnd AND a.ReportYear=@year AND f.CodeM=@codeM AND c.rf_idV006=1 AND a.ReportMonth<4
	  AND e.ErrorNumber='62' AND NOT EXISTS(SELECT *
											FROM t_Case cc JOIN dbo.t_RecordCaseBack r ON
													cc.id=r.rf_idCase
															JOIN dbo.t_CaseBack cb ON
													r.id=cb.rf_idRecordCaseBack
											WHERE cc.rf_idMO=@codeM AND cc.GUID_Case=c.GUID_Case AND cb.TypePay=1)