USE AccountOMS
go
SELECT  s.rf_idCase , s.DS_ONK ,s.Reab
FROM  dbo.tmp_FileSynch AS f INNER JOIN t_RegistersAccounts AS a ON 
				f.rf_idFile = a.rf_idFiles 
							INNER JOIN t_RecordCasePatient AS r ON 
				a.id = r.rf_idRegistersAccounts 							
							INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient                          
							INNER JOIN dbo.t_DS_ONK_REAB s ON
				c.id=s.rf_idCase
--------------------------------------

SELECT s.id ,s.rf_idCase ,s.DS1_T ,s.rf_idN002 ,s.rf_idN003 ,s.rf_idN004 ,s.rf_idN005 ,s.IsMetastasis ,s.TotalDose
FROM  dbo.tmp_FileSynch AS f INNER JOIN t_RegistersAccounts AS a ON 
				f.rf_idFile = a.rf_idFiles 
							INNER JOIN t_RecordCasePatient AS r ON 
				a.id = r.rf_idRegistersAccounts 							
							INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient                          
							INNER JOIN dbo.t_ONK_SL s ON
				c.id=s.rf_idCase
-------------------------------------------

SELECT  s.rf_idONK_SL ,s.TypeDiagnostic ,s.CodeDiagnostic ,s.ResultDiagnostic
FROM  dbo.tmp_FileSynch AS f INNER JOIN t_RegistersAccounts AS a ON 
				f.rf_idFile = a.rf_idFiles 
							INNER JOIN t_RecordCasePatient AS r ON 
				a.id = r.rf_idRegistersAccounts 							
							INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient
							INNER JOIN dbo.t_ONK_SL o ON
				c.id=o.rf_idCase                          
							INNER JOIN dbo.t_DiagnosticBlock s ON
				o.id=s.rf_idONK_SL
----------------------------------------------------

SELECT   s.rf_idONK_SL ,s.Code ,s.DateContraindications
FROM  dbo.tmp_FileSynch AS f INNER JOIN t_RegistersAccounts AS a ON 
				f.rf_idFile = a.rf_idFiles 
							INNER JOIN t_RecordCasePatient AS r ON 
				a.id = r.rf_idRegistersAccounts 							
							INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient
							INNER JOIN dbo.t_ONK_SL o ON
				c.id=o.rf_idCase                          
							INNER JOIN dbo.t_Contraindications s ON
				o.id=s.rf_idONK_SL
---------------------------------------------------------

SELECT    s.rf_idCase ,s.GUID_MU ,s.DirectionDate ,s.TypeDirection ,s.MethodStudy ,s.DirectionMU
FROM  dbo.tmp_FileSynch AS f INNER JOIN t_RegistersAccounts AS a ON 
				f.rf_idFile = a.rf_idFiles 
							INNER JOIN t_RecordCasePatient AS r ON 
				a.id = r.rf_idRegistersAccounts 							
							INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient
							INNER JOIN dbo.t_DirectionMU s ON
				c.id=s.rf_idCase
-------------------------------------------------------------


SELECT     s.rf_idCase , s.GUID_MU ,s.ConsultationInfo ,s.rf_idN013 ,s.TypeSurgery ,s.TypeDrug ,s.TypeCycleOfDrug ,s.TypeRadiationTherapy
FROM  dbo.tmp_FileSynch AS f INNER JOIN t_RegistersAccounts AS a ON 
				f.rf_idFile = a.rf_idFiles 
							INNER JOIN t_RecordCasePatient AS r ON 
				a.id = r.rf_idRegistersAccounts 							
							INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient
							INNER JOIN dbo.t_ONK_USL s ON
				c.id=s.rf_idCase

