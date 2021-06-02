USE RegisterCases
GO
DECLARE @idFile INT
SELECT @idFile=id FROM dbo.vw_getIdFileNumber WHERE ReportYear=2014 AND CodeM='114506' AND NumberRegister=16

select rcb.NumberRegister,rcb.PropertyNumberRegister,fb.CodeM,fb.DateCreate
FROM dbo.t_FileBack fb INNER JOIN t_RegisterCaseBack rcb ON
				fb.id=rcb.rf_idFilesBack
						inner join t_RecordCaseBack recb on
				rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
				recb.rf_idRecordCase=rc.id
							inner join t_Case c on
				recb.rf_idCase=c.id
							INNER JOIN (SELECT c1.id
										FROM dbo.t_ErrorProcessControl e INNER JOIN dbo.t_Case c ON
														e.rf_idCase=c.id
																		LEFT JOIN t_case c1 ON
														c.GUID_Case=c1.GUID_Case
														AND c.id<>c1.id																												
										WHERE e.rf_idFile=@idFile							
										)   c1	 ON c.id=c1.id
					
				