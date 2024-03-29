USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test516]    Script Date: 16.01.2020 10:54:49 ******/
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
						INNER JOIN dbo.t_CompletedCase cc ON
             r.id=cc.rf_idRecordCase
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
			AND cc.DateEnd BETWEEN b.dateBeg AND b.dateEnd 						
WHERE csg.CodeSLP=11 AND DATALENGTH(mm.Comments) IN(1,3)  AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)
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
						INNER JOIN dbo.t_Coefficient cc ON
			c.id=cc.rf_idCase
			and csg.CodeSLP=cc.Code_SL					
WHERE csg.CodeSLP=11 AND len(mm.Comments)=1 AND mm.Comments IS NOT NULL 
GROUP BY c.id
)
insert #tError select DISTINCT id,516 FROM cte WHERE CountMU<2

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
WHERE csg.CodeSLP=11 AND LEN(mm.Comments)=3 AND mm.Comments IS NOT NULL
GROUP BY c.id
)
insert #tError select DISTINCT id,516 FROM cte WHERE CountMU!=1

--нету ни одной услуги из номенклатуры
;WITH cte
AS(
SELECT c.id,mes,mm.MUSurgery,mm.Comments,cc1.DateEnd
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
						INNER JOIN dbo.t_Coefficient cc ON
			c.id=cc.rf_idCase
			and csg.CodeSLP=cc.Code_SL						
WHERE csg.CodeSLP=11 AND mm.MUSurgery IS NOT NULL AND mm.Comments IS NOT null AND LEN(mm.Comments)=1 AND mm.Comments IS NOT NULL
)
INSERT #tError
SELECT c1.id,516
FROM cte c1 INNER JOIN cte c2 ON
		c1.id=c2.id
		AND c1.Comments <> c2.Comments
WHERE NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprNomenclMUBodyParts b WHERE c1.MUSurgery=b.codeNomenclMU AND c1.DateEnd BETWEEN b.dateBeg AND b.dateEnd )

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
SELECT DISTINCT codeNomenclMU ,dateBeg, dateEnd INTO #tCSG FROM vw_sprNomenclMUBodyParts

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
							INNER JOIN dbo.t_Coefficient cc ON
			c.id=cc.rf_idCase
			and csg.CodeSLP=cc.Code_SL
							inner JOIN (VALUES('A11.20.017'),('A11.20.025.001')) v(idV001) on
				mm.MUSurgery=v.idV001
	WHERE csg.CodeSLP=12 
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
						INNER JOIN dbo.t_Coefficient cc ON
			c.id=cc.rf_idCase
			and csg.CodeSLP=cc.Code_SL
						INNER JOIN (VALUES('A11.20.017'),('A11.20.025.001')) v(idV001) on			   
				mm.MUSurgery=v.idV001			
WHERE csg.CodeSLP=12 --AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)
	 AND NOT EXISTS(SELECT 1 FROM t_Meduslugi m WHERE mm.MUSurgery NOT IN ('A11.20.017','A11.20.025.001') AND m.rf_idCase=c.id) 

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
							INNER JOIN dbo.t_Coefficient cc ON
			c.id=cc.rf_idCase
			and csg.CodeSLP=cc.Code_SL
							left JOIN (VALUES('A11.20.017'),('A11.20.025.001'),('A11.20.036')) v(idV001) on
				mm.MUSurgery=v.idV001
	WHERE csg.CodeSLP=12 
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
						INNER JOIN (VALUES('A11.20.017'),('A11.20.025.001'),('A11.20.036')) v(idV001) on
				mm.MUSurgery=v.idV001			
WHERE csg.CodeSLP=12 --AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id) 
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
							INNER JOIN dbo.t_Coefficient cf ON
				c.id=cf.rf_idCase
				AND csg.CodeSLP=cf.Code_SL
							INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase
							inner JOIN (VALUES('A11.20.017'),('A11.20.025.001'),('A11.20.028')) v(idV001) on
				mm.MUSurgery=v.idV001
	WHERE csg.CodeSLP=12 --AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id) 
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
						INNER JOIN (VALUES('A11.20.017'),('A11.20.025.001'),('A11.20.028')) v(idV001) on
				mm.MUSurgery=v.idV001			
WHERE csg.CodeSLP=12 --AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)
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
	WHERE csg.CodeSLP=13 --and NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)
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
WHERE csg.CodeSLP=13 --AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)
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
							INNER JOIN (VALUES('A11.20.017'),('A11.20.030.001')) v(idV001) on
				mm.MUSurgery=v.idV001
	WHERE csg.CodeSLP=14 --and NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)
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
						INNER JOIN (VALUES('A11.20.017'),('A11.20.030.001')) v(idV001) on
				mm.MUSurgery=v.idV001			
WHERE csg.CodeSLP=14-- AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id) 
	AND NOT EXISTS(SELECT 1 FROM t_Meduslugi m WHERE mm.MUSurgery NOT IN ('A11.20.017','A11.20.030.001') AND m.rf_idCase=c.id) 
DROP TABLE #tMU
DROP TABLE #tCSG