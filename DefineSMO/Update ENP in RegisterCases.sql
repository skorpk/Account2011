USE RegisterCases
GO
declare @idFileBack INT,
		@idFile int

select @idFileBack=idFileBack ,@idFile=rf_idFiles FROM dbo.vw_getFileBack where CodeM='145516' and NumberRegister=1413 and ReportYear=2020 AND PropertyNumberRegister=2


SELECT recb.rf_idCase,p.*,z.UniqueNumberPolicy
from t_FileBack fb inner join t_RegisterCaseBack rcb on
				fb.id=rcb.rf_idFilesBack
					inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
							INNER JOIN dbo.t_CaseBack cp ON
			cp.rf_idRecordCaseBack = recb.id
							INNER JOIN dbo.t_RefCasePatientDefine d ON
            d.rf_idCase = recb.rf_idCase
			AND d.rf_idFiles=@idFile
							INNER JOIN dbo.t_CaseDefineZP1Found z ON
				d.id=z.rf_idRefCaseIteration
where fb.id=@idFileBack AND cp.TypePay=1 AND p.ENP IS NULL

BEGIN TRANSACTION
UPDATE p SET p.ENP=z.UniqueNumberPolicy
from t_FileBack fb inner join t_RegisterCaseBack rcb on
				fb.id=rcb.rf_idFilesBack
					inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
							INNER JOIN dbo.t_CaseBack cp ON
			cp.rf_idRecordCaseBack = recb.id
							INNER JOIN dbo.t_RefCasePatientDefine d ON
            d.rf_idCase = recb.rf_idCase
			AND d.rf_idFiles=@idFile
							INNER JOIN dbo.t_CaseDefineZP1Found z ON
				d.id=z.rf_idRefCaseIteration
where fb.id=@idFileBack AND cp.TypePay=1 AND p.ENP IS NULL
-------------update SMO--------------------
UPDATE p SET p.CodeSMO34=s.SMOKOD
from t_FileBack fb inner join t_RegisterCaseBack rcb on
				fb.id=rcb.rf_idFilesBack
					inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							INNER JOIN dbo.t_CompletedCase cc ON
            rc.id=cc.rf_idRecordCase
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
							INNER JOIN dbo.t_CaseBack cp ON
			cp.rf_idRecordCaseBack = recb.id
							INNER JOIN dbo.t_RefCasePatientDefine d ON
            d.rf_idCase = recb.rf_idCase
			AND d.rf_idFiles=@idFile
							INNER JOIN dbo.t_CaseDefineZP1Found z ON
				d.id=z.rf_idRefCaseIteration
						inner join dbo.vw_sprSMOGlobal s on
			z.OGRN_SMO=s.OGRN
			and z.OKATO=s.OKATO
			AND cc.DateEnd BETWEEN s.dateBeg AND s.dateEnd
where fb.id=@idFileBack AND cp.TypePay=1 AND p.rf_idSMO='34'



SELECT recb.rf_idCase,p.*,z.UniqueNumberPolicy
from t_FileBack fb inner join t_RegisterCaseBack rcb on
				fb.id=rcb.rf_idFilesBack
					inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
							INNER JOIN dbo.t_CaseBack cp ON
			cp.rf_idRecordCaseBack = recb.id
							INNER JOIN dbo.t_RefCasePatientDefine d ON
            d.rf_idCase = recb.rf_idCase
			AND d.rf_idFiles=@idFile
							INNER JOIN dbo.t_CaseDefineZP1Found z ON
				d.id=z.rf_idRefCaseIteration
where fb.id=@idFileBack AND cp.TypePay=1 
commit
GO
