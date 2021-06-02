USE RegisterCases
--GO
--/****** Object:  Index [IX_DateEnd_Account_Case]    Script Date: 10/17/2013 09:14:39 ******/
/*
CREATE NONCLUSTERED INDEX IX_DateEnd_Account_Case
ON [dbo].[t_Case] ([DateEnd])
INCLUDE ([id],[GUID_Case],[rf_idV006])
*/
--DROP TABLE t_UnreturnedCaseInAccount
/*
CREATE TABLE t_UnreturnedCaseInAccount
(
	idFileBack int ,id bigint,rf_idV006 tinyint
)

GO
*/
/****** Object:  Index [IX_DateEnd_Account_Case]    Script Date: 10/17/2013 09:14:39 ******/

DECLARE	@year SMALLINT=YEAR(GETDATE())
declare @yearPrev smallint=@year-1
declare	@dateReg DATETIME

SELECT @dateReg=(CASE WHEN @year>2013 THEN cast(@yearPrev as char(4))+'0101' ELSE cast(@year as char(4))+'0101' end) 
		
SELECT f.CodeM,r.NumberRegister,r.PropertyNumberRegister,c.GUID_Case
INTO #tmpAccount
from AccountOMS.dbo.t_File f inner join AccountOMS.dbo.t_RegistersAccounts r on
					f.id=r.rf_idFiles																
							  inner join AccountOMS.dbo.t_RecordCasePatient cb on
					cb.rf_idRegistersAccounts=r.id 
					and	r.ReportYear=2013				
							inner join AccountOMS.dbo.t_Case c on
					c.rf_idRecordCasePatient=cb.id
WHERE f.DateRegistration>@dateReg AND f.DateRegistration<GETDATE()


select fb.id as idFileBack,fb.CodeM,ab.NumberRegister, ab.PropertyNumberRegister,c.GUID_Case,c.id,c.rf_idV006
INTO #tmpRegisterCase
FROM t_FileBack fb inner join t_RegisterCaseBack ab on
					fb.id=ab.rf_idFilesBack	
					AND ab.ReportYear>=@yearPrev
					and ab.ReportYear<=@year						
			INNER JOIN dbo.t_RecordCaseBack rb ON
					ab.id=rb.rf_idRegisterCaseBack
			INNER JOIN dbo.t_CaseBack cb ON
					rb.id=cb.rf_idRecordCaseBack
					AND cb.TypePay=1	
			INNER JOIN dbo.t_Case c ON 
					c.id=rb.rf_idCase
					AND c.DateEnd>=@dateReg
					AND c.DateEnd<=GETDATE()
WHERE fb.DateCreate>@dateReg AND fb.DateCreate<GETDATE()
--очищаю таблицу
TRUNCATE TABLE dbo.t_UnreturnedCaseInAccount

INSERT dbo.t_UnreturnedCaseInAccount( idFileBack ,id,rf_idV006)
SELECT distinct c.idFileBack,c.id,c.rf_idV006
FROM #tmpRegisterCase c LEFT JOIN #tmpAccount a ON
			c.CodeM=a.CodeM
			AND c.NumberRegister=a.NumberRegister
			AND c.GUID_Case=a.GUID_Case
WHERE a.GUID_Case IS NULL
					
GO
DROP TABLE #tmpAccount
DROP TABLE #tmpRegisterCase					