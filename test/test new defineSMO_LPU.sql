USE RegisterCases
GO
SET NOCOUNT ON
DBCC freeproccache
GO
SET STATISTICS TIME ON

DECLARE @iteration TINYINT=1
DECLARE @idFile INT=14401

--select @idFile=id from vw_getIdFileNumber where DateRegistration>'20121113' and CountSluch>2000

CREATE TABLE #tPeople
(
	rf_idRefCaseIteration BIGINT,
	PID INT,
    DateEnd DATE
)
DECLARE @tmpCaseDefine AS TABLE
(
	rf_idRefCaseIteration BIGINT,
	DateDefine DATETIME,
	PID INT,
	UniqueNumberPolicy VARCHAR(20),
	IsDefined BIT,
	SMO VARCHAR(5),
	SPolicy VARCHAR(20) ,
	NPolcy VARCHAR(20),
	RN VARCHAR(11),
	rf_idF008 TINYINT,
	DateEnd DATE,
	LPU CHAR(6) DEFAULT '000000'
) 


INSERT #tPeople
SELECT cd.rf_idRefCaseIteration,cd.PID, c.DateEnd
FROM t_CaseDefine cd INNER JOIN t_RefCasePatientDefine r ON
		cd.rf_idRefCaseIteration=r.id
					INNER JOIN t_Case c ON
		r.rf_idCase=c.id
WHERE r.rf_idFiles=@idFile

-----------------Iteraration 1------------------------
IF(@iteration=1)
BEGIN
	INSERT @tmpCaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,DateEnd)
	SELECT TOP 1 WITH TIES t.rf_idRefCaseIteration, GETDATE(), t.PID,p.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,DateEnd
	FROM vw_People p INNER JOIN #tPeople t ON
							p.ID=t.pid
							INNER JOIN vw_Polis pol ON
							p.ID=pol.PID
							 INNER JOIN vw_sprSMO smo ON
							ISNULL(pol.Q,0)=smo.smocod
	WHERE t.pid IS NOT NULL AND t.DateEnd>=pol.DBEG AND t.DateEnd<=pol.DEND AND (pol.Q IS NOT NULL) AND pol.OKATO='18000000000'--т.к. в базе есть люди у которых не определена СМО, хотя ОГРН СМО есть.
	ORDER BY ROW_NUMBER() OVER(PARTITION BY t.rf_idRefCaseIteration,pol.PID ORDER BY pol.DBEG DESC)		
	
END
ELSE
BEGIN
-------------Iteration 3----------------------------
	INSERT @tmpCaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,DateEnd)
	SELECT t.rf_idRefCaseIteration, GETDATE(), t.PID,p.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,DateEnd
	FROM vw_People p INNER JOIN #tPeople t ON
							p.ID=t.pid
							INNER JOIN (
										SELECT TOP 1 WITH TIES t.*
										FROM vw_Polis t INNER JOIN #tPeople t1 ON
													t.PID=t1.PID
													AND t1.DateEnd>=t.DBEG						
										WHERE t.pid IS NOT NULL  
										ORDER BY ROW_NUMBER() OVER(PARTITION BY t.PID ORDER BY t.DBeg DESC)
										)pol ON
							p.ID=pol.PID
	WHERE t.pid IS NOT NULL AND (pol.Q IS NOT NULL) AND pol.OKATO='18000000000'
END			
	UPDATE @tmpCaseDefine
	SET LPU=p.LPU
	FROM @tmpCaseDefine t INNER JOIN t_RefCasePatientDefine r ON
			t.rf_idRefCaseIteration=r.id
						INNER JOIN t_Case c ON
			r.rf_idCase=c.id
						INNER JOIN t_RecordCase rc ON
			c.rf_idRecordCase=rc.id
			AND rc.IsChild=0
						INNER JOIN (
										SELECT  TOP 1 WITH TIES t.rf_idRefCaseIteration,t.PID, ISNULL(LPU,'000000') AS LPU
										FROM vw_PeopleDefineLPU p INNER JOIN #tPeople t ON
														p.ID=t.pid
										WHERE t.pid IS NOT NULL AND t.DateEnd>=ISNULL(p.LPUDT,'20120101')
										ORDER BY ROW_NUMBER() OVER(PARTITION BY t.rf_idRefCaseIteration,t.PID ORDER BY p.LPUDT DESC)
										) p ON
			t.rf_idRefCaseIteration=p.rf_idRefCaseIteration
			AND t.PID=p.PID
						
			
SELECT * FROM @tmpCaseDefine

SET STATISTICS TIME OFF
GO
DROP TABLE #tPeople