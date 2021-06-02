USE AccountOMS
GO
CREATE TABLE #tCase(CodeM CHAR(6), Account VARCHAR(15),Letter CHAR(1), rf_idCase BIGINT)

INSERT #tCase( CodeM, Account, Letter, rf_idCase )
SELECT f.CodeM,a.Account,a.Letter,c.id 
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCasePatient
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20140531' AND a.ReportYear=2014

SELECT c.CodeM,c.Account,COUNT(c.rf_idCase)
FROM #tCase c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase
WHERE NOT EXISTS(SELECT MU,AccountParam from vw_MUCSGLetter WHERE MU=m.MES AND ISNULL(AccountParam,c.Letter)=c.Letter)
GROUP BY c.CodeM,c.Account

SELECT DISTINCT c.CodeM,c.Account
FROM #tCase c INNER JOIN dbo.t_Meduslugi m ON
		c.rf_idCase=m.rf_idCase
WHERE NOT EXISTS(SELECT MU,AccountParam from vw_MUCSGLetter WHERE MU=m.MU AND ISNULL(AccountParam,c.Letter)=c.Letter) AND m.Price>0

GO

DROP TABLE #tCase