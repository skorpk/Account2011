USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test518]    Script Date: 25.01.2021 9:21:06 ******/
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

IF @year<2021
begin	
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
	  WHERE  m.TypeMES=2 AND co.DateEnd BETWEEN cs.dateBegSLP AND cs.dateEndSLP	AND cs.CodeSLP IN(12 ,15)
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
	  WHERE  m.TypeMES=2 AND co.DateEnd BETWEEN cs.dateBegSLP AND cs.dateEndSLP	AND cs.CodeSLP IN(13,14,16,17)
			AND NOT EXISTS(SELECT 1 FROM dbo.vw_MeduslugiCSLP_13 WHERE rf_idCase=c.id AND ID_SL=cs.CodeSLP )

--Если код КСЛП  равен 18, то в одном из тегов CRIT должно быть указано значение "cr6"
--07.09.2020
insert #tError
select DISTINCT c.id,518
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_Coefficient co ON
            c.id=co.rf_idCase
WHERE co.Code_SL=18 AND NOT EXISTS(SELECT 1 FROM dbo.t_AdditionalCriterion aa WHERE aa.rf_idAddCretiria='cr6' AND aa.rf_idCase=c.id)
END
ELSE----------------------------для 2021 года---------------------------------
BEGIN 
	
	INSERT #tError
	select DISTINCT m.rf_idCase,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20210101'												
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
	  WHERE  m.TypeMES=2 AND co.DateEnd BETWEEN cs.dateBegSLP AND cs.dateEndSLP	AND cs.CodeSLP=1 AND (c.Age<76 OR p.rf_idV020=16 )

/*
ID_SL=7, то в случае присутствуют услуги из номенклатуры, для которых в поле COMENTU через запятую перечислены различающиеся коды парных органов/частей тела, 
либо в случае присутствуют как минимум 2 услуги из Номенклатуры, у которых в поле COMENTU указаны различающиеся коды парных органов/ частей тела
*/
	INSERT #tError
	select DISTINCT m.rf_idCase,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20210101'												
							INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase                          
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN t_Coefficient cc ON
				c.id=cc.rf_idCase  
							INNER JOIN dbo.vw_CSG_CSLP2019 cs ON
				m.MES=cs.code                    										
				AND cc.Code_SL=cs.CodeSLP	 				
	  WHERE  m.TypeMES=2 AND co.DateEnd BETWEEN cs.dateBegSLP AND cs.dateEndSLP	AND cs.CodeSLP=7 
			AND NOT EXISTS(SELECT 1 FROM dbo.vw_MeduslugiBodyParts WHERE rf_idCase=c.id )

/*
КСЛП=10 то KD>70
*/
	INSERT #tError
	select DISTINCT m.rf_idCase,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20210101'												
							INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase                          
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN t_Coefficient cc ON
				c.id=cc.rf_idCase  
							INNER JOIN dbo.vw_CSG_CSLP2019 cs ON
				m.MES=cs.code                    										
				AND cc.Code_SL=cs.CodeSLP	 				
	  WHERE  m.TypeMES=2 AND co.DateEnd BETWEEN cs.dateBegSLP AND cs.dateEndSLP	AND cs.CodeSLP=10
			AND c.KD<71

/*
Если КСЛП=6, то в составе случая (одного SL)  в тегах USL должны быть представлены  услуги, 
сочетание 2-ух из которых должно быть найдено  в таблице sprCombinedSyrgery (OMS_NSI)…(сочетание пары услуг соответствует хотя бы одной записи в таблице)
*/
	INSERT #tError
	select DISTINCT m.rf_idCase,518
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile			
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20210101'												
							INNER JOIN dbo.t_CompletedCase co ON
				r.id=co.rf_idRecordCase                          
							INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
							INNER JOIN t_Coefficient cc ON
				c.id=cc.rf_idCase  
							INNER JOIN dbo.vw_CSG_CSLP2019 cs ON
				m.MES=cs.code                    										
				AND cc.Code_SL=cs.CodeSLP	 				
	  WHERE  m.TypeMES=2 AND co.DateEnd BETWEEN cs.dateBegSLP AND cs.dateEndSLP	AND cs.CodeSLP=6
	  AND NOT EXISTS(SELECT r.CombinedSurgeryId,t.rf_idCase
					FROM (SELECT DISTINCT rf_idCase,MUSurgery FROM dbo.t_Meduslugi WHERE rf_idCase=c.id) t INNER JOIN (SELECT CombinedSurgeryId ,Sur1 FROM oms_nsi.dbo.sprCombinedSurgery 
																														UNION ALL
																														SELECT CombinedSurgeryId,Sur2 FROM oms_nsi.dbo.sprCombinedSurgery ) r ON
									t.MUSurgery=r.Sur1
					GROUP BY t.rf_idCase,r.CombinedSurgeryId
					HAVING COUNT(*)>1
					)
END 