USE RegisterCases
GO
DECLARE @idFile INT


select @idFile=id FROM dbo.vw_getIdFileNumber WHERE ReportYear=2021 AND CodeM='611001' AND NumberRegister=79
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6)
		
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod=rc.rf_idMO
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile
SELECT DISTINCT codeNomenclMU ,dateBeg, dateEnd INTO #tCSG FROM vw_sprNomenclMUBodyParts
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))

select code,CodeSLP,dateBegSLP,dateEndSLP,DateBegCoefficient,DateEndCoefficient INTO #KSLP FROM vw_CSG_CSLP2019 WHERE dateBegSLP>='20210101'

	select DISTINCT m.rf_idCase,516,c.idRecordCase,c.Age
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
	
	SELECT * FROM t_Coefficient WHERE rf_idCase IN(141634292,141634421)
	/*
	Если Z_SL\SL\KD>70, то должен быть применен КСЛП=10. 
	*/
	
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

	select DISTINCT m.rf_idCase,516,'Error',csg.code
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
	 select DISTINCT id,516 FROM cte WHERE CountMU=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=cte.id)
	
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
	 select DISTINCT id,516 FROM cte WHERE CountMU=1 AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=cte.id)
	
	--нету ни одной услуги из номенклатуры
	
	
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
	 SELECT distinct id,516
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
	 SELECT distinct id,516
	FROM cteC
	--проверяем что бы при КСЛП =7 были только цифры
	 
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
	
	 
	select m.rf_idCase,516
	FROM (
			SELECT rf_idCase,BodyParts from #tMU2 GROUP BY rf_idCase,BodyParts HAVING COUNT(*)=1
			) m
	
go
DROP TABLE #tCSG
go
DROP TABLE #tMU2
GO
DROP TABLE #KSLP
GO
DROP TABLE #tCombine