USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test518]    Script Date: 20.02.2019 12:04:08 ******/
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
IF @year>2018
BEGIN
	INSERT #tError
	select DISTINCT m.rf_idCase,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'
							INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase												
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN t_Coefficient cc ON
				c.id=cc.rf_idCase                      											 				
	WHERE  m.TypeMES=2 AND NOT EXISTS (SELECT 1 FROM dbo.vw_CSG_CSLP2019 csg WHERE MES=csg.code AND co.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP)			
/*
Значение VAL_C должно соответствовать значению кода оснований (проверка проводится на «Справочнике случаев с КСЛП») и должно быть  действующим по состоянию на дату окончания лечения DATE_Z_2.
*/
	INSERT #tError
	select DISTINCT m.rf_idCase,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'
							INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase												
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN t_Coefficient cc ON
				c.id=cc.rf_idCase                      											 				
	WHERE  m.TypeMES=2 AND NOT EXISTS (SELECT 1 FROM dbo.vw_CSG_CSLP2019 csg WHERE MES=csg.code AND co.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP AND csg.CodeSLP=cc.Code_SL 
											AND csg.VAL_C=cc.Coefficient AND co.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient)			
	INSERT #tError
	select DISTINCT m.rf_idCase,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'												
							INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase                          
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN t_Coefficient cc ON
				c.id=cc.rf_idCase  							
	  WHERE  m.TypeMES=2 AND NOT EXISTS(SELECT 1 FROM dbo.vw_CSG_CSLP2019 cs WHERE m.mes=cs.code and co.DateEnd BETWEEN cs.dateBegSLP AND cs.dateEndSLP AND cc.Code_SL=cs.CodeSLP)

/*
Значение VAL_C должно соответствовать значению кода оснований (проверка проводится на «Справочнике случаев с КСЛП») и должно быть  действующим по состоянию на дату окончания лечения DATE_Z_2.
*/
	INSERT #tError
	select DISTINCT m.rf_idCase,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'
							INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase												
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN t_Coefficient cc ON
				c.id=cc.rf_idCase                      											 				
	WHERE  m.TypeMES=2 AND NOT EXISTS (SELECT 1 FROM dbo.vw_CSG_CSLP2019 csg WHERE MES=csg.code AND co.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP AND csg.CodeSLP=cc.Code_SL 
											AND csg.VAL_C=cc.Coefficient AND co.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient)			

	
--если код КСЛП равен 1, то age<1
	INSERT #tError
	select DISTINCT m.rf_idCase,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'												
							INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase                          
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN t_Coefficient cc ON
				c.id=cc.rf_idCase  
							INNER JOIN dbo.vw_CSG_CSLP2019 cs ON
				m.MES=cs.code                    										
				AND cc.Code_SL=cs.CodeSLP	 				
	  WHERE  m.TypeMES=2 AND co.DateEnd BETWEEN cs.dateBegSLP AND cs.dateEndSLP	AND cs.CodeSLP=1 AND c.Age>=1
--если код КСЛП равен 2, то 1=<age<=3
	INSERT #tError
	select DISTINCT m.rf_idCase,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'												
							INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase                          
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN t_Coefficient cc ON
				c.id=cc.rf_idCase  
							INNER JOIN dbo.vw_CSG_CSLP2019 cs ON
				m.MES=cs.code                    										
				AND cc.Code_SL=cs.CodeSLP	 				
	  WHERE  m.TypeMES=2 AND co.DateEnd BETWEEN cs.dateBegSLP AND cs.dateEndSLP	AND cs.CodeSLP=2 AND c.Age NOT IN (1,2,3)
	--если код КСЛП равен 4, то age>74 and PROFIL_K<>16 
	INSERT #tError
	select DISTINCT m.rf_idCase,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'												
							INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase                          
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN t_Coefficient cc ON
				c.id=cc.rf_idCase  
							INNER JOIN dbo.vw_CSG_CSLP2019 cs ON
				m.MES=cs.code                    										
				AND cc.Code_SL=cs.CodeSLP	 				
							LEFT JOIN dbo.t_ProfileOfBed p ON
				c.id=p.rf_idCase                          
	  WHERE  m.TypeMES=2 AND co.DateEnd BETWEEN cs.dateBegSLP AND cs.dateEndSLP	AND cs.CodeSLP=4 AND (c.Age<75 OR p.rf_idV020=16 )
--если код КСЛП равен 5, то PROFIL_K=16 (геронтология) and DS1<>R54 and DS2=R54, 
--т.е пациент “лежит на геронтологической койке» с основным диагнозом не «R54-старость», но в сопутствующих диагнозах есть диагноз  «R54-старость»;
	INSERT #tError
	select DISTINCT m.rf_idCase,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'												
							INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase                          
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN t_Coefficient cc ON
				c.id=cc.rf_idCase  
							INNER JOIN dbo.vw_CSG_CSLP2019 cs ON
				m.MES=cs.code                    										
				AND cc.Code_SL=cs.CodeSLP	 				
							LEFT JOIN dbo.t_ProfileOfBed p ON
				c.id=p.rf_idCase                          
	  WHERE  m.TypeMES=2 AND co.DateEnd BETWEEN cs.dateBegSLP AND cs.dateEndSLP	AND cs.CodeSLP=5 
			AND (c.Age<60 OR p.rf_idV020<>16 OR NOT EXISTS(SELECT 1 FROM dbo.vw_Diagnosis WHERE rf_idCase=c.id AND DS1='R54' OR DS2<>'R54') )

/*
ID_SL=11, то в случае присутствуют услуги из номенклатуры, для которых в поле COMENTU через запятую перечислены различающиеся коды парных органов/частей тела, 
либо в случае присутствуют как минимум 2 услуги из Номенклатуры, у которых в поле COMENTU указаны различающиеся коды парных органов/ частей тела
*/
	INSERT #tError
	select DISTINCT m.rf_idCase,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'												
							INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase                          
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN t_Coefficient cc ON
				c.id=cc.rf_idCase  
							INNER JOIN dbo.vw_CSG_CSLP2019 cs ON
				m.MES=cs.code                    										
				AND cc.Code_SL=cs.CodeSLP	 				
	  WHERE  m.TypeMES=2 AND co.DateEnd BETWEEN cs.dateBegSLP AND cs.dateEndSLP	AND cs.CodeSLP=11 
			AND NOT EXISTS(SELECT 1 FROM dbo.vw_MeduslugiBodyParts WHERE rf_idCase=c.id )
/*
ID_SL=12, то в случае должны быть представлены:
или (ровно 2 услуги из Номенклатуры: A11.20.017 и A11.20.025.001 и других услуг из Номенклатуры нет) 
или (ровно 3 услуги из Номенклатуры: A11.20.017 и A11.20.025.001 и A11.20.036 и других услуг из Номенклатуры нет) 
или (ровно 3 услуги из Номенклатуры: A11.20.017 и A11.20.025.001 и A11.20.028 и других услуг из Номенклатуры нет)  
*/
	INSERT #tError
	select DISTINCT m.rf_idCase,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'												
							INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase                          
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN t_Coefficient cc ON
				c.id=cc.rf_idCase  
							INNER JOIN dbo.vw_CSG_CSLP2019 cs ON
				m.MES=cs.code                    										
				AND cc.Code_SL=cs.CodeSLP	 				
	  WHERE  m.TypeMES=2 AND co.DateEnd BETWEEN cs.dateBegSLP AND cs.dateEndSLP	AND cs.CodeSLP=12 
			AND NOT EXISTS(SELECT 1 FROM dbo.vw_MeduslugiCSLP_12 WHERE rf_idCase=c.id )
/*
ID_SL=13, то в случае должны быть представлены (ровно 2 услуги из Номенклатуры: A11.20.017 и A11.20.031 и других услуг из Номенклатуры нет) 
ID_SL=14, то в случае должны быть представлены или (ровно 2 услуги из Номенклатуры: A11.20.017 и A11.20.030.001 и других услуг из Номенклатуры нет) 
*/
	INSERT #tError
	select DISTINCT m.rf_idCase,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'												
							INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase                          
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN t_Coefficient cc ON
				c.id=cc.rf_idCase  
							INNER JOIN dbo.vw_CSG_CSLP2019 cs ON
				m.MES=cs.code                    										
				AND cc.Code_SL=cs.CodeSLP	 				
	  WHERE  m.TypeMES=2 AND co.DateEnd BETWEEN cs.dateBegSLP AND cs.dateEndSLP	AND cs.CodeSLP IN(13,14)
			AND NOT EXISTS(SELECT 1 FROM dbo.vw_MeduslugiCSLP_13 WHERE rf_idCase=c.id AND ID_SL=cs.CodeSLP )
END 
ELSE 
BEGIN
	INSERT #tError
	select DISTINCT m.rf_idCase,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20180101'												
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN t_Coefficient cc ON
				c.id=cc.rf_idCase                      											 				
	WHERE  NOT EXISTS (SELECT 1 FROM dbo.vw_CsgCSlp csg WHERE MES=csg.code)			                          
	/*
	Если перечень КСЛП не пуст, то выполняются нижеописанные проверки.
	Код оснований применения КСЛП (CODE_SL) – код должен соответствовать «Справочнику случаев с КСЛП» и должен быть действующим на дату окончания лечения
	
	*/
	INSERT #tError
	select DISTINCT m.rf_idCase,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20180101'												
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN t_Coefficient cc ON
				c.id=cc.rf_idCase     											 				
	WHERE  NOT EXISTS (SELECT 1 FROM dbo.vw_CsgCSlp csg WHERE MES=csg.code AND csg.CodeSLP=cc.Code_SL AND c.DateEnd>= csg.DateBegCoefficient AND c.DateEnd<=csg.DateEndCoefficient )
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
		WHERE csg.CodeSLP=12 AND NOT EXISTS(SELECT * FROM (VALUES('A11.20.036'),('A11.20.028')) v(MU) WHERE v.MU=mm.MUSurgery)
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
	INSERT #tError SELECT id,518 FROM cte1 WHERE CountMU NOT IN(2,3)
	
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
	INSERT #tError SELECT id,518 FROM cte1 WHERE CountMU NOT IN(2,3)
	
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
END
