USE RegisterCases
GO
DECLARE @dateStart DATETIME='20210401',
		@dateEnd DATETIME='20210601',
		@dateEndPay DATETIME='20210601',
		@reportYear SMALLINT=2021,
		@reportMonth TINYINT =MONTH(GETDATE())

DECLARE @dtEndReg DATETIME=GETDATE()
/*
	Зачистить таблицу t_FactControlFV перед первым запуском.
	
	Загружает суммы только по принятым к оплате случаям и застрахованным на территориии ВО.
	Запуск данного скрипта должен быть только 1 РАЗ перед запуском проверки в работу!!!!
*/
CREATE TABLE #tmpCases
					(id INT,
					 DateRegistration DATETIME,
					 CodeM CHAR(6), 
					 rf_idCase bigint,
					 AmountPayment decimal(15,2),
					 DateEnd date,
					 rf_idV006 tinyint, 
					 Quantity INT,
					 UnitCode INT,
					 CodeSMO VARCHAR(5)
					 )
/*-------------------------------------------------------------------------------------------------------------------------------------------*/

SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET INTO #tmpMU1 FROM RegisterCases.dbo.vw_sprMU WHERE unitCode IS NOT NULL AND calculationType=1
UNION ALL
SELECT CSGCode AS MU,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE unitCode IS NOT NULL AND calculationType=1

SELECT CSGCode AS MU,beginDate,endDate,UnitCode,ChildUET, AdultUET INTO #tmpMU2  FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE unitCode IS NOT NULL AND calculationType=2
UNION ALL
SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET  FROM RegisterCases.dbo.vw_sprMU WHERE unitCode IS NOT NULL AND calculationType=2

CREATE NONCLUSTERED INDEX IX_MU1 ON #tmpMU1(MU,beginDate,endDate) INCLUDE(ChildUET,AdultUET,unitCode)
CREATE NONCLUSTERED INDEX IX_MU2 ON #tmpMU2(MU,beginDate,endDate) INCLUDE(ChildUET,AdultUET,unitCode)

/*ЗС и КСГ*/
INSERT #tmpCases( id ,DateRegistration ,CodeM ,rf_idCase ,AmountPayment ,DateEnd ,rf_idV006 ,Quantity,UnitCode, CodeSMO)
SELECT f.id,f.DateRegistration,f.CodeM,c.id AS rf_idCase,c.AmountPayment, c.DateEnd,c.rf_idV006,
		CASE WHEN c.IsChildTariff=1 THEN m.Quantity*t1.ChildUET ELSE m.Quantity*t1.AdultUET END ,unitCode , a.rf_idSMO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase	
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase            
					INNER JOIN #tmpMU1 t1  ON
		m.MES=t1.MU			
WHERE  f.DateRegistration>=@dateStart AND f.DateRegistration<=@dtEndReg AND a.ReportYear>=@reportYear AND c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate
	AND a.ReportMonth>3 AND NOT EXISTS(SELECT 1 FROM dbo.t_ErrorProcessControl e WHERE e.rf_idCase=c.id) 
	

INSERT #tmpCases( id ,DateRegistration ,CodeM ,rf_idCase ,AmountPayment ,DateEnd ,rf_idV006 ,Quantity,UnitCode, CodeSMO)
SELECT f.id,f.DateRegistration,f.CodeM,c.id AS rf_idCase,c.AmountPayment, c.DateEnd,c.rf_idV006,1,unitCode, a.rf_idSMO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase	
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase            
					INNER JOIN #tmpMU2 t1 ON
		m.MES=t1.MU			
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<=@dtEndReg AND a.ReportYear>=@reportYear AND c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate
		AND a.ReportMonth>3 AND NOT EXISTS(SELECT 1 FROM dbo.t_ErrorProcessControl e WHERE e.rf_idCase=c.id)
/*-------------------------------------------------------------------------------------------------------------------------------------------*/
/*Медуслуги*/
INSERT #tmpCases( id ,DateRegistration ,CodeM ,rf_idCase ,AmountPayment ,DateEnd ,rf_idV006 ,Quantity,UnitCode, CodeSMO)
SELECT f.id,f.DateRegistration,f.CodeM,c.id AS rf_idCase,c.AmountPayment, c.DateEnd,c.rf_idV006,
		CASE WHEN c.IsChildTariff=1 THEN m.Quantity*t1.ChildUET ELSE m.Quantity*t1.AdultUET END ,unitCode, a.rf_idSMO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase	
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase            
					INNER JOIN RegisterCases.dbo.vw_sprMU t1 ON
		m.MUCode=t1.MU
		AND t1.unitCode IS NOT NULL
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<=@dtEndReg AND a.ReportYear>=@reportYear AND c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND t1.calculationType=1
		AND a.ReportMonth>3 AND NOT EXISTS(SELECT 1 FROM dbo.t_ErrorProcessControl e WHERE e.rf_idCase=c.id)

INSERT #tmpCases( id ,DateRegistration ,CodeM ,rf_idCase ,AmountPayment ,DateEnd ,rf_idV006 ,Quantity,UnitCode, CodeSMO)
SELECT f.id,f.DateRegistration,f.CodeM,c.id AS rf_idCase,c.AmountPayment, c.DateEnd,c.rf_idV006,1,unitCode, a.rf_idSMO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase	
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase            
					INNER JOIN RegisterCases.dbo.vw_sprMU t1 ON
		m.MUCode=t1.MU
		AND t1.unitCode IS NOT NULL
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<=@dtEndReg AND a.ReportYear>=@reportYear AND c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND t1.calculationType=2
		AND a.ReportMonth>3 AND NOT EXISTS(SELECT 1 FROM dbo.t_ErrorProcessControl e WHERE e.rf_idCase=c.id)

--SELECT rf_idCase, UnitCode,rf_idV006 ,DateRegistration ,CodeM,Quantity FROM #tmpCases


SELECT DISTINCT f.id AS rf_idFile,c.id AS rf_idCase, f.CodeM,  a.ReportYear,cc.DateBegin,cc.DateEnd,c.rf_idV002 AS Profil,c1.UnitCode, cc.AmountPayment
,(CASE WHEN a.ReportMonth<4 THEN 1 WHEN a.ReportMonth>3 AND a.ReportMonth<7 THEN 2 WHEN a.ReportMonth>6 AND a.ReportMonth<10 THEN 3 ELSE 4 END) AS [Quarter]
INTO #t1
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase	
					JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCase	
					JOIN dbo.t_RecordCaseBack rb ON
			c.id=rb.rf_idCase
					JOIN dbo.t_CaseBack cb ON
			rb.id=cb.rf_idRecordCaseBack				
					JOIN #tmpCases c1 ON
            c.id=c1.rf_idCase
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND a.ReportMonth>3 AND cb.TypePay=1
	AND EXISTS(SELECT 1 FROM dbo.t_PatientBack pb WHERE pb.rf_idRecordCaseBack=rb.id AND pb.rf_idSMO IN('34001','34002') )

ALTER TABLE #t1 ADD CodeFV SMALLINT
/*
Определяю единицу ФО по алгоритму написанному Антоновой Л.Н

1.	 «без подушевого норматива». Если в медицинской организации не применяется способ оплаты по подушевому нормативу, 
то при выборе единицы ФО всегда выбирается единица ФО с таким значением параметра
*/
IF NOT EXISTS(SELECT 1 
			  FROM dbo.vw_sprT001 l JOIN #t1 t ON
						l.CodeM=l.CodeM
			  WHERE pfa=1 OR pfv=1)
begin
	UPDATE t SET CodeFV=f.CodeFV
	FROM #t1 t JOIN RegisterCases.dbo.vw_sprFOCode_UnitCode f ON
			t.unitCode=f.unitCode
			AND f.[Quarter]=t.[Quarter] 
	WHERE f.TypePF=1 AND t.DateEnd BETWEEN f.dateBeg AND f.dateEnd AND f.YearFV=@reportYear
	PRINT('1.«без подушевого норматива».')
END
/*
2.по подушевому нормативу». Если в медицинской организации применяется способ оплаты по подушевому нормативу и указанный в законченном случае профиль  
  медицинской помощи включен в оплату по подушевому нормативу, то  при выборе единицы ФО всегда выбирается единица ФО с таким значением параметра
*/
ELSE IF EXISTS(SELECT 1 
				FROM dbo.vw_sprT001 l JOIN #t1 t ON
						l.CodeM=l.CodeM
				where (pfa=1 OR pfv=1) 
				)
begin
	UPDATE t SET CodeFV=f.CodeFV
	FROM #t1 t JOIN RegisterCases.dbo.vw_sprFOCode_UnitCode f ON
			t.unitCode=f.unitCode			
				JOIN RegisterCases.dbo.vw_FS_Profil_Calc pc ON
            t.profil=pc.ProfilID    
			AND f.[Quarter]=t.[Quarter] 
	WHERE f.TypePF=2 AND t.DateEnd BETWEEN f.dateBeg AND f.dateEnd AND f.YearFV=@reportYear AND pc.code=2
	PRINT('2. «по подушевого нормативу».')
/*
3. «вне подушевого норматива». Если в медицинской организации применяется способ оплаты по подушевому нормативу и указанный 
	в законченном случае профиль медицинской помощи не включен в оплату по подушевому нормативу, 
	то  при выборе единицы ФО всегда выбирается единица ФО с таким значением параметра
*/
	UPDATE t SET CodeFV=f.CodeFV
	FROM #t1 t JOIN RegisterCases.dbo.vw_sprFOCode_UnitCode f ON
			t.unitCode=f.unitCode
			AND f.[Quarter]=t.[Quarter] 
	WHERE f.TypePF=3 AND t.DateEnd BETWEEN f.dateBeg AND f.dateEnd AND f.YearFV=@reportYear
		AND NOT EXISTS(SELECT 1 FROM  RegisterCases.dbo.vw_FS_Profil_Calc pc WHERE t.profil=pc.ProfilID )
	PRINT('3. «без подушевого норматива».')
END        

PRINT('Вставленно в таблицу t_FactControlFV')

INSERT dbo.t_FactControlFV(CodeM,ReportYear,[quarter],idFile,PropertyNumber,unitCode,CodeFV,SumAmount)
SELECT CodeM,ReportYear,[Quarter],rf_idFile,0 AS PropertyNumber,UnitCode,codeFV,SUM(AmountPayment) AS SumAmountPayment
FROM #t1 
WHERE CodeFV IS NOT NULL
GROUP BY CodeM,ReportYear,[Quarter],rf_idFile,UnitCode,codeFV
ORDER BY ReportYear,CodeM,[Quarter],rf_idFile

PRINT(@@ROWCOUNT)

go
DROP TABLE #tmpCases
go
DROP TABLE #tmpMU1
GO
DROP TABLE #t1
go
DROP TABLE #tmpMU2