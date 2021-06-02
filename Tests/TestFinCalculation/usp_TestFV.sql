USE RegisterCases
GO
IF OBJECT_ID('usp_TestFV',N'P') IS NOT NULL
	DROP PROCEDURE usp_TestFV
go
CREATE PROCEDURE usp_TestFV
				@idFile INT,
				@month tinyint,
				@year smallint,
				@codeLPU char(6)        
/*
	���������������� ������� � ������� 
*/				        
AS
/*
�������� ������ � ������� #t1
*/
DECLARE @quarter TINYINT=(CASE WHEN @month<4 THEN 1 WHEN @month>3 AND @month<7 THEN 2 WHEN @month>6 AND @month<10 THEN 3 ELSE 4 END) --����������� �������


UPDATE #t1 set IsGood=2 WHERE TotalRest<0
/*
	�������� ������� ������� ���������� ��������������� �������� ������� ����������� �����������
	����� ������� ���� ������, ����� ������ �� ������ ������� �� ������ � ������ 62( �.� � TotalRest>=0) � ���������� ���������� �������
*/
UPDATE t SET t.dateEnd=cc.DateEnd, DateBegin=cc.DateBegin,rf_idRecordCase=c.rf_idRecordCase,AmountPayment=cc.AmountPayment,Profil=c.rf_idV002
FROM #t1 t JOIN dbo.t_Case c ON
	t.rf_idCase=c.id	
			JOIN dbo.t_CompletedCase cc ON
     c.rf_idRecordCase=cc.rf_idRecordCase 
WHERE IsGood=1

/*
��������� ������� �� �� ��������� ����������� ��������� �.�

1.	 ���� ���������� ���������. ���� � ����������� ����������� �� ����������� ������ ������ �� ���������� ���������, 
�� ��� ������ ������� �� ������ ���������� ������� �� � ����� ��������� ���������
*/
IF NOT EXISTS(SELECT 1 FROM dbo.vw_sprT001 WHERE CodeM=@codeLPU AND (pfa=1 OR pfv=1) )
begin
	UPDATE t SET CodeFV=f.CodeFV
	FROM #t1 t JOIN dbo.vw_sprFOCode_UnitCode f ON
			t.unitCode=f.unitCode
	WHERE f.TypePF=1 AND f.[Quarter]=@quarter AND t.DateEnd BETWEEN f.dateBeg AND f.dateEnd AND IsGood=1 AND f.YearFV=@year
	PRINT('1.���� ���������� ���������.')
END
/*
2.�� ���������� ���������. ���� � ����������� ����������� ����������� ������ ������ �� ���������� ��������� � ��������� � ����������� ������ �������  
  ����������� ������ ������� � ������ �� ���������� ���������, ��  ��� ������ ������� �� ������ ���������� ������� �� � ����� ��������� ���������
*/
ELSE IF EXISTS(SELECT 1 FROM dbo.vw_sprT001 WHERE CodeM=@codeLPU AND (pfa=1 OR pfv=1) )
begin
	UPDATE t SET CodeFV=f.CodeFV
	FROM #t1 t JOIN dbo.vw_sprFOCode_UnitCode f ON
			t.unitCode=f.unitCode			
				JOIN dbo.vw_FS_Profil_Calc pc ON
            t.profil=pc.ProfilID    
	WHERE f.TypePF=2 AND f.[Quarter]=@quarter AND t.DateEnd BETWEEN f.dateBeg AND f.dateEnd AND IsGood=1 AND f.YearFV=@year AND pc.code=2
	PRINT('2. ��� ���������� ���������.')
/*
3. ���� ���������� ���������. ���� � ����������� ����������� ����������� ������ ������ �� ���������� ��������� � ��������� 
	� ����������� ������ ������� ����������� ������ �� ������� � ������ �� ���������� ���������, 
	��  ��� ������ ������� �� ������ ���������� ������� �� � ����� ��������� ���������
*/		
	UPDATE t SET CodeFV=f.CodeFV
	FROM #t1 t JOIN dbo.vw_sprFOCode_UnitCode f ON
			t.unitCode=f.unitCode
	WHERE f.TypePF=3 AND f.[Quarter]=@quarter AND t.DateEnd BETWEEN f.dateBeg AND f.dateEnd AND IsGood=1 AND f.YearFV=@year
		AND NOT EXISTS(SELECT 1 FROM  dbo.vw_FS_Profil_Calc pc WHERE t.profil=pc.ProfilID )
	PRINT('3. ���� ���������� ���������.')
END        
/*
	������ ��� ������� ������ � ��������� �������
*/
SELECT DISTINCT idRecordCase,unitCode,CodeFV,DateBegin,DateEnd,TotalPriceFV,rf_idRecordCase,AmountPayment 
INTO #tFV
FROM #t1
ORDER BY DateEnd asc,DateBegin asc,AmountPayment DESC,idRecordCase asc

SELECT distinct v.unitCode,v.CodeFV,v.SumFV,v.[Quarter]
INTO #tmpPlanFV
FROM dbo.vw_sprFS_SUM_MO v JOIN #tFV t ON
		v.unitCode=t.unitCode
		AND v.CodeFV=t.CodeFV
		AND v.CodeM=@codeLPU				
		AND v.YearFV=@year
WHERE v.[Quarter]=@quarter

--����������� ��������� ���������� ����� ��, ����� ���� ������� �� ����� ����� �� ��� ������� �������� 
UPDATE p SET p.SumFV=p.SumFV-v.SumAmount
FROM #tmpPlanFV p JOIN (
						SELECT v.unitCode,v.CodeFV,SUM(v.SumAmount) AS SumAmount
						FROM dbo.t_FactControlFV v 
						WHERE v.ReportYear=@year AND v.[quarter]=@quarter AND v.CodeM=@codeLPU
						GROUP BY v.unitCode,v.CodeFV
						UNION ALL
                        SELECT v.unitCode,v.CodeFV,-SUM(v.SumAmountDeduction) AS SumAmount
						FROM dbo.t_FactControlFVDeduction v 
						WHERE v.ReportYear=@year AND v.[quarter]=@quarter AND v.CodeM=@codeLPU
						GROUP BY v.unitCode,v.CodeFV
					 ) v ON
           v.unitCode = p.UnitCode
		   AND v.CodeFV=p.CodeFV




	--������� ����������� ����
		declare cPlanFS cursor for
			select f.UnitCode,f.CodeFV,f.SumFV from #tmpPlanFV f ORDER BY f.unitCode,f.CodeFV
		declare @unitCode int,@codeFV int, @totalPlanFV decimal(15,2)
		open cPlanFS
		fetch next from cPlanFS into @unitCode,@codeFV,@totalPlanFV
		while @@FETCH_STATUS = 0
		begin					
			update #tFV set @totalPlanFV=TotalPriceFV=@totalPlanFV-AmountPayment where unitCode=@unitCode AND CodeFV=@codeFV
			
			fetch next from cPlanFS into @unitCode,@codeFV,@totalPlanFV
		end
		close cPlanFS
		deallocate cPlanFS
		-----------------------------------
		/*
			���������� ������� ������ � �������������� �������, ��� ������������ ������������� ��� �������� ��
			PropertyNumber- ��� ���� ������ �� � �� ����� �-1 ��� -0, �� ������ 1. ���� ����� ����������� �������� �� ������ 2
		*/
		IF NOT EXISTS(SELECT 1 FROM dbo.t_FactControlFV WHERE idFile=@idFile)
		BEGIN
			/*
			���������������� �������
			*/
			--INSERT dbo.t_FactControlFV(CodeM,ReportYear,[quarter],idFile,PropertyNumber,unitCode,CodeFV,SumAmount)		
			SELECT @codeLPU AS CodeM,@year AS ReportYear,@quarter,@idFile,1,unitCode,CodeFV,sum(AmountPayment) AS SumAmount
			FROM #tFV 
			WHERE TotalPriceFV>=0 
			GROUP BY unitCode,CodeFV
		END
        ELSE
		BEGIN
			/*
			���������������� �������
			*/
			--INSERT dbo.t_FactControlFV(CodeM,ReportYear,quarter,idFile,PropertyNumber,unitCode,CodeFV,SumAmount)		
			SELECT @codeLPU AS CodeM,@year AS ReportYear,@quarter,@idFile,2,unitCode,CodeFV,sum(AmountPayment) AS SumAmount
			FROM #tFV  t
			WHERE TotalPriceFV>=0 
			GROUP BY unitCode,CodeFV 
		end		 	
		-----��������� ������ �� ������� �������� �������� ��
		/*
			���������������� �������
			*/
		--insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
		SELECT DISTINCT 323,@idFile,c.id
		FROM #tFV f JOIN t_Case c ON
				f.rf_idRecordCase=c.rf_idRecordCase
		WHERE f.TotalPriceFV<0 


DROP TABLE #tmpPlanFV
DROP TABLE #tFV
GO
GRANT EXECUTE ON usp_TestFV TO db_RegisterCase
go