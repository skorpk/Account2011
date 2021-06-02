USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test516]    Script Date: 05.02.2021 9:49:53 ******/
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


SELECT DISTINCT codeNomenclMU ,dateBeg, dateEnd INTO #tCSG FROM vw_sprNomenclMUBodyParts
IF @year<2021
BEGIN
	--error 516
	/*#tMU
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
				AND c.DateEnd<'20190101'
							INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v(idV006,idV008, idV010) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
				AND c.rf_idV010=ISNULL(v.idV010,c.rf_idV010)
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CsgCSlp csg ON
				m.MES=csg.code						 										
	WHERE csg.CodeSLP<6 AND 1=(CASE WHEN csg.CodeSLP=1 AND c.Age=0 THEN 1 WHEN csg.CodeSLP=2 AND c.Age IN (1,2,3) THEN 1
												WHEN csg.CodeSLP=4 AND c.Age>74 THEN 1 /*WHEN csg.CodeSLP=5 and c.Age>59 THEN  1*/ ELSE 0 END)
			AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)
	/*
	Перечень кодов случаев с КСЛП и условий применения КСЛП:
	если код КСЛП равен 1, то age<1;(надо иметь в виду, что достижение определенного возраста происходит на следующий после даты рождения день)
	если код КСЛП равен 2, то 1<age<=3(надо иметь в виду, что достижение определенного возраста происходит на следующий после даты рождения день)
	если код КСЛП равен 4, то age>74 and PROFIL_K<>16 (геронтология);
	если код КСЛП равен 5, то PROFIL_K=16 (геронтология) and DS1<>R54 and DS2=R54, т.е пациент “лежит на геронтологической койке» с основным диагнозом не «R54-старость», 
	но в сопутствующих диагнозах есть диагноз  «R54-старость»;
	
	*/	 
	insert #tError
	select DISTINCT m.rf_idCase,516
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'						
							INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v(idV006,idV008, idV010) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
				AND c.rf_idV010=ISNULL(v.idV010,c.rf_idV010)
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
				m.MES=csg.code										
							LEFT JOIN dbo.t_ProfileOfBed p ON
				c.id=p.rf_idCase									
	WHERE csg.CodeSLP<5 AND 1=(CASE WHEN csg.CodeSLP=1 AND c.Age=0 THEN 1 WHEN csg.CodeSLP=2 AND c.Age IN (2,3) THEN 1
												WHEN csg.CodeSLP=4 AND c.Age>74 AND p.rf_idV020!=16 THEN 1 ELSE 0 END)
			AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)
	
	insert #tError
	select DISTINCT m.rf_idCase,516
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'						
							INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v(idV006,idV008, idV010) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
				AND c.rf_idV010=ISNULL(v.idV010,c.rf_idV010)
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
				m.MES=csg.code				
				AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient	
							INNER JOIN dbo.vw_Diagnosis d ON
				c.id=d.rf_idCase		 	
							LEFT JOIN dbo.t_ProfileOfBed p ON
				c.id=p.rf_idCase									
	WHERE csg.CodeSLP=5 AND p.rf_idV020=16 AND d.DS1<>'R54' AND d.DS2 ='R54'
			AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)
	/*
	если код КСЛП равен 11, то в случае присутствуют услуги из номенклатуры, для которых в поле COMENTU через 
	запятую перечислены различающиеся коды парных органов/частей тела, либо в случае присутствуют как минимум 
	2 услуги из Номенклатуры, у которых в поле COMENTU указаны различающиеся коды парных органов/ частей тела
	*/
	
	--если КСЛП =11, то операции должны быть в ремках одного случая
	;WITH cte
	AS(
	SELECT c.id,COUNT(DISTINCT mm.GUID_MU) AS CountMU
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'
						INNER JOIN dbo.t_CompletedCase cc1 ON
	             r.id=cc1.rf_idRecordCase						
							INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v(idV006,idV008, idV010) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
				AND c.rf_idV010=ISNULL(v.idV010,c.rf_idV010)
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
				m.MES=csg.code				
				AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient	
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase		 
							INNER JOIN oms_nsi.dbo.sprNomenclMUBodyParts b ON
				mm.MUSurgery=b.codeNomenclMU	
				AND cc1.DateEnd BETWEEN b.dateBeg AND b.dateEnd 		
				--			INNER JOIN dbo.t_Coefficient cc ON
				--c.id=cc.rf_idCase
				--and csg.CodeSLP=cc.Code_SL					
	WHERE csg.CodeSLP=11 AND len(mm.Comments) IN(1,2) AND mm.Comments IS NOT NULL 
	GROUP BY c.id
	)
	insert #tError select DISTINCT id,516 FROM cte WHERE CountMU=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=cte.id)
	
	;WITH cte
	AS(
	SELECT c.id,COUNT(DISTINCT mm.GUID_MU) AS CountMU
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'	
							INNER JOIN dbo.t_CompletedCase cc1 ON
	             r.id=cc1.rf_idRecordCase							
							INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v(idV006,idV008, idV010) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
				AND c.rf_idV010=ISNULL(v.idV010,c.rf_idV010)
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
				m.MES=csg.code	
				AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient				
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase		 
							INNER JOIN oms_nsi.dbo.sprNomenclMUBodyParts b ON
				mm.MUSurgery=b.codeNomenclMU	
				AND cc1.DateEnd BETWEEN b.dateBeg AND b.dateEnd 
							INNER JOIN dbo.t_Coefficient cc ON
				c.id=cc.rf_idCase
				and csg.CodeSLP=cc.Code_SL					
	WHERE csg.CodeSLP=11 AND LEN( REPLACE(mm.Comments,',','')) IN(3,4,5) AND mm.Comments IS NOT NULL
	GROUP BY c.id
	)
	insert #tError select DISTINCT id,516 FROM cte WHERE CountMU=1 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=cte.id)
	
	--нету ни одной услуги из номенклатуры
	
	insert #tError
	select DISTINCT m.rf_idCase,516
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'									
							INNER JOIN dbo.t_CompletedCase cc1 ON
	             r.id=cc1.rf_idRecordCase	
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
				m.MES=csg.code							
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase
						INNER JOIN dbo.t_Coefficient cc ON
				c.id=cc.rf_idCase
				and csg.CodeSLP=cc.Code_SL		 			
	WHERE csg.CodeSLP=11 AND LEN(mm.Comments)=1 AND NOT EXISTS(SELECT 1 FROM vw_sprNomenclMUBodyParts b 
																WHERE mm.MUSurgery=b.codeNomenclMU	AND mm.Comments=CAST(b.code AS VARCHAR(4))
																	AND cc1.DateEnd BETWEEN b.dateBeg AND b.dateEnd 
																)			
	
	
	;WITH cteA
	AS(
		SELECT c.id,mm.MUSurgery,cc1.DateEnd, (CONVERT(xml,replace(('<Root><Num num="'+mm.Comments)+'" /></Root>',',','" /><Num num="'),0))	AS XMLNum
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile			
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>='20190101'
								INNER JOIN dbo.t_CompletedCase cc1 ON
	             r.id=cc1.rf_idRecordCase											
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
								INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
					m.MES=csg.code	
					AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient				
								INNER JOIN dbo.t_Meduslugi mm ON
					c.id=mm.rf_idCase		 
								INNER JOIN dbo.t_Coefficient cc ON
				c.id=cc.rf_idCase
				and csg.CodeSLP=cc.Code_SL
								INNER JOIN vw_sprNomenclMUBodyParts b ON
					mm.MUSurgery=b.codeNomenclMU			
					AND cc1.DateEnd BETWEEN b.dateBeg AND b.dateEnd
		WHERE csg.CodeSLP=11 AND LEN(mm.Comments)>1 AND mm.Comments IS NOT NULL
	) ,
	cteB 
	AS
	(
	SELECT s.id,s.MUSurgery,m.c.value('@num[1]','smallint') AS BodyParts
	FROM cteA s CROSS APPLY s.XMLNum.nodes('/Root/Num') as m(c)
	)
	insert #tError SELECT distinct id,516
	FROM cteB
	WHERE NOT EXISTS(SELECT 1 FROM vw_sprNomenclMUBodyParts b WHERE cteB.MUSurgery=b.codeNomenclMU AND BodyParts=b.code AND DateEnd BETWEEN b.dateBeg AND b.dateEnd)
	
	
	/*
	не может быть повторений внутри одного COMMENTU
	*/
	--SELECT DISTINCT codeNomenclMU ,dateBeg, dateEnd INTO #tCSG FROM vw_sprNomenclMUBodyParts
	
	;WITH cteA
	AS(
		SELECT c.id,mm.MUSurgery, mm.GUID_MU,(CONVERT(xml,replace(('<Root><Num num="'+mm.Comments)+'" /></Root>',',','" /><Num num="'),0))	AS XMLNum
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile			
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>='20190101'						
								INNER JOIN dbo.t_CompletedCase cc1 ON
	             r.id=cc1.rf_idRecordCase	
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
								INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
					m.MES=csg.code		
					AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient			
								INNER JOIN dbo.t_Meduslugi mm ON
					c.id=mm.rf_idCase		 
								INNER JOIN dbo.t_Coefficient cc ON
				c.id=cc.rf_idCase
				and csg.CodeSLP=cc.Code_SL
								INNER JOIN #tCSG b ON
					mm.MUSurgery=b.codeNomenclMU		
					AND cc1.DateEnd BETWEEN b.dateBeg AND b.dateEnd
		WHERE csg.CodeSLP=11 AND LEN(mm.Comments)>1 AND mm.Comments IS NOT NULL
	) ,
	cteB 
	AS
	(
	SELECT DISTINCT s.id,s.Guid_MU,s.MUSurgery,m.c.value('@num[1]','smallint') AS BodyParts
	FROM cteA s CROSS APPLY s.XMLNum.nodes('/Root/Num') as m(c)
	),
	cteC
	as
	(
		SELECT id,Guid_MU,MUSurgery,BodyParts from cteB GROUP BY id,Guid_MU,MUSurgery,BodyParts HAVING COUNT(*)>1
	)
	insert #tError SELECT distinct id,516
	FROM cteC
	--проверяем что бы при КСЛП =11 были только цифры
	insert #tError 
	select m.rf_idCase,516
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'									
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
				m.MES=csg.code			
				AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient		
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase		 
						INNER JOIN dbo.t_Coefficient cc ON
				c.id=cc.rf_idCase
				and csg.CodeSLP=cc.Code_SL
							INNER JOIN vw_sprNomenclMUBodyParts b ON
				mm.MUSurgery=b.codeNomenclMU			
				AND mm.Comments<>CAST(b.code AS VARCHAR(4))		
	WHERE csg.CodeSLP=11 AND ISNUMERIC(mm.Comments)=0 
	---проверяем на то что бы было несколько значений в BodyParts в одном случаи
	select m.rf_idCase,mm.MUSurgery,CAST(mm.Comments AS SMALLINT) AS BodyParts
	INTO #tMU
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'	
							INNER JOIN dbo.t_CompletedCase cc1 ON
	             r.id=cc1.rf_idRecordCase									
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
				m.MES=csg.code	
				AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient				
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase		 
							INNER JOIN vw_sprNomenclMUBodyParts b ON
				mm.MUSurgery=b.codeNomenclMU			
				AND mm.Comments<>CAST(b.code AS VARCHAR(4))		
				AND cc1.DateEnd BETWEEN b.dateBeg AND b.dateEnd
							INNER JOIN dbo.t_Coefficient cc ON
				c.id=cc.rf_idCase
				and csg.CodeSLP=cc.Code_SL
	WHERE csg.CodeSLP=11 AND LEN(mm.Comments)=1 AND ISNUMERIC(mm.Comments)=0 AND mm.Comments IS NOT NULL
	
	;WITH cteA
	AS(
		SELECT c.id,mm.MUSurgery, (CONVERT(xml,replace(('<Root><Num num="'+mm.Comments)+'" /></Root>',',','" /><Num num="'),0))	AS XMLNum
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile			
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>='20190101'
								INNER JOIN dbo.t_CompletedCase cc1 ON
	             r.id=cc1.rf_idRecordCase											
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
								INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
					m.MES=csg.code		
					AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient			
								INNER JOIN dbo.t_Meduslugi mm ON
					c.id=mm.rf_idCase		 
								INNER JOIN vw_sprNomenclMUBodyParts b ON
					mm.MUSurgery=b.codeNomenclMU	
					AND cc1.DateEnd BETWEEN b.dateBeg AND b.dateEnd
							INNER JOIN dbo.t_Coefficient cc ON
				c.id=cc.rf_idCase
				and csg.CodeSLP=cc.Code_SL		
		WHERE csg.CodeSLP=11 AND LEN(mm.Comments)>1 AND ISNUMERIC(mm.Comments)=0 
	) ,
	cteB 
	AS
	(
	SELECT s.id,s.MUSurgery,m.c.value('@num[1]','smallint') AS BodyParts
	FROM cteA s CROSS APPLY s.XMLNum.nodes('/Root/Num') as m(c)
	)
	INSERT #tMU( rf_idCase, MUSurgery, BodyParts) SELECT id,MUSurgery,BodyParts FROM cteB
	
	insert #tError 
	select m.rf_idCase,516
	FROM (
			SELECT rf_idCase,BodyParts from #tMU GROUP BY rf_idCase,BodyParts HAVING COUNT(*)=1
			) m
	
	-----------------------------------------------------------------
	/*
	КСЛП равен 12, то в случае должны быть представлены или (ровно 2 услуги из Номенклатуры: A11.20.017 и A11.20.025.001 и других услуг из Номенклатуры нет)
	*/
	
	;WITH cte1
	AS(
		select c.id,COUNT(DISTINCT mm.GUID_MU) AS CountMU
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile			
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>='20180101'						
								INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v1(idV006,idV008, idV010) ON
					c.rf_idV006=v1.idV006
					AND c.rf_idV008=v1.idV008
					AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
								INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
					m.MES=csg.code						
					AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient	 											
								INNER JOIN dbo.t_Meduslugi mm ON
					c.id=mm.rf_idCase
				--				INNER JOIN dbo.t_Coefficient cc ON
				--c.id=cc.rf_idCase
				--and csg.CodeSLP=cc.Code_SL
								inner JOIN (VALUES('A11.20.017'),('A11.20.025.001')) v(idV001) on
					mm.MUSurgery=v.idV001
		WHERE csg.CodeSLP=12 
		GROUP BY c.id
	)
	INSERT #tError SELECT id,516 FROM cte1 WHERE CountMU=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=cte1.id)
	
	
	/*
	или (ровно 3 услуги из Номенклатуры: A11.20.017 и A11.20.025.001 и A11.20.036 и других услуг из Номенклатуры нет) 
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
								INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v1(idV006,idV008, idV010) ON
					c.rf_idV006=v1.idV006
					AND c.rf_idV008=v1.idV008
					AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
								INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
					m.MES=csg.code										 								
								INNER JOIN dbo.t_Meduslugi mm ON
					c.id=mm.rf_idCase
								inner JOIN (VALUES('A11.20.017'),('A11.20.025.001'),('A11.20.036')) v(idV001) on
					mm.MUSurgery=v.idV001
		WHERE csg.CodeSLP=12 AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m1 WHERE m1.rf_idCase=c.id AND m1.MUSurgery<>v.idV001)
		GROUP BY c.id
	)
	INSERT #tError SELECT id,516 FROM cte1 WHERE CountMU=3 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=cte1.id)
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
								INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v1(idV006,idV008, idV010) ON
					c.rf_idV006=v1.idV006
					AND c.rf_idV008=v1.idV008
					AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
								INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
					m.MES=csg.code			
					AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient				 								
								INNER JOIN dbo.t_Meduslugi mm ON
					c.id=mm.rf_idCase
								INNER JOIN (VALUES('A11.20.017'),('A11.20.031')) v(idV001) on
					mm.MUSurgery=v.idV001
		WHERE csg.CodeSLP=13 AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m1 WHERE m1.rf_idCase=c.id AND m1.MUSurgery<>v.idV001)
		GROUP BY c.id
	)
	INSERT #tError SELECT id,516 FROM cte1 WHERE CountMU=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=cte1.id)
	
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
								INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v1(idV006,idV008, idV010) ON
					c.rf_idV006=v1.idV006
					AND c.rf_idV008=v1.idV008
					AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
								INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
					m.MES=csg.code			
					AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient				 								
								INNER JOIN dbo.t_Meduslugi mm ON
					c.id=mm.rf_idCase
								INNER JOIN (VALUES('A11.20.017'),('A11.20.031')) v(idV001) on
					mm.MUSurgery=v.idV001
		WHERE csg.CodeSLP=14 AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m1 WHERE m1.rf_idCase=c.id AND m1.MUSurgery<>v.idV001)
		GROUP BY c.id
	)
	INSERT #tError SELECT id,516 FROM cte1 WHERE CountMU=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=cte1.id)
	---------------------------2020--------------------
	/*
	КСЛП равен 12, то в случае должны быть представлены или (ровно 2 услуги из Номенклатуры: A11.20.017 и A11.20.025.001 и других услуг из Номенклатуры нет)
	*/
	;WITH cte1
	AS(
		select c.id,COUNT(DISTINCT mm.GUID_MU) AS CountMU
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile			
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>='20200101'						
								INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v1(idV006,idV008, idV010) ON
					c.rf_idV006=v1.idV006
					AND c.rf_idV008=v1.idV008
					AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
								INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
					m.MES=csg.code						
					AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient	 											
								INNER JOIN dbo.t_Meduslugi mm ON
					c.id=mm.rf_idCase
								inner JOIN (VALUES('A11.20.017'),('A11.20.025.001')) v(idV001) on
					mm.MUSurgery=v.idV001
		WHERE csg.CodeSLP=15
		GROUP BY c.id
	)
	INSERT #tError SELECT id,516 FROM cte1 WHERE CountMU=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=cte1.id)
	
	/*
	или (ровно 3 услуги из Номенклатуры: A11.20.017 и A11.20.025.001 и A11.20.036 и других услуг из Номенклатуры нет) 
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
								INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v1(idV006,idV008, idV010) ON
					c.rf_idV006=v1.idV006
					AND c.rf_idV008=v1.idV008
					AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
								INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
					m.MES=csg.code										 								
								INNER JOIN dbo.t_Meduslugi mm ON
					c.id=mm.rf_idCase			
								inner JOIN (VALUES('A11.20.017'),('A11.20.025.001'),('A11.20.036')) v(idV001) on
					mm.MUSurgery=v.idV001
		WHERE csg.CodeSLP=15 AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m1 WHERE m1.rf_idCase=c.id AND m1.MUSurgery<>v.idV001)
		GROUP BY c.id
	)
	INSERT #tError SELECT id,516 FROM cte1 WHERE CountMU=3 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=cte1.id)
	
	
	/*
	(ровно 3 услуги из Номенклатуры: A11.20.017 и A11.20.025.001 и A11.20.028 и других услуг из Номенклатуры нет)  
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
								INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v1(idV006,idV008, idV010) ON
					c.rf_idV006=v1.idV006
					AND c.rf_idV008=v1.idV008
					AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
								INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
					m.MES=csg.code										 								
								INNER JOIN dbo.t_Meduslugi mm ON
					c.id=mm.rf_idCase			
								inner JOIN (VALUES('A11.20.017'),('A11.20.025.001'),('A11.20.028')) v(idV001) on
					mm.MUSurgery=v.idV001
		WHERE csg.CodeSLP=15 AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m1 WHERE m1.rf_idCase=c.id AND m1.MUSurgery<>v.idV001)
		GROUP BY c.id
	)
	INSERT #tError SELECT id,516 FROM cte1 WHERE CountMU=3 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=cte1.id)
	
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
								INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v1(idV006,idV008, idV010) ON
					c.rf_idV006=v1.idV006
					AND c.rf_idV008=v1.idV008
					AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
								INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
					m.MES=csg.code			
					AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient				 								
								INNER JOIN dbo.t_Meduslugi mm ON
					c.id=mm.rf_idCase
								INNER JOIN (VALUES('A11.20.017'),('A11.20.031')) v(idV001) on
					mm.MUSurgery=v.idV001
		WHERE csg.CodeSLP=16 AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m1 WHERE m1.rf_idCase=c.id AND m1.MUSurgery<>v.idV001)
		GROUP BY c.id
	)
	INSERT #tError SELECT id,516 FROM cte1 WHERE CountMU=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=cte1.id)
	
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
								INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v1(idV006,idV008, idV010) ON
					c.rf_idV006=v1.idV006
					AND c.rf_idV008=v1.idV008
					AND c.rf_idV010=ISNULL(v1.idV010,c.rf_idV010)
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
								INNER JOIN dbo.vw_CSG_CSLP2019 csg ON
					m.MES=csg.code			
					AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient				 								
								INNER JOIN dbo.t_Meduslugi mm ON
					c.id=mm.rf_idCase
								INNER JOIN (VALUES('A11.20.017'),('A11.20.031')) v(idV001) on
					mm.MUSurgery=v.idV001
		WHERE csg.CodeSLP=17 AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m1 WHERE m1.rf_idCase=c.id AND m1.MUSurgery<>v.idV001)
		GROUP BY c.id
	)
	INSERT #tError SELECT id,516 FROM cte1 WHERE CountMU=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=cte1.id)
	

	--Если код КСЛП  равен 18, то в одном из тегов CRIT должно быть указано значение "cr6"
	--07.09.2020
	
	INSERT #tError
	select DISTINCT c.id,516
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'												
							INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v(idV006,idV008, idV010) ON
			c.rf_idV006=v.idV006
			AND c.rf_idV008=v.idV008
			AND c.rf_idV010=ISNULL(v.idV010,c.rf_idV010)
							INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase                          
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN t_Coefficient cc ON
				c.id=cc.rf_idCase  
							INNER JOIN dbo.vw_CSG_CSLP2019 cs ON
				m.MES=cs.code                    										
				AND cc.Code_SL=cs.CodeSLP	 				
	  WHERE  m.TypeMES=2 AND co.DateEnd BETWEEN cs.dateBegSLP AND cs.dateEndSLP	AND cs.CodeSLP =18
			AND NOT EXISTS(SELECT 1 FROM dbo.t_AdditionalCriterion aa WHERE aa.rf_idCase=c.id AND aa.rf_idAddCretiria='cr6' )
DROP TABLE #tMU
END
-----------------------------------------------2021-------------------------------------
ELSE
BEGIN
select code,CodeSLP,dateBegSLP,dateEndSLP,DateBegCoefficient,DateEndCoefficient INTO #KSLP FROM vw_CSG_CSLP2019 WHERE dateBegSLP>='20210101'

	insert #tError
	select DISTINCT m.rf_idCase,516
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase									
							INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v(idV006,idV008, idV010) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
				AND c.rf_idV010=ISNULL(v.idV010,c.rf_idV010)
						INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.#KSLP csg ON
				m.MES=csg.code						
				AND co.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP					
							LEFT JOIN dbo.t_ProfileOfBed p ON
				c.id=p.rf_idCase									
	WHERE csg.CodeSLP=1 AND c.Age>75 AND p.rf_idV020!=16 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient cc WHERE cc.rf_idCase=c.id AND cc.Code_SL=1)	

	/*
	Если Z_SL\SL\KD>70, то должен быть применен КСЛП=10. 
	*/
	insert #tError
	select DISTINCT m.rf_idCase,516
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase					
							INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v(idV006,idV008, idV010) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
				AND c.rf_idV010=ISNULL(v.idV010,c.rf_idV010)
							INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.#KSLP csg ON
				m.MES=csg.code		
				AND co.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP	
	WHERE csg.CodeSLP=10 AND c.KD>70 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient cc WHERE cc.rf_idCase=c.id AND cc.Code_SL=10)	

	/*
	Если в составе случая (одного SL)  в тегах USL представлены  услуги, сочетание 2-ух из которых указано в таблице sprCombinedSyrgery (OMS_NSI)
	сочетание пары услуг соответствует хотя бы одной записи в таблице), то должен быть применен КСЛП=6
	*/

	
SELECT CombinedSurgeryId ,Sur1 INTO #tCombine FROM oms_nsi.dbo.sprCombinedSurgery 
UNION ALL
SELECT CombinedSurgeryId,Sur2 FROM oms_nsi.dbo.sprCombinedSurgery

	insert #tError
	select DISTINCT m.rf_idCase,516
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase									
							INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v(idV006,idV008, idV010) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
				AND c.rf_idV010=ISNULL(v.idV010,c.rf_idV010)
						INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN #KSLP csg ON
				m.MES=csg.code						
				AND co.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP										
	WHERE csg.CodeSLP=6  AND EXISTS(SELECT r.CombinedSurgeryId,t.rf_idCase
					FROM (SELECT DISTINCT m.rf_idCase,MUSurgery 
							FROM (SELECT rf_idCase 
								  FROM dbo.t_Meduslugi WHERE rf_idCase=c.id and MUSurgery IS NOT NULL 
								  GROUP BY rf_idCase HAVING COUNT(*)>1) t INNER JOIN dbo.t_Meduslugi m ON
												t.rf_idCase=m.rf_idCase
							WHERE m.rf_idCase=c.id)t INNER JOIN #tCombine r ON
									t.MUSurgery=r.Sur1
					GROUP BY t.rf_idCase,r.CombinedSurgeryId
					HAVING COUNT(*)>1
					)	AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient cc WHERE cc.rf_idCase=c.id AND cc.Code_SL=6)
	/*
	если код КСЛП равен 7, то в случае присутствуют услуги из номенклатуры, для которых в поле COMENTU через 
	запятую перечислены различающиеся коды парных органов/частей тела, либо в случае присутствуют как минимум 
	2 услуги из Номенклатуры, у которых в поле COMENTU указаны различающиеся коды парных органов/ частей тела
	*/
	
	--если КСЛП =11, то операции должны быть в ремках одного случая
	;WITH cte
	AS(
	SELECT c.id,COUNT(DISTINCT mm.GUID_MU) AS CountMU
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20210101'
						INNER JOIN dbo.t_CompletedCase cc1 ON
	             r.id=cc1.rf_idRecordCase						
							INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v(idV006,idV008, idV010) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
				AND c.rf_idV010=ISNULL(v.idV010,c.rf_idV010)
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.#KSLP csg ON
				m.MES=csg.code				
				AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
				AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient	
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase		 
							INNER JOIN oms_nsi.dbo.sprNomenclMUBodyParts b ON
				mm.MUSurgery=b.codeNomenclMU	
				AND cc1.DateEnd BETWEEN b.dateBeg AND b.dateEnd 		
	WHERE csg.CodeSLP=7 AND len(mm.Comments) IN(1,2) AND mm.Comments IS NOT NULL 
	GROUP BY c.id
	)
	insert #tError select DISTINCT id,516 FROM cte WHERE CountMU=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=cte.id)
	
	;WITH cte
	AS(
	SELECT c.id,COUNT(DISTINCT mm.GUID_MU) AS CountMU
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20210101'	
							INNER JOIN dbo.t_CompletedCase cc1 ON
	             r.id=cc1.rf_idRecordCase							
							INNER JOIN (values(1,31,33),(2,43,null),(2,33,null)) v(idV006,idV008, idV010) ON
				c.rf_idV006=v.idV006
				AND c.rf_idV008=v.idV008
				AND c.rf_idV010=ISNULL(v.idV010,c.rf_idV010)
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.#KSLP csg ON
				m.MES=csg.code	
				AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient				
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase		 
							INNER JOIN oms_nsi.dbo.sprNomenclMUBodyParts b ON
				mm.MUSurgery=b.codeNomenclMU	
				AND cc1.DateEnd BETWEEN b.dateBeg AND b.dateEnd 
							INNER JOIN dbo.t_Coefficient cc ON
				c.id=cc.rf_idCase
				and csg.CodeSLP=cc.Code_SL					
	WHERE csg.CodeSLP=7 AND LEN( REPLACE(mm.Comments,',','')) IN(3,4,5) AND mm.Comments IS NOT NULL
	GROUP BY c.id
	)
	insert #tError select DISTINCT id,516 FROM cte WHERE CountMU=1 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=cte.id)
	
	--нету ни одной услуги из номенклатуры
	
	insert #tError
	select DISTINCT m.rf_idCase,516
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'									
							INNER JOIN dbo.t_CompletedCase cc1 ON
	             r.id=cc1.rf_idRecordCase	
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.#KSLP csg ON
				m.MES=csg.code							
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase
						INNER JOIN dbo.t_Coefficient cc ON
				c.id=cc.rf_idCase
				and csg.CodeSLP=cc.Code_SL		 			
	WHERE csg.CodeSLP=7 AND LEN(mm.Comments)=1 AND NOT EXISTS(SELECT 1 FROM vw_sprNomenclMUBodyParts b 
																WHERE mm.MUSurgery=b.codeNomenclMU	AND mm.Comments=CAST(b.code AS VARCHAR(4))
																	AND cc1.DateEnd BETWEEN b.dateBeg AND b.dateEnd 
																)			
	
	
	;WITH cteA
	AS(
		SELECT c.id,mm.MUSurgery,cc1.DateEnd, (CONVERT(xml,replace(('<Root><Num num="'+mm.Comments)+'" /></Root>',',','" /><Num num="'),0))	AS XMLNum
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile			
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>='20210101'
								INNER JOIN dbo.t_CompletedCase cc1 ON
	             r.id=cc1.rf_idRecordCase											
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
								INNER JOIN dbo.#KSLP csg ON
					m.MES=csg.code	
					AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient				
								INNER JOIN dbo.t_Meduslugi mm ON
					c.id=mm.rf_idCase		 
								INNER JOIN dbo.t_Coefficient cc ON
				c.id=cc.rf_idCase
				and csg.CodeSLP=cc.Code_SL
								INNER JOIN vw_sprNomenclMUBodyParts b ON
					mm.MUSurgery=b.codeNomenclMU			
					AND cc1.DateEnd BETWEEN b.dateBeg AND b.dateEnd
		WHERE csg.CodeSLP=7 AND LEN(mm.Comments)>1 AND mm.Comments IS NOT NULL
	) ,
	cteB 
	AS
	(
	SELECT s.id,s.MUSurgery,m.c.value('@num[1]','smallint') AS BodyParts
	FROM cteA s CROSS APPLY s.XMLNum.nodes('/Root/Num') as m(c)
	)
	insert #tError SELECT distinct id,516
	FROM cteB
	WHERE NOT EXISTS(SELECT 1 FROM vw_sprNomenclMUBodyParts b WHERE cteB.MUSurgery=b.codeNomenclMU AND BodyParts=b.code AND DateEnd BETWEEN b.dateBeg AND b.dateEnd)
	
	
	/*
	не может быть повторений внутри одного COMMENTU
	*/
	
	
	;WITH cteA
	AS(
		SELECT c.id,mm.MUSurgery, mm.GUID_MU,(CONVERT(xml,replace(('<Root><Num num="'+mm.Comments)+'" /></Root>',',','" /><Num num="'),0))	AS XMLNum
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile			
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>='20210101'						
								INNER JOIN dbo.t_CompletedCase cc1 ON
	             r.id=cc1.rf_idRecordCase	
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
								INNER JOIN dbo.#KSLP csg ON
					m.MES=csg.code		
					AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient			
								INNER JOIN dbo.t_Meduslugi mm ON
					c.id=mm.rf_idCase		 
								INNER JOIN dbo.t_Coefficient cc ON
				c.id=cc.rf_idCase
				and csg.CodeSLP=cc.Code_SL
								INNER JOIN #tCSG b ON
					mm.MUSurgery=b.codeNomenclMU		
					AND cc1.DateEnd BETWEEN b.dateBeg AND b.dateEnd
		WHERE csg.CodeSLP=7 AND LEN(mm.Comments)>1 AND mm.Comments IS NOT NULL
	) ,
	cteB 
	AS
	(
	SELECT DISTINCT s.id,s.Guid_MU,s.MUSurgery,m.c.value('@num[1]','smallint') AS BodyParts
	FROM cteA s CROSS APPLY s.XMLNum.nodes('/Root/Num') as m(c)
	),
	cteC
	as
	(
		SELECT id,Guid_MU,MUSurgery,BodyParts from cteB GROUP BY id,Guid_MU,MUSurgery,BodyParts HAVING COUNT(*)>1
	)
	insert #tError SELECT distinct id,516
	FROM cteC
	--проверяем что бы при КСЛП =7 были только цифры
	insert #tError 
	select m.rf_idCase,516
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20210101'									
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.#KSLP csg ON
				m.MES=csg.code			
				AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient		
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase		 
						INNER JOIN dbo.t_Coefficient cc ON
				c.id=cc.rf_idCase
				and csg.CodeSLP=cc.Code_SL
							INNER JOIN vw_sprNomenclMUBodyParts b ON
				mm.MUSurgery=b.codeNomenclMU			
				AND mm.Comments<>CAST(b.code AS VARCHAR(4))		
	WHERE csg.CodeSLP=7 AND ISNUMERIC(mm.Comments)=0 
	---проверяем на то что бы было несколько значений в BodyParts в одном случаи
	select m.rf_idCase,mm.MUSurgery,CAST(mm.Comments AS SMALLINT) AS BodyParts
	INTO #tMU2
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20210101'	
							INNER JOIN dbo.t_CompletedCase cc1 ON
	             r.id=cc1.rf_idRecordCase									
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.#KSLP csg ON
				m.MES=csg.code	
				AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient				
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase		 
							INNER JOIN vw_sprNomenclMUBodyParts b ON
				mm.MUSurgery=b.codeNomenclMU			
				AND mm.Comments<>CAST(b.code AS VARCHAR(4))		
				AND cc1.DateEnd BETWEEN b.dateBeg AND b.dateEnd
							INNER JOIN dbo.t_Coefficient cc ON
				c.id=cc.rf_idCase
				and csg.CodeSLP=cc.Code_SL
	WHERE csg.CodeSLP=7 AND LEN(mm.Comments)=1 AND ISNUMERIC(mm.Comments)=0 AND mm.Comments IS NOT NULL
	
	;WITH cteA
	AS(
		SELECT c.id,mm.MUSurgery, (CONVERT(xml,replace(('<Root><Num num="'+mm.Comments)+'" /></Root>',',','" /><Num num="'),0))	AS XMLNum
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile			
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>='20210101'
								INNER JOIN dbo.t_CompletedCase cc1 ON
	             r.id=cc1.rf_idRecordCase											
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
								INNER JOIN dbo.#KSLP csg ON
					m.MES=csg.code		
					AND c.DateEnd BETWEEN csg.dateBegSLP AND csg.dateEndSLP
					AND c.DateEnd BETWEEN csg.DateBegCoefficient AND csg.DateEndCoefficient			
								INNER JOIN dbo.t_Meduslugi mm ON
					c.id=mm.rf_idCase		 
								INNER JOIN vw_sprNomenclMUBodyParts b ON
					mm.MUSurgery=b.codeNomenclMU	
					AND cc1.DateEnd BETWEEN b.dateBeg AND b.dateEnd
							INNER JOIN dbo.t_Coefficient cc ON
				c.id=cc.rf_idCase
				and csg.CodeSLP=cc.Code_SL		
		WHERE csg.CodeSLP=7 AND LEN(mm.Comments)>1 AND ISNUMERIC(mm.Comments)=0 
	) ,
	cteB 
	AS
	(
	SELECT s.id,s.MUSurgery,m.c.value('@num[1]','smallint') AS BodyParts
	FROM cteA s CROSS APPLY s.XMLNum.nodes('/Root/Num') as m(c)
	)
	INSERT #tMU2( rf_idCase, MUSurgery, BodyParts) SELECT id,MUSurgery,BodyParts FROM cteB
	
	insert #tError 
	select m.rf_idCase,516
	FROM (
			SELECT rf_idCase,BodyParts from #tMU2 GROUP BY rf_idCase,BodyParts HAVING COUNT(*)=1
			) m
	
END

DROP TABLE #tCSG
DROP TABLE #tMU2
DROP TABLE #KSLP
DROP TABLE #tCombine