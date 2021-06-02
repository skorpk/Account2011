USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='186002' AND ReportYear=2021 AND NumberRegister=28

SELECT * FROM  vw_getIdFileNumber WHERE id=@idFile

declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6),
		@typeFile char(1)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO, @typeFile=UPPER(f.TypeFile)
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

SELECT * FROM dbo.vw_CSG_CSLP2019 csg WHERE code='st17.003'

select DISTINCT m.rf_idCase,518,cc.Code_SL,m.MES
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
	select DISTINCT m.rf_idCase,518,m.MES,cc.Coefficient,cc.Code_SL,co.GUID_ZSL,c.NumberHistoryCase
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
											
--SELECT * FROM dbo.vw_CSG_CSLP2019 csg WHERE code='st17.003'	AND dateBegSLP>='20210101'												

	select DISTINCT m.rf_idCase,518,m.MES
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
----------------------------------2019---------------------- 
select DISTINCT m.rf_idCase,518,'error',m.MES,c.NumberHistoryCase,cc.Code_SL,c.Age
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
WHERE  m.TypeMES=2 AND co.DateEnd BETWEEN cs.dateBegSLP AND cs.dateEndSLP AND cs.CodeSLP=1 AND (c.Age<75 OR p.rf_idV020=16 )

/*
ID_SL=7, то в случае присутствуют услуги из номенклатуры, для которых в поле COMENTU через запятую перечислены различающиеся коды парных органов/частей тела, 
либо в случае присутствуют как минимум 2 услуги из Номенклатуры, у которых в поле COMENTU указаны различающиеся коды парных органов/ частей тела
*/
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