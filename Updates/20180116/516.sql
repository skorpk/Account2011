USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test516]    Script Date: 16.01.2018 14:10:15 
Провести тестирование данной проверки ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test516]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--error 516
---Проверка на заполненость тегов связанных с КСЛП 
IF @year<2018
BEGIN
	insert #tError
	select DISTINCT m.rf_idCase,516
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>'20160430'						
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase		
							INNER JOIN dbo.vw_sprCSG csg ON
				m.MES=csg.code
	where c.rf_idV006=1 AND c.rf_idV008=31 AND ISNULL(csg.noKSLP,0)<>1 AND (c.Age>74 OR c.Age<4) AND c.IT_SL IS NULL

	insert #tError
	SELECT DISTINCT m.rf_idCase,516
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>'20160430'						
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase		
							INNER JOIN dbo.vw_sprCSG csg ON
				m.MES=csg.code
	where c.rf_idV006=1 AND c.rf_idV008=31 AND ISNULL(csg.noKSLP,0)<>1 AND (c.Age>74 OR c.Age<4) 
		AND NOT EXISTS(SELECT * FROM dbo.t_Coefficient WHERE rf_idCase=c.id AND Code_SL IS NOT NULL AND Coefficient IS NOT NULL)
END 

/*
Перечень кодов случаев с КСЛП и условий применения КСЛП:
если код КСЛП равен 1, то age<1;
если код КСЛП равен 2, то 0<age<4;
если код КСЛП равен 4, то age>74;
если код КСЛП равен 5, то age>59;
*/
insert #tError
select DISTINCT m.rf_idCase,516
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
						INNER JOIN dbo.vw_CsgCSlp csg ON
			m.MES=csg.code						 										
WHERE csg.CodeSLP<6 AND 1=(CASE WHEN csg.CodeSLP=1 AND c.Age=0 THEN 1 WHEN csg.CodeSLP=2 AND c.Age IN (1,2,3) THEN 1
											WHEN csg.CodeSLP=4 AND c.Age>74 THEN 1 WHEN csg.CodeSLP=5 and c.Age>59 THEN  1 ELSE 0 END)
		AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)

/*
КСЛП равен 12, то в случае должны быть представлены или (ровно 2 услуги из Номенклатуры: A11.20.017 и A11.20.025.001 и других услуг из Номенклатуры нет)
*/
;WITH cte1
AS(
	select c.id,COUNT(mm.MUSurgery) AS CountMU
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20180101'						
							INNER JOIN (values(1,31,33),(2,43,null)) v1(idV006,idV008, idV010) ON
				c.rf_idV006=v1.idV006
				AND c.rf_idV008=v1.idV008
				AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CsgCSlp csg ON
				m.MES=csg.code						 											
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase
							inner JOIN (VALUES('A11.20.017'),('A11.20.025.001')) v(idV001) on
				mm.MUSurgery=v.idV001
	WHERE csg.CodeSLP=12 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)
	GROUP BY c.id
)
INSERT #tError SELECT id,516 FROM cte1 WHERE CountMU=2

INSERT #tError
select c.id,516
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'						
						INNER JOIN (values(1,31,33),(2,43,null)) v1(idV006,idV008, idV010) ON
				c.rf_idV006=v1.idV006
				AND c.rf_idV008=v1.idV008
				AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_CsgCSlp csg ON
			m.MES=csg.code						 							
						INNER JOIN dbo.t_Meduslugi mm ON
			c.id=mm.rf_idCase	
						INNER JOIN (VALUES('A11.20.017'),('A11.20.025.001')) v(idV001) on
				mm.MUSurgery=v.idV001			
WHERE csg.CodeSLP=12 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)
	 AND NOT EXISTS(SELECT 1 FROM t_Meduslugi m WHERE mm.MUSurgery NOT IN ('A11.20.017','A11.20.025.001') AND m.rf_idCase=c.id) 

/*
или (ровно 3 услуги из Номенклатуры: A11.20.017 и A11.20.025.001 и A11.20.036 и других услуг из Номенклатуры нет) 
*/
;WITH cte1
AS(
	select c.id,COUNT(mm.MUSurgery) AS CountMU
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20180101'						
							INNER JOIN (values(1,31,33),(2,43,null)) v1(idV006,idV008, idV010) ON
				c.rf_idV006=v1.idV006
				AND c.rf_idV008=v1.idV008
				AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CsgCSlp csg ON
				m.MES=csg.code						 								
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase
							left JOIN (VALUES('A11.20.017'),('A11.20.025.001'),('A11.20.036')) v(idV001) on
				mm.MUSurgery=v.idV001
	WHERE csg.CodeSLP=12 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)
	GROUP BY c.id
)
INSERT #tError SELECT id,516 FROM cte1 WHERE CountMU=3

INSERT #tError
select c.id,516
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'						
						INNER JOIN (values(1,31,33),(2,43,null)) v1(idV006,idV008, idV010) ON
				c.rf_idV006=v1.idV006
				AND c.rf_idV008=v1.idV008
				AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_CsgCSlp csg ON
			m.MES=csg.code						 							
						INNER JOIN dbo.t_Meduslugi mm ON
			c.id=mm.rf_idCase	
						INNER JOIN (VALUES('A11.20.017'),('A11.20.025.001'),('A11.20.036')) v(idV001) on
				mm.MUSurgery=v.idV001			
WHERE csg.CodeSLP=12 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id) 
	AND NOT EXISTS(SELECT 1 FROM t_Meduslugi m WHERE mm.MUSurgery NOT IN ('A11.20.017','A11.20.025.001','A11.20.036') AND m.rf_idCase=c.id) 
/*
(ровно 3 услуги из Номенклатуры: A11.20.017 и A11.20.025.001 и A11.20.028 и других услуг из Номенклатуры нет)  
*/
;WITH cte1
AS(
	select c.id,COUNT(mm.MUSurgery) AS CountMU
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20180101'						
							INNER JOIN (values(1,31,33),(2,43,null)) v1(idV006,idV008, idV010) ON
				c.rf_idV006=v1.idV006
				AND c.rf_idV008=v1.idV008
				AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CsgCSlp csg ON
				m.MES=csg.code						 				
							INNER JOIN dbo.t_Coefficient cf ON
				c.id=cf.rf_idCase
				AND csg.CodeSLP=cf.Code_SL
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase
							INNER JOIN (VALUES('A11.20.017'),('A11.20.025.001'),('A11.20.028')) v(idV001) on
				mm.MUSurgery=v.idV001
	WHERE csg.CodeSLP=12 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id) 
	GROUP BY c.id
)
INSERT #tError SELECT id,516 FROM cte1 WHERE CountMU<>3

INSERT #tError
select c.id,516
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'						
						INNER JOIN (values(1,31,33),(2,43,null)) v1(idV006,idV008, idV010) ON
				c.rf_idV006=v1.idV006
				AND c.rf_idV008=v1.idV008
				AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_CsgCSlp csg ON
			m.MES=csg.code						 							
						INNER JOIN dbo.t_Meduslugi mm ON
			c.id=mm.rf_idCase	
						INNER JOIN (VALUES('A11.20.017'),('A11.20.025.001'),('A11.20.028')) v(idV001) on
				mm.MUSurgery=v.idV001			
WHERE csg.CodeSLP=12 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)
	AND NOT EXISTS(SELECT 1 FROM t_Meduslugi m WHERE mm.MUSurgery NOT IN ('A11.20.017','A11.20.025.001','A11.20.028') AND m.rf_idCase=c.id) 
/*
если код КСЛП равен 13, то в случае должны быть представлены (ровно 2 услуги из Номенклатуры: A11.20.017 и A11.20.031 и других услуг из Номенклатуры нет) 
(другие услуги не из Номенклатуры могут быть, например, пациенто-дни 55.1.*)
*/
;WITH cte1
AS(
	select c.id,COUNT(mm.MUSurgery) AS CountMU
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20180101'						
							INNER JOIN (values(1,31,33),(2,43,null)) v1(idV006,idV008, idV010) ON
				c.rf_idV006=v1.idV006
				AND c.rf_idV008=v1.idV008
				AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CsgCSlp csg ON
				m.MES=csg.code						 								
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase
							INNER JOIN (VALUES('A11.20.017'),('A11.20.031')) v(idV001) on
				mm.MUSurgery=v.idV001
	WHERE csg.CodeSLP=13 and NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)
	GROUP BY c.id
)
INSERT #tError SELECT id,516 FROM cte1 WHERE CountMU<>2

INSERT #tError
select c.id,516
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'						
						INNER JOIN (values(1,31,33),(2,43,null)) v1(idV006,idV008, idV010) ON
				c.rf_idV006=v1.idV006
				AND c.rf_idV008=v1.idV008
				AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_CsgCSlp csg ON
			m.MES=csg.code						 							
						INNER JOIN dbo.t_Meduslugi mm ON
			c.id=mm.rf_idCase	
						INNER JOIN (VALUES('A11.20.017'),('A11.20.031')) v(idV001) on
				mm.MUSurgery=v.idV001			
WHERE csg.CodeSLP=13 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)
	AND NOT EXISTS(SELECT 1 FROM t_Meduslugi m WHERE mm.MUSurgery NOT IN ('A11.20.017','A11.20.031') AND m.rf_idCase=c.id) 
/*
если код КСЛП равен 14, то в случае должны быть представлены (ровно 2 услуги из Номенклатуры: A11.20.017 и A11.20.030.001 и других услуг из Номенклатуры нет) 
(другие услуги не из Номенклатуры могут быть, например, пациенто-дни 55.1.*)
*/
;WITH cte1
AS(
	select c.id,COUNT(mm.MUSurgery) AS CountMU
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20180101'						
							INNER JOIN (values(1,31,33),(2,43,null)) v1(idV006,idV008, idV010) ON
				c.rf_idV006=v1.idV006
				AND c.rf_idV008=v1.idV008
				AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CsgCSlp csg ON
				m.MES=csg.code						 								
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase
							INNER JOIN (VALUES('A11.20.017'),('A11.20.030.001')) v(idV001) on
				mm.MUSurgery=v.idV001
	WHERE csg.CodeSLP=14 and NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)
	GROUP BY c.id
)
INSERT #tError SELECT id,516 FROM cte1 WHERE CountMU<>2

INSERT #tError
select c.id,516
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'						
						INNER JOIN (values(1,31,33),(2,43,null)) v1(idV006,idV008, idV010) ON
				c.rf_idV006=v1.idV006
				AND c.rf_idV008=v1.idV008
				AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_CsgCSlp csg ON
			m.MES=csg.code						 							
						INNER JOIN dbo.t_Meduslugi mm ON
			c.id=mm.rf_idCase	
						INNER JOIN (VALUES('A11.20.017'),('A11.20.030.001')) v(idV001) on
				mm.MUSurgery=v.idV001			
WHERE csg.CodeSLP=14 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id) 
	AND NOT EXISTS(SELECT 1 FROM t_Meduslugi m WHERE mm.MUSurgery NOT IN ('A11.20.017','A11.20.030.001') AND m.rf_idCase=c.id) 
GO