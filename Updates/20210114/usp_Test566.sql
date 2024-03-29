USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test566]    Script Date: 26.01.2021 8:49:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test566]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

---------------------------------------------------------------------------
--с 2019 года новая единая проверка суммы случая
IF @year<2021
begin
		;WITH cteSUM
		AS(
		SELECT c.id  AS rf_idCase,c.AmountPayment, 
			CASE WHEN c.IT_SL IS not NULL or k.ValueKiro IS NOT NULL THEN CAST(CAST(mes.Tariff* ISNULL(c.IT_SL,1) AS DECIMAL(15,0) )*ISNULL(k.ValueKiro ,1) AS DECIMAL(15,0))+SUM(m.TotalPrice)
				ELSE mes.tariff+SUM(m.TotalPrice) END AS SUM_M
		from dbo.t_File f INNER JOIN t_RegistersCase a ON
					f.id=a.rf_idFiles
						inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
								inner join t_MES mes on
					c.id=mes.rf_idCase
								INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase              			        
							LEFT JOIN dbo.t_Kiro k ON
					c.id=k.rf_idCase   
		WHERE f.TypeFile='H' 
		GROUP BY c.id,c.AmountPayment,mes.Tariff, c.IT_SL,k.ValueKiro,CAST(CAST(mes.Tariff* ISNULL(c.IT_SL,1) AS DECIMAL(15,0) )*ISNULL(k.ValueKiro ,1) AS DECIMAL(15,0))
		UNION ALL
		SELECT c.id  AS rf_idCase,c.AmountPayment,SUM(m.TotalPrice) AS SUM_M
		from dbo.t_File f INNER JOIN t_RegistersCase a ON
					f.id=a.rf_idFiles
						 inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
								inner join t_Case c on
					r.id=c.rf_idRecordCase				
								INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase              			        					 
		WHERE c.IsCompletedCase=0 AND f.TypeFile='H'
		GROUP BY c.id,c.AmountPayment
		)
		insert #tError
		select c.rf_idCase,566 
		FROM cteSUM c
		WHERE c.AmountPayment<>SUM_M 

		insert #tError
		SELECT DISTINCT c.id,566
		FROM dbo.t_File f INNER JOIN t_RegistersCase a ON
					f.id=a.rf_idFiles
						inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
								inner join t_Case c on
					r.id=c.rf_idRecordCase							
								inner join t_MES mes on
					c.id=mes.rf_idCase
								INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase              			        
		WHERE m.TotalPrice<>0.0 AND mes.Tariff<>0.0 AND mes.MES IS NULL AND f.TypeFile='H'

		insert #tError
		SELECT DISTINCT c.id,566
		from dbo.t_File f INNER JOIN t_RegistersCase a ON
					f.id=a.rf_idFiles
						inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
								inner join t_Case c on
					r.id=c.rf_idRecordCase							
								inner join t_MES mes on
					c.id=mes.rf_idCase
								INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase              			        
		WHERE m.TotalPrice<>0.0 AND mes.Tariff<>0.0 AND mes.MES IS NOT NULL AND m.MUCode NOT LIKE '60.3.%' AND f.TypeFile='H'  


		insert #tError
		SELECT DISTINCT c.id,566
		from dbo.t_File f INNER JOIN t_RegistersCase a ON
					f.id=a.rf_idFiles
						 inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
								inner join t_MES mes on
					c.id=mes.rf_idCase
								INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase              			        
		WHERE m.MUCode LIKE '60.3.%' AND m.TotalPrice=0 AND f.TypeFile='H'
END
ELSE 
BEGIN
-----------------------------------------Стоимость случая с 2021----------------------------------
	;WITH cteSUM
		AS(
		SELECT c.id  AS rf_idCase,c.AmountPayment, 
			CASE WHEN c.IT_SL IS not NULL or k.ValueKiro IS NOT NULL THEN CAST(CAST(mes.Tariff* ISNULL(c.IT_SL,1) AS DECIMAL(15,0) )*ISNULL(k.ValueKiro ,1) AS DECIMAL(15,0))+SUM(m.TotalPrice)
				ELSE mes.tariff+SUM(m.TotalPrice) END AS SUM_M
		from dbo.t_File f INNER JOIN t_RegistersCase a ON
					f.id=a.rf_idFiles
						inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
								inner join dbo.t_CompletedCase cc on
					r.id=cc.rf_idRecordCase
								inner join t_MES mes on
					c.id=mes.rf_idCase
								INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase              			        
							LEFT JOIN dbo.t_Kiro k ON
					c.id=k.rf_idCase   
		WHERE f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprCSGWage w WHERE w.code=mes.MES AND cc.DateEnd BETWEEN w.dateBeg AND w.dateEnd) ---new 2021
		GROUP BY c.id,c.AmountPayment,mes.Tariff, c.IT_SL,k.ValueKiro,CAST(CAST(mes.Tariff* ISNULL(c.IT_SL,1) AS DECIMAL(15,0) )*ISNULL(k.ValueKiro ,1) AS DECIMAL(15,0))
		UNION ALL
        SELECT c.id  AS rf_idCase,c.AmountPayment, 
			CASE WHEN c.IT_SL IS not NULL or k.ValueKiro IS NOT NULL THEN CAST(CAST(mes.Tariff* ISNULL(c.IT_SL,1) AS DECIMAL(15,0) )*ISNULL(k.ValueKiro ,1) AS DECIMAL(15,0))+SUM(m.TotalPrice)
				ELSE mes.tariff+SUM(m.TotalPrice) END AS SUM_M
		from dbo.t_File f INNER JOIN t_RegistersCase a ON
					f.id=a.rf_idFiles
						inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
								inner join t_MES mes on
					c.id=mes.rf_idCase
								inner join dbo.t_CompletedCase cc on
					r.id=cc.rf_idRecordCase
								INNER JOIN dbo.vw_sprCSGWage w ON
					w.code=mes.MES	
					AND cc.DateEnd BETWEEN w.dateBeg AND w.dateEnd
								INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase              			        
							LEFT JOIN dbo.t_Kiro k ON
					c.id=k.rf_idCase   
		WHERE f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.t_SLK s WHERE s.rf_idCase=c.id AND s.SL_K=1)---new 2021
		GROUP BY c.id,c.AmountPayment,mes.Tariff, c.IT_SL,k.ValueKiro,CAST(CAST(mes.Tariff* ISNULL(c.IT_SL,1) AS DECIMAL(15,0) )*ISNULL(k.ValueKiro ,1) AS DECIMAL(15,0))
		UNION ALL
		SELECT c.id  AS rf_idCase,c.AmountPayment,SUM(m.TotalPrice) AS SUM_M
		from dbo.t_File f INNER JOIN t_RegistersCase a ON
					f.id=a.rf_idFiles
						 inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
								inner join t_Case c on
					r.id=c.rf_idRecordCase				
								INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase              			        					 
		WHERE c.IsCompletedCase=0 AND f.TypeFile='H'
		GROUP BY c.id,c.AmountPayment
		)
		insert #tError
		select c.rf_idCase,566 
		FROM cteSUM c
		WHERE c.AmountPayment<>SUM_M 	
		--------------------------------------------new 2021--------------------------------------------------------
		;WITH cteSUM
		AS(
		SELECT c.id  AS rf_idCase,c.AmountPayment, 
			 CAST(CAST(CAST(CAST(b.price AS DECIMAL(18,5))*CAST(kz.coefficient AS DECIMAL(18,5)) AS decimal(18,1)) *
				CAST(( (1-cast(w.coefficient AS DECIMAL(18,5)) ) + CAST(CAST(CAST(w.coefficient *men.coefficient AS DECIMAL(18,5))*t1.coefficient AS DECIMAL(18,5))* ISNULL(c.IT_SL,1) AS DECIMAL(18,5)) ) AS DECIMAL(18,5)) AS DECIMAL(18,0) )
				*ISNULL(k.ValueKiro ,1) AS DECIMAL(18,0) ) AS SUM_M
		from dbo.t_File f INNER JOIN t_RegistersCase a ON
					f.id=a.rf_idFiles
						inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
								inner join dbo.t_CompletedCase cc on
					r.id=cc.rf_idRecordCase
								inner join t_MES mes on
					c.id=mes.rf_idCase
								INNER JOIN dbo.vw_sprCSGWage w ON
					w.code=mes.MES	
					AND cc.DateEnd BETWEEN w.dateBeg AND w.dateEnd
								INNER JOIN dbo.t_SLK s ON
                    c.id=s.rf_idCase
								INNER JOIN oms_nsi.dbo.tCSGBasePrice b ON
                    c.rf_idV006=b.rf_MSConditionId
					AND cc.DateEnd BETWEEN b.dateBeg AND b.dateEnd
								INNER JOIN dbo.vw_tCSGResourceConsuming kz ON
                    mes.MES=kz.code								
					AND cc.DateEnd BETWEEN kz.dateBeg AND kz.dateEnd
								INNER JOIN dbo.vw_tCSGManagement men ON
                    mes.MES=men.code								
					AND cc.DateEnd BETWEEN men.dateBeg AND men.dateEnd
								inner join dbo.vw_CSGLevel t1 on
						c.rf_idMO =t1.CodeM
						AND ISNULL(c.rf_idDepartmentMO,0)=ISNULL(t1.DeptCode,0)
						and c.rf_idV006=t1.rf_idV006
						and cc.DateEnd BETWEEN t1.DateBegin AND t1.DateEnd
						and cc.DateEnd BETWEEN t1.DateBegLevel AND t1.DateEndLevel
							LEFT JOIN dbo.t_Kiro k ON
					c.id=k.rf_idCase   
		WHERE f.TypeFile='H' AND s.SL_K=1		
		)
		insert #tError
		select c.rf_idCase,566 
		FROM cteSUM c
		WHERE c.AmountPayment<>SUM_M 
END
