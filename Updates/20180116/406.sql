USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test406]    Script Date: 25.01.2018 11:47:18 ******/
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
Если перечень КИРО не пуст и в случае то КИРО должен присутствовать обязательно (и если КИРО нет, то выдается ошибка).
*/
--insert #tError
--select DISTINCT m.rf_idCase,406
--from t_RegistersCase a inner join t_RecordCase r on
--			a.id=r.rf_idRegistersCase
--			and a.rf_idFiles=@idFile			
--						inner join t_Case c on
--			r.id=c.rf_idRecordCase	
--			AND c.DateEnd>='20180101'
--									INNER JOIN (values(1,31,33),(2,43,null)) v(idV006,idV008, idV010) ON
--			c.rf_idV006=v.idV006
--			AND c.rf_idV008=v.idV008
--			AND c.rf_idV010=ISNULL(v.idV010,c.rf_idV010)												
--						INNER JOIN dbo.t_MES m ON
--			c.id=m.rf_idCase
--						INNER JOIN dbo.vw_sprCSG_KIRO k ON
--			m.MES=k.KSG
--WHERE k.KIRO IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.t_Kiro WHERE rf_idCase=c.id)
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
							INNER JOIN (values(1,31,33)) v(idV006,idV008, idV010) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
				AND c.rf_idV010=v.idV010
							INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase
	WHERE m.MUCode LIKE '1.11.%'
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
							INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase
	WHERE m.MUCode LIKE '55.%'
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
WHERE k.KIRO IS NOT NULL AND k1.rf_idKiro<>k.KIRO

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

