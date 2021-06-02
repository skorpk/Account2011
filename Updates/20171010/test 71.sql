USE RegisterCases
GO
DECLARE @CaseDefined TVP_CasePatient ,		
		@idFile int	=99767


select @idFile=f.id from t_File f WHERE f.TypeFile='H' AND f.DateRegistration>'20170501' AND f.DateRegistration<GETDATE() AND CountSluch>4000 ORDER BY NEWID()

SELECT * FROM dbo.vw_getFileBack WHERE rf_idFiles=@idFile					   

	
declare @tError as table(rf_idCase bigint,ErrorNumber smallint)

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

INSERT @CaseDefined
SELECT rf.rf_idCase,rf.rf_idRegisterPatient
FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
				rf.id=i.rf_idRefCaseIteration		          
WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration>1				                          

--SELECT cd.*,c.rf_idV006
--FROM @CaseDefined cd INNER JOIN dbo.t_Case c ON
--		cd.rf_idCase=c.id
--WHERE rf_idV006=1


IF EXISTS(SELECT 1 FROM dbo.t_File WHERE id=@idFile AND TypeFile='H')
BEGIN 
		----проверка на дулированность случая по пациенту в РС H от 10/10/2017
		CREATE TABLE #tabStac(rf_idCase bigint,IdStep TINYINT,ENP VARCHAR(16),DateBeg DATE,DateEnd DATE,NewBorn VARCHAR(9),DS1 VARCHAR(9),rf_idFile INT, NumberCase INT, rf_idV006 tinyint)
		--собираем данные по файлу
		--данные по застрахованным определенным на 1-ом этапе
		INSERT #tabStac
		SELECT rf.rf_idCase,1,pb.UniqueNumberPolicy,c.DateBegin,c.DateEnd,r.NewBorn,d.DiagnosisCode, @idFile, c.idRecordCase,c.rf_idV006
		FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
						rf.id=i.rf_idRefCaseIteration
										INNER JOIN t_Case c ON
						rf.rf_idCase=c.id		          
										INNER JOIN dbo.t_RecordCase r ON
						c.rf_idRecordCase=r.id
										 INNER JOIN dbo.t_RecordCaseBack rb ON
							c.id=rb.rf_idCase								
										 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
										INNER JOIN dbo.t_CaseDefine pb ON
							rp.id=pb.rf_idRefCaseIteration 							
										INNER JOIN dbo.t_Diagnosis d ON
							c.id=d.rf_idCase
							AND d.TypeDiagnosis=1			                                      
		WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration=1	AND c.rf_idV006 <3

		---для данных вернувшихся из ФФОМС
		INSERT #tabStac
		SELECT rf.rf_idCase,2,pb.UniqueNumberPolicy,c.DateBegin,c.DateEnd,r.NewBorn,d.DiagnosisCode, @idFile, c.idRecordCase,c.rf_idV006
		FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
						rf.id=i.rf_idRefCaseIteration
										INNER JOIN @CaseDefined cd ON
						rf.rf_idCase=cd.rf_idCase 
										INNER JOIN t_Case c ON
						rf.rf_idCase=c.id              
										INNER JOIN dbo.t_RecordCase r ON
						c.rf_idRecordCase=r.id
										 INNER JOIN dbo.t_RecordCaseBack rb ON
							c.id=rb.rf_idCase								
										 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
										INNER JOIN dbo.t_CaseDefineZP1Found pb ON
							rp.id=pb.rf_idRefCaseIteration 							
										INNER JOIN dbo.t_Diagnosis d ON
							c.id=d.rf_idCase
							AND d.TypeDiagnosis=1			               
		WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration>1 AND c.rf_idV006<3				                          

		------------------------------------------------------------------
		----проверка на дулированность случая по пациенту в РС F
			;WITH cteDouble
			AS
			(  
			SELECT ROW_NUMBER() OVER(PARTITION BY s1.ENP,DateBeg,DateEnd,DS1,NewBorn,rf_idV006 ORDER BY s1.IdStep,s1.NumberCase ASC) AS idRow, s1.rf_idCase,s1.NumberCase,s1.ENP				
			from #tabStac s1
			)
			insert @tError 
			SELECT distinct rf_idCase,71 FROM cteDouble WHERE idRow>1
END
GO
DROP TABLE #tabStac