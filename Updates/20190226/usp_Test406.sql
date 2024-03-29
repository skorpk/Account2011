USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test406]    Script Date: 26.02.2019 9:14:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test406]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
/*
Если перечень КИРО пуст, а КИРО в случае присутствует, то выдается ошибка
*/
insert #tError
select DISTINCT m.rf_idCase,406
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'						
						INNER JOIN (values(1,31,33),(2,43,null)) v(idV006,idV008, idV010) ON
			c.rf_idV006=v.idV006
			AND c.rf_idV008=v.idV008
			AND c.rf_idV010=ISNULL(v.idV010,c.rf_idV010)
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_sprCSG_KIRO k ON
			m.MES=k.KSG
						INNER JOIN dbo.t_Kiro k1 ON
			k1.rf_idCase=c.id
WHERE k.KIRO IS NULL 

/*
(USL_OK=1 И VIDPOM=31 И IDSP=33 и количество услуг из класса 1.11.* меньше 4) 
или (USL_OK=2 И IDSP=43 и количество услуг из класса 55.*.* меньше 4),  
то КИРО должен присутствовать обязательно 
*/
---стационар

;WITH cte 
AS(
	SELECT c.id,SUM(m.Quantity) AS Quantity
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20180101'	
				AND c.DateEnd<'20190101'					
							INNER JOIN (values(1,31,33)) v(idV006,idV008, idV010) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
				AND c.rf_idV010=v.idV010
								INNER JOIN dbo.t_MES me ON
			c.id=me.rf_idCase
						INNER JOIN dbo.vw_sprCSG_KIRO k ON
			me.MES=k.KSG
							INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase
	WHERE m.MUCode LIKE '1.11.%' AND k.KIRO IS NOT NULL
	GROUP BY c.id									
)
insert #tError
select DISTINCT id,406 FROM cte c WHERE Quantity<4 AND NOT EXISTS(SELECT 1 FROM dbo.t_Kiro WHERE rf_idCase=c.id)
--дневной стационар
;WITH cte 
AS(
	SELECT c.id,SUM(m.Quantity) AS Quantity
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20180101'						
							INNER JOIN (values(2,43)) v(idV006,idV008) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
								INNER JOIN dbo.t_MES me ON
			c.id=me.rf_idCase
						INNER JOIN dbo.vw_sprCSG_KIRO k ON
			me.MES=k.KSG              
							INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase
	WHERE m.MUCode LIKE '55.%' AND k.KIRO IS NOT NULL
	GROUP BY c.id									
)
insert #tError
select DISTINCT id,406 FROM cte c WHERE Quantity<4 AND NOT EXISTS(SELECT 1 FROM dbo.t_Kiro WHERE rf_idCase=c.id)

/*
•	проводится проверка соответствия кода КИРО(CODE_KIRO) кодам КИРО, соответствующим представленной в случае КСГ (если не соответствует, то ошибка);
*/
insert #tError
select DISTINCT m.rf_idCase,406
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'	
						INNER JOIN (values(1,31,33),(2,43,null)) v(idV006,idV008, idV010) ON
			c.rf_idV006=v.idV006
			AND c.rf_idV008=v.idV008
			AND c.rf_idV010=ISNULL(v.idV010,c.rf_idV010)											
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_sprCSG_KIRO k ON
			m.MES=k.KSG
						INNER JOIN dbo.t_Kiro k1 ON
			k1.rf_idCase=c.id
WHERE k.KIRO IS NOT NULL AND NOT EXISTS( SELECT 1 FROM dbo.vw_sprCSG_KIRO k WHERE k.KSG=m.MES AND k1.rf_idKiro=k.KIRO)

/*
проверяется, что на дату окончания лечения указанный код КИРО является действующим;
*/

insert #tError
select DISTINCT m.rf_idCase,406
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'												
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_sprCSG_KIRO k ON
			m.MES=k.KSG
						INNER JOIN dbo.t_Kiro k1 ON
			k1.rf_idCase=c.id
			AND k1.rf_idKiro=k.KIRO
WHERE k.KIRO IS NOT NULL AND c.DateEnd<k.dateBegKIRO OR c.DateEnd>k.dateEndKIRO
/*
проверяется, что для представленного кода КИРО значение, указанное в VAL_K, является действующим на дату окончания лечения
*/
insert #tError
select DISTINCT m.rf_idCase,406
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'												
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_sprCSG_KIRO k ON
			m.MES=k.KSG
						INNER JOIN dbo.t_Kiro k1 ON
			k1.rf_idCase=c.id
			AND k1.rf_idKiro=k.KIRO			
WHERE k.KIRO IS NOT NULL AND k1.ValueKiro<>k.COEF

insert #tError
select DISTINCT m.rf_idCase,406
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'												
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_sprCSG_KIRO k ON
			m.MES=k.KSG
						INNER JOIN dbo.t_Kiro k1 ON
			k1.rf_idCase=c.id
			AND k1.rf_idKiro=k.KIRO
			AND k1.ValueKiro=k.COEF
WHERE k.KIRO IS NOT NULL AND c.DateEnd<k.dateBegCoef OR c.DateEnd>k.dateECoef



/*
Если КИРО=1, то проверяется выполнение условия: (USL_OK=1 И VIDPOM=31 И IDSP=33 и количество услуг из класса 1.11.* меньше 4) 
или (USL_OK=2 И IDSP=43 и количество услуг из класса 55.*.* меньше 4), 
то КИРО=1 в SL должно присутствовать обязательно.
Если КИРО=2, то проверяется выполнение условия: (USL_OK=1 И VIDPOM=31 И IDSP=33 и количество услуг из класса 1.11.* меньше 4) или (USL_OK=2 И IDSP=43 и количество услуг из класса 55.*.* меньше 4), 
то КИРО=2 в SL должно присутствовать обязательно
*/
;WITH cte 
AS(
	SELECT ROW_NUMBER() OVER(PARTITION BY c.rf_idRecordCase ORDER BY c.DateBegin DESC, c.DateEnd desc) AS idRow,c.id,SUM(m.Quantity) AS Quantity
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'						
							INNER JOIN (values(1,31,33)) v(idV006,idV008, idV010) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
				AND c.rf_idV010=v.idV010
								INNER JOIN dbo.t_MES me ON
			c.id=me.rf_idCase
						INNER JOIN dbo.vw_sprCSG_KIRO k ON
			me.MES=k.KSG
							INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase
	WHERE m.MUCode LIKE '1.11.%' AND k.KIRO IN (1,2)
	GROUP BY c.id,c.rf_idRecordCase,c.DateBegin,c.DateEnd
)
insert #tError
select DISTINCT id,406 FROM cte c WHERE idRow=1 AND Quantity<4 AND NOT EXISTS(SELECT 1 FROM dbo.t_Kiro WHERE rf_idCase=c.id AND rf_idKiro IN(1,2))

--дневной стационар
;WITH cte 
AS(
	SELECT ROW_NUMBER() OVER(PARTITION BY c.rf_idRecordCase ORDER BY c.DateBegin DESC, c.DateEnd desc) AS idRow,c.id,SUM(m.Quantity) AS Quantity
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'						
							INNER JOIN (values(2,43)) v(idV006,idV008) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
								INNER JOIN dbo.t_MES me ON
			c.id=me.rf_idCase
						INNER JOIN dbo.vw_sprCSG_KIRO k ON
			me.MES=k.KSG              
							INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase
	WHERE m.MUCode LIKE '55.%' AND k.KIRO IN(1,2)
	GROUP BY c.id,c.rf_idRecordCase,c.DateBegin,c.DateEnd	
)
insert #tError
select DISTINCT id,406 FROM cte c WHERE idRow=1 AND Quantity<4 AND NOT EXISTS(SELECT 1 FROM dbo.t_Kiro WHERE rf_idCase=c.id AND rf_idKiro IN(1,2))

/*
Если КИРО=3, то проверяется выполнение условия: (USL_OK=1 И VIDPOM=31 И IDSP=33 и количество услуг из класса 1.11.* больше 3 И RSLT in (102, 105, 107, 110)) 
или (USL_OK=2 И IDSP=43 и количество услуг из класса 55.*.* больше 3 И RSLT in (202, 205, 207)), то КИРО=3 в SL должно присутствовать обязательно.


Если КИРО=4, то проверяется выполнение условия: (USL_OK=1 И VIDPOM=31 И IDSP=33 и количество услуг из класса 1.11.* больше 3 И RSLT in (102, 105, 107, 110)) 
или (USL_OK=2 И IDSP=43 и количество услуг из класса 55.*.* больше 3 И RSLT in (202, 205, 207)), то КИРО=4 в SL должно присутствовать обязательно.

*/

;WITH cte 
AS(
	SELECT ROW_NUMBER() OVER(PARTITION BY c.rf_idRecordCase ORDER BY c.DateBegin DESC, c.DateEnd desc) AS idRow,c.id,SUM(m.Quantity) AS Quantity
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'						
							INNER JOIN (values(1,31,33)) v(idV006,idV008, idV010) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
				AND c.rf_idV010=v.idV010
								INNER JOIN dbo.t_MES me ON
			c.id=me.rf_idCase
						INNER JOIN dbo.vw_sprCSG_KIRO k ON
			me.MES=k.KSG
							INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase
	WHERE m.MUCode LIKE '1.11.%' AND k.KIRO IN(3,4) AND c.rf_idV009 IN(102,105,107,110)
	GROUP BY c.id,c.rf_idRecordCase,c.DateBegin,c.DateEnd								
)
insert #tError
select DISTINCT id,406 FROM cte c WHERE idRow=1 AND Quantity>3 AND NOT EXISTS(SELECT 1 FROM dbo.t_Kiro k  WHERE k.rf_idCase=id AND rf_idKiro IN(3,4))

;WITH cte 
AS(
	SELECT ROW_NUMBER() OVER(PARTITION BY c.rf_idRecordCase ORDER BY c.DateBegin DESC, c.DateEnd desc) AS idRow,c.id,SUM(m.Quantity) AS Quantity
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'						
							INNER JOIN (values(2,43)) v(idV006,idV008) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
								INNER JOIN dbo.t_MES me ON
			c.id=me.rf_idCase
						INNER JOIN dbo.vw_sprCSG_KIRO k ON
			me.MES=k.KSG              
							INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase
	WHERE m.MUCode LIKE '55.%' AND k.KIRO IN(3,4) AND c.rf_idV009 IN(202,205,207)
	GROUP BY c.id,c.rf_idRecordCase,c.DateBegin,c.DateEnd								
)
insert #tError
select DISTINCT id,406 FROM cte c WHERE idRow=1 AND Quantity>3 AND NOT EXISTS(SELECT 1 FROM dbo.t_Kiro k  WHERE k.rf_idCase=id AND rf_idKiro IN(3,4))

---для КИРО 5 и 6
;WITH cte 
AS(
	SELECT ROW_NUMBER() OVER(PARTITION BY c.rf_idRecordCase ORDER BY c.DateBegin DESC, c.DateEnd desc) AS idRow,c.id,SUM(m.Quantity) AS Quantity
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'						
							INNER JOIN (values(1,31,33)) v(idV006,idV008, idV010) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
				AND c.rf_idV010=v.idV010
								INNER JOIN dbo.t_MES me ON
			c.id=me.rf_idCase			
						INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase
						INNER JOIN dbo.t_Kiro kk ON
				c.id=kk.rf_idCase
	WHERE m.MUCode LIKE '1.11.%' AND kk.rf_idKiro=5
	GROUP BY c.id,c.rf_idRecordCase,c.DateBegin,c.DateEnd									
)
insert #tError select DISTINCT id,406 FROM cte c WHERE idRow=1 and Quantity>3 

;WITH cte 
AS(
	SELECT ROW_NUMBER() OVER(PARTITION BY c.rf_idRecordCase ORDER BY c.DateBegin DESC, c.DateEnd desc) AS idRow,c.id,SUM(m.Quantity) AS Quantity
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'						
							INNER JOIN (values(2,43)) v(idV006,idV008) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
								INNER JOIN dbo.t_MES me ON
			c.id=me.rf_idCase			
							INNER JOIN dbo.t_Kiro kk ON
				c.id=kk.rf_idCase  
							INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase
	WHERE m.MUCode LIKE '55.%' AND kk.rf_idKiro=5 
	GROUP BY c.id,c.rf_idRecordCase,c.DateBegin,c.DateEnd									
)
insert #tError select DISTINCT id,406 FROM cte c WHERE Quantity>3

;WITH cte 
AS(
	SELECT ROW_NUMBER() OVER(PARTITION BY c.rf_idRecordCase ORDER BY c.DateBegin DESC, c.DateEnd desc) AS idRow,c.id,SUM(m.Quantity) AS Quantity
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'						
							INNER JOIN (values(1,31,33)) v(idV006,idV008, idV010) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
				AND c.rf_idV010=v.idV010
								INNER JOIN dbo.t_MES me ON
			c.id=me.rf_idCase			
						INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase
						INNER JOIN dbo.t_Kiro kk ON
				c.id=kk.rf_idCase
	WHERE m.MUCode LIKE '1.11.%' AND kk.rf_idKiro=6 
	GROUP BY c.id,c.rf_idRecordCase,c.DateBegin,c.DateEnd								
)
insert #tError
select DISTINCT id,406 FROM cte c WHERE idRow=1 and Quantity<4 OR NOT EXISTS(SELECT * FROM t_Case WHERE id=c.id AND rf_idV009 IN(102,105,107,110))

;WITH cte 
AS(
	SELECT ROW_NUMBER() OVER(PARTITION BY c.rf_idRecordCase ORDER BY c.DateBegin DESC, c.DateEnd desc) AS idRow,c.id,SUM(m.Quantity) AS Quantity
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'						
							INNER JOIN (values(2,43)) v(idV006,idV008) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
								INNER JOIN dbo.t_MES me ON
			c.id=me.rf_idCase			
							INNER JOIN dbo.t_Kiro kk ON
				c.id=kk.rf_idCase  
							INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase
	WHERE m.MUCode LIKE '55.%' AND kk.rf_idKiro=6 
	GROUP BY c.id,c.rf_idRecordCase,c.DateBegin,c.DateEnd								
)
insert #tError
select DISTINCT id,406 FROM cte c WHERE idRow=1 AND Quantity<4 OR NOT EXISTS(SELECT * FROM t_Case WHERE id=c.id AND rf_idV009 IN(202,205,207)) 
GO
GRANT EXECUTE ON dbo.usp_Test406 TO db_RegisterCase