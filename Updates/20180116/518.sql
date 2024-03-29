USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test518]    Script Date: 17.01.2018 9:26:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test518]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
IF @year<2018
BEGIN
	INSERT #tError
	select c.id,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>'20160430'
							INNER JOIN vw_CSLP_Coefficient co ON
				c.id=co.rf_idCase
	WHERE c.IT_SL<>co.Sum_CSLP

	--error 518
	insert #tError
	select DISTINCT c.id,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>'20160430'
							INNER JOIN dbo.t_Coefficient co ON
				c.id=co.rf_idCase
	WHERE NOT EXISTS(SELECT * FROM oms_nsi.dbo.tSLP WHERE code=co.Code_SL)			                      

	insert #tError
	select DISTINCT c.id,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>'20160430'
							INNER JOIN dbo.t_Coefficient co ON
				c.id=co.rf_idCase
							INNER JOIN (VALUES(1,0,4),(2,74,120)) v(code,ageStart, ageEnd) ON
				co.Code_SL=v.code
				AND c.age<=v.AgeStart
				AND c.age>=v.AgeEnd			                      

	insert #tError
	select DISTINCT c.id,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>'20160430'
							INNER JOIN dbo.t_Coefficient co ON
				c.id=co.rf_idCase
	WHERE NOT EXISTS(SELECT * FROM dbo.VW_sprCoefficient WHERE code=co.Code_SL AND coefficient=co.Coefficient AND c.DateEnd>=dateBeg AND c.DateEnd<=dateEnd)			                      
	--В справочник КСГ 2017 введено новое поле noKSLP. Если для КСГ noKSLP=1, то КСЛП не может быть применен. 
	insert #tError
	select DISTINCT c.id,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>'20160430'
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase                      
							INNER JOIN dbo.t_Coefficient co ON
				c.id=co.rf_idCase
	WHERE EXISTS(SELECT * FROM dbo.vw_sprCSG WHERE code=m.MES AND noKSLP=1 AND c.DateEnd>=dateBeg AND c.DateEnd<=dateEnd)
END
/*
Если перечень КСЛП пуст, а в случае КСЛП представлен, то выдается ошибка. 
*/
insert #tError
select DISTINCT m.rf_idCase,518
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
WHERE csg.CodeSLP IS NULL AND EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)				                          


insert #tError
select DISTINCT m.rf_idCase,518
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'												
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_CsgCSlp csg ON
			m.MES=csg.code						 				
WHERE csg.CodeSLP IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)				                          
/*
Перечень кодов случаев с КСЛП и условий применения КСЛП:
если код КСЛП равен 1, то age<1;
если код КСЛП равен 2, то 0<age<4;
если код КСЛП равен 4, то age>74;
если код КСЛП равен 5, то age>59;
*/
insert #tError
select DISTINCT m.rf_idCase,518
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'												
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_CsgCSlp csg ON
			m.MES=csg.code						 				
						INNER JOIN dbo.t_Coefficient cf ON
			c.id=cf.rf_idCase
			AND csg.CodeSLP=cf.Code_SL
WHERE csg.CodeSLP<6 AND 1=(CASE WHEN cf.Code_SL=1 AND c.Age>0 THEN 1 WHEN cf.Code_SL=2 AND c.Age NOT IN (1,2,3) THEN 1
											WHEN cf.Code_SL=4 AND c.Age<75 THEN 1 WHEN cf.Code_SL=5 and c.Age<60 THEN  1 ELSE 0 END)

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
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CsgCSlp csg ON
				m.MES=csg.code						 				
							INNER JOIN dbo.t_Coefficient cf ON
				c.id=cf.rf_idCase
				AND csg.CodeSLP=cf.Code_SL
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase
							LEFT JOIN (VALUES('A11.20.017'),('A11.20.025.001')) v(idV001) on
				mm.MUSurgery=v.idV001
	WHERE csg.CodeSLP=12 
	GROUP BY c.id
)
INSERT #tError SELECT id,518 FROM cte1 WHERE CountMU<>2

INSERT #tError
select c.id,518
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'												
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_CsgCSlp csg ON
			m.MES=csg.code						 				
						INNER JOIN dbo.t_Coefficient cf ON
			c.id=cf.rf_idCase
			AND csg.CodeSLP=cf.Code_SL
						INNER JOIN dbo.t_Meduslugi mm ON
			c.id=mm.rf_idCase	
						INNER JOIN (VALUES('A11.20.017'),('A11.20.025.001')) v(idV001) on
				mm.MUSurgery=v.idV001			
WHERE csg.CodeSLP=12 AND EXISTS(SELECT 1 FROM t_Meduslugi m WHERE mm.MUSurgery NOT IN ('A11.20.017','A11.20.025.001') AND m.rf_idCase=c.id) 

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
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CsgCSlp csg ON
				m.MES=csg.code						 				
							INNER JOIN dbo.t_Coefficient cf ON
				c.id=cf.rf_idCase
				AND csg.CodeSLP=cf.Code_SL
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase
							left JOIN (VALUES('A11.20.017'),('A11.20.025.001'),('A11.20.036')) v(idV001) on
				mm.MUSurgery=v.idV001
	WHERE csg.CodeSLP=12 
	GROUP BY c.id
)
INSERT #tError SELECT id,518 FROM cte1 WHERE CountMU<>3

INSERT #tError
select c.id,518
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'												
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_CsgCSlp csg ON
			m.MES=csg.code						 				
						INNER JOIN dbo.t_Coefficient cf ON
			c.id=cf.rf_idCase
			AND csg.CodeSLP=cf.Code_SL
						INNER JOIN dbo.t_Meduslugi mm ON
			c.id=mm.rf_idCase	
						inner JOIN (VALUES('A11.20.017'),('A11.20.025.001'),('A11.20.036')) v(idV001) on
				mm.MUSurgery=v.idV001			
WHERE csg.CodeSLP=12 AND EXISTS(SELECT 1 FROM t_Meduslugi m WHERE mm.MUSurgery NOT IN ('A11.20.017','A11.20.025.001','A11.20.036') AND m.rf_idCase=c.id) 
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
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CsgCSlp csg ON
				m.MES=csg.code						 				
							INNER JOIN dbo.t_Coefficient cf ON
				c.id=cf.rf_idCase
				AND csg.CodeSLP=cf.Code_SL
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase
							left JOIN (VALUES('A11.20.017'),('A11.20.025.001'),('A11.20.028')) v(idV001) on
				mm.MUSurgery=v.idV001
	WHERE csg.CodeSLP=12 
	GROUP BY c.id
)
INSERT #tError SELECT id,518 FROM cte1 WHERE CountMU<>3

INSERT #tError
select c.id,518
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'												
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_CsgCSlp csg ON
			m.MES=csg.code						 				
						INNER JOIN dbo.t_Coefficient cf ON
			c.id=cf.rf_idCase
			AND csg.CodeSLP=cf.Code_SL
						INNER JOIN dbo.t_Meduslugi mm ON
			c.id=mm.rf_idCase	
						inner JOIN (VALUES('A11.20.017'),('A11.20.025.001'),('A11.20.028')) v(idV001) on
				mm.MUSurgery=v.idV001			
WHERE csg.CodeSLP=12 AND EXISTS(SELECT 1 FROM t_Meduslugi m WHERE mm.MUSurgery NOT IN ('A11.20.017','A11.20.025.001','A11.20.028') AND m.rf_idCase=c.id) 
/*
если код КСЛП равен 13, то в случае должны быть представлены (ровно 2 услуги из Номенклатуры: A11.20.017 и A11.20.031 и других услуг из Номенклатуры нет) 
(другие услуги не из Номенклатуры могут быть, например, пациенто-дни 55.1.*)
*/
;WITH cte1
AS(
	select c.id,COUNT(DISTINCT mm.MUSurgery) AS CountMU
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20180101'													
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CsgCSlp csg ON
				m.MES=csg.code						 				
							INNER JOIN dbo.t_Coefficient cf ON
				c.id=cf.rf_idCase
				AND csg.CodeSLP=cf.Code_SL
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase
							left JOIN (VALUES('A11.20.017'),('A11.20.031')) v(idV001) on
				mm.MUSurgery=v.idV001
	WHERE csg.CodeSLP=13
	GROUP BY c.id
)
INSERT #tError SELECT id,518 FROM cte1 WHERE CountMU<>2

INSERT #tError
select c.id,518
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'												
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_CsgCSlp csg ON
			m.MES=csg.code						 				
						INNER JOIN dbo.t_Coefficient cf ON
			c.id=cf.rf_idCase
			AND csg.CodeSLP=cf.Code_SL
						INNER JOIN dbo.t_Meduslugi mm ON
			c.id=mm.rf_idCase	
						INNER JOIN (VALUES('A11.20.017'),('A11.20.031')) v(idV001) on
				mm.MUSurgery=v.idV001			
WHERE csg.CodeSLP=13 AND EXISTS(SELECT 1 FROM t_Meduslugi m WHERE mm.MUSurgery NOT IN ('A11.20.017','A11.20.031') AND m.rf_idCase=c.id) 
/*
если код КСЛП равен 14, то в случае должны быть представлены (ровно 2 услуги из Номенклатуры: A11.20.017 и A11.20.030.001 и других услуг из Номенклатуры нет) 
(другие услуги не из Номенклатуры могут быть, например, пациенто-дни 55.1.*)
*/
;WITH cte1
AS(
	select c.id,COUNT(DISTINCT mm.MUSurgery) AS CountMU
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20180101'													
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CsgCSlp csg ON
				m.MES=csg.code						 				
							INNER JOIN dbo.t_Coefficient cf ON
				c.id=cf.rf_idCase
				AND csg.CodeSLP=cf.Code_SL
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase
							left JOIN (VALUES('A11.20.017'),('A11.20.030.001')) v(idV001) on
				mm.MUSurgery=v.idV001
	WHERE csg.CodeSLP=14
	GROUP BY c.id
)
INSERT #tError SELECT id,518 FROM cte1 WHERE CountMU<>2

INSERT #tError
select c.id,518
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'												
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_CsgCSlp csg ON
			m.MES=csg.code						 				
						INNER JOIN dbo.t_Coefficient cf ON
			c.id=cf.rf_idCase
			AND csg.CodeSLP=cf.Code_SL
						INNER JOIN dbo.t_Meduslugi mm ON
			c.id=mm.rf_idCase	
						INNER JOIN (VALUES('A11.20.017'),('A11.20.030.001')) v(idV001) on
				mm.MUSurgery=v.idV001			
WHERE csg.CodeSLP=14 AND EXISTS(SELECT 1 FROM t_Meduslugi m WHERE mm.MUSurgery NOT IN ('A11.20.017','A11.20.030.001') AND m.rf_idCase=c.id) 

INSERT #tError
select c.id,518
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20180101'												
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_CsgCSlp csg ON
			m.MES=csg.code						 				
						INNER JOIN dbo.t_Coefficient cf ON
			c.id=cf.rf_idCase
			AND csg.CodeSLP=cf.Code_SL
WHERE csg.CodeSLP IS NOT NULL AND c.DateEnd>=csg.DateBegCoefficient AND csg.DateEndCoefficient>=c.DateEnd AND csg.VAL_C<>cf.Coefficient
go