USE AccountOMS
GO
DECLARE @dateStart DATETIME='20210101',
		@dateEnd DATETIME=GETDATE(),
		@dateEndPay DATETIME=GETDATE(),
		@reportYear SMALLINT=2021,
		@reportMonth TINYINT =MONTH(GETDATE())

SELECT DISTINCT c.id AS rf_idCase, f.CodeM, p.AmountDeduction,vu.UnitCode, a.ReportYear,cc.DateBegin,cc.DateEnd,c.rf_idV002 AS Profil
,(CASE WHEN a.ReportMonth<4 THEN 1 WHEN a.ReportMonth>3 AND a.ReportMonth<7 THEN 2 WHEN a.ReportMonth>6 AND a.ReportMonth<10 THEN 3 ELSE 4 END) AS [Quarter]
INTO #t1
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient					
					JOIN dbo.t_PaymentAcceptedCase2 p ON
			c.id=p.rf_idCase			
					JOIN dbo.t_Case_UnitCode_V006 vu ON
			c.id=vu.rf_idCase			
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND p.DateRegistration>@dateStart AND p.DateRegistration<@dateEndPay
AND a.ReportMonth<=@reportMonth AND p.TypeCheckup=1 AND p.AmountDeduction>0

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
		---зачищаем данные
		TRUNCATE TABLE RegisterCases.dbo.t_FactControlFVDeduction
		--вставляем новые данные
		INSERT RegisterCases.dbo.t_FactControlFVDeduction
		SELECT CodeM,ReportYear,[Quarter],UnitCode,codeFV,SUM(AmountDeduction) AS SumAmountDeduction
		FROM #t1 WHERE CodeFV IS NOT NULL
        GROUP BY CodeM,ReportYear,[Quarter],UnitCode,codeFV
		ORDER BY ReportYear,CodeM,[Quarter]
GO 
DROP TABLE #t1