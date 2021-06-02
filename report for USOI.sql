USE AccountOMS
GO
--DROP INDEX IX_MU_Quantity_V002 ON dbo.t_Meduslugi
--CREATE NONCLUSTERED INDEX IX_MU_Quantity_V002
--ON [dbo].[t_Meduslugi] ([MUGroupCode],[MUUnGroupCode])
--INCLUDE ([rf_idCase],[rf_idV002],[Quantity]) WITH (ONLINE=ON)
--GO

DECLARE @dateBegin DATETIME='20130101',
		@dateEnd DATETIME='20130812 23:59:59',
		@monthSatrt tinyint=1,
		@monthEnd tinyint=6
		
DECLARE @tMU AS TABLE(MUGroupCode TINYINT, MUUnGroupCode TINYINT)
INSERT @tMU( MUGroupCode, MUUnGroupCode )
VALUES	( 70,3),( 70,5),( 70,6),( 72,1),( 72,2),( 72,3),( 72,4)

CREATE TABLE #tmpCaseMU 
(
	id BIGINT,
	AmountPayment DECIMAL(15,2),
	rf_idV002 SMALLINT,
	Quantity DECIMAL(6,2),
	IsAdult TINYINT,
	MU varchar(16),
	MUName varchar(255)
)		
INSERT #tmpCaseMU( id ,AmountPayment ,rf_idV002 ,Quantity ,IsAdult,MU,MUName)
SELECT c.id, c.AmountPayment, m.rf_idV002, m.Quantity,CASE WHEN c.Age>17 THEN 1 ELSE 0 END AS IsAdult,mes.MES,mu.MUName
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportYear=2013
					AND a.ReportMonth>=@monthSatrt AND a.ReportMonth<=@monthEnd
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts						  
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.IsCompletedCase=1
					AND c.DateEnd<=@dateEnd
					AND c.DateEnd>='20130101'
							INNER JOIN dbo.t_MES mes ON
					c.id=mes.rf_idCase
							INNER JOIN dbo.vw_sprMUCompletedCase mu ON
					mes.MES=mu.MU
							INNER JOIN @tMU m1 ON
					mu.MUGroupCode=m1.MUGroupCode
					AND mu.MUUnGroupCode=m1.MUUnGroupCode
							INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase
WHERE m.MUGroupCode=2 AND m.MUUnGroupCode=3 AND f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEnd

----------------Report 1----------------
SELECT v002.name,SUM(t.Quantity)
		,ISNULL(SUM(CASE isnull(IsAdult,0) WHEN 1 THEN t.Quantity END),0) AS CountAdult,
		isnull(SUM(CASE isnull(IsAdult,0) WHEN 0 THEN t.Quantity END),0) AS CountChild
FROM #tmpCaseMU t INNER JOIN RegisterCases.dbo.vw_sprV002 v002 ON
			t.rf_idV002=v002.id
GROUP BY v002.name

SELECT t.MU,t.MUName,count(t.id) AS CountCase,SUM(t.SumQuantity) AS Quntity,SUM(t.AmountPayment)
FROM (
		SELECT MU,MUName,t.id,SUM(t.Quantity) AS SumQuantity,t.AmountPayment
		FROM #tmpCaseMU t
		GROUP BY MU,MUName,t.id,t.AmountPayment
	) t
GROUP BY t.MU,t.MUName
ORDER BY MU

GO
DROP TABLE #tmpCaseMU

