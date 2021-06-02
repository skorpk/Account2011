USE [RegisterCases]
GO	   
create PROC [dbo].[usp_Test437]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
;WITH cte
AS(
SELECT c.id, COUNT(c.id) AS COUNTMU
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'		 	  
				INNER JOIN dbo.t_MES mm ON
		c.id=mm.rf_idCase              
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase         
				INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase     
				LEFT JOIN dbo.t_ONK_USL u ON
		c.id=u.rf_idCase
		AND m.GUID_MU=u.GUID_MU
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006<3 AND m.MUSurgery IS NOT NULL AND mm.mes NOT IN('1138.0','2051.0') 
GROUP BY c.id
)
INSERT #tError SELECT c.id,437 FROM cte c WHERE CountMU=0


insert #tError
SELECT DISTINCT c.id,437
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'		 	  
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase         
				INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase  
				INNER JOIN dbo.t_ONK_USL u ON
		c.id=u.rf_idCase 
		AND u.GUID_MU=m.GUID_MU  				            
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006<3 AND m.MUSurgery IS NOT NULL AND c.rf_idV008<>32 
		AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.V001 WHERE IDRB=m.MUSurgery AND ISNULL(ID_TLech,u.rf_idN013)=u.rf_idN013) 

/*
Если (USL_OK in (1,2) and VID_POM=32), то по коду законченного случая в теге CODE_MES1 определяется вид лечения: комбинированное или монолечение. 
Под комбинированным лечением понимается лечение, при котором обязательно оказываются услуги как минимум 2 разных типов, т.е в случай должны быть обязательно включены услуги из 2 разных типов. 
Монолечение предполагает оказание услуг как минимум одного типа, хотя могут присутствовать услуги и др. типа. 
В НСИ устанавливается соответствие кодов законченных случаев ВМП и видов лечения (1-комбинированное (типы услуг объединены операндом «and»), 2 –монолечение (типы услуг объединены операндом «or»)), 
один код ЗС соответствует одному виду лечения. В НСИ устанавливается соответствие одного кода ЗС одному или нескольким типам услугам (типы из N013).  
Далее, проводится проверка на наличие в представленных в  случае услугах из номенклатуры хотя бы одной услуги из номенклатуры с указанным типом для кодов ЗС с видом «монолечение». 
Для «комбинированного» лечения проводится проверка на наличие в представленных в случае услуг из номенклатуры хотя бы одной услуги, но каждого типа, определенного в НСИ.
*/

select convert(varchar, C.MUGroupCode) + '.' + convert(varchar, B.MUUnGroupCode) + '.' + CONVERT(varchar, A.MUCode) AS CodeMU,
       COUNT(E.ID_TLech) AS CountN13
INTO #tMU
from oms_nsi.dbo.sprMU A
     INNER JOIN oms_nsi.dbo.sprMUUnGroup B on B.MUUnGroupId = A.rf_MUUnGroupId
     INNER JOIN oms_nsi.dbo.sprMUGroup C on C.MUGroupId = B.rf_MUGroupId
     INNER JOIN oms_nsi.dbo.sprMUN013 D on D.rf_MUId = A.MUId
     INNER JOIN oms_nsi.dbo.sprN013 E on D.rf_sprN013Id = E.sprN013Id
WHERE a.typeHealing=1
GROUP BY convert(varchar, C.MUGroupCode) + '.' + convert(varchar, B.MUUnGroupCode) + '.' + CONVERT(varchar, A.MUCode) 

---проверка для комбинированного лечения должны присутствовать все виды
;WITH cteCountMU
as
(
SELECT DISTINCT c.id,m.MES, COUNT(DISTINCT u.rf_idN013) AS CountUSL_OK
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'		 	  
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase         
				INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase  
				INNER JOIN dbo.t_ONK_USL u ON
		c.id=u.rf_idCase   
				INNER JOIN dbo.vw_sprMUAndN0013 n13 ON
		m.MES=n13.CodeMU              
		AND u.rf_idN013=n13.ID_TLech
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006<3 AND c.rf_idV008=32 AND n13.typeHealing=1 
GROUP BY c.id, m.MES
)
INSERT #tError SELECT c.id,437	FROM cteCountMU c WHERE NOT EXISTS(SELECT * FROM #tMU WHERE CodeMU=c.MES AND CountN13=c.CountUSL_OK)

--для монолечения должна быть хотя бы одна
;WITH cteCountMU
as
(
SELECT DISTINCT c.id, COUNT(DISTINCT n13_2.ID_TLech) AS countMU
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'		 	  
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase         
				INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase  
				INNER JOIN dbo.t_ONK_USL u ON
		c.id=u.rf_idCase   
				INNER JOIN dbo.vw_sprMUAndN0013 n13 ON
		m.MES=n13.CodeMU      
				LEFT JOIN  dbo.vw_sprMUAndN0013 n13_2 ON
		m.MES=n13.CodeMU   
		AND u.rf_idN013=n13_2.ID_TLech      
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006<3 AND c.rf_idV008=32 AND n13.typeHealing=2 AND n13_2.typeHealing=2
GROUP BY c.id
)
INSERT #tError SELECT c.id,437 FROM cteCountMU c WHERE CountMU=0

---для монолечения
;WITH cteCountMU
AS(
SELECT DISTINCT c.id,COUNT(v1.IDRB) AS CountMU
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'		
				INNER JOIN dbo.t_MES mm ON
		c.id=mm.rf_idCase 	  
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase         
				INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase  		
				INNER JOIN dbo.t_ONK_USL u ON
		c.id=u.rf_idCase
		AND u.GUID_MU=m.GUID_MU  
				INNER JOIN dbo.vw_sprMUAndN0013 n13 ON
		mm.MES=n13.CodeMU
		AND u.rf_idN013=n13.ID_TLech
				left JOIN oms_nsi.dbo.V001 v1 ON
		m.MUSurgery=v1.IDRB
		AND n13.ID_TLech=v1.ID_TLech                
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006<3 AND c.rf_idV008=32 AND n13.typeHealing=2
GROUP BY c.id
)
INSERT #tError SELECT c.id,437 FROM cteCountMU c WHERE CountMU=0


---для комбинированного
;WITH cteCountMU
AS(
SELECT DISTINCT c.id,mm.MES,COUNT(v1.IDRB) AS CountMU
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'		
				INNER JOIN dbo.t_MES mm ON
		c.id=mm.rf_idCase 	  
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase         
				INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase  
				INNER JOIN dbo.t_ONK_USL u ON
		c.id=u.rf_idCase
		AND u.GUID_MU=m.GUID_MU  
				INNER JOIN dbo.vw_sprMUAndN0013 n13 ON
		mm.MES=n13.CodeMU
		AND u.rf_idN013=n13.ID_TLech
				left JOIN oms_nsi.dbo.V001 v1 ON
		m.MUSurgery=v1.IDRB
		AND n13.ID_TLech=v1.ID_TLech                
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006<3 AND c.rf_idV008=32 AND n13.typeHealing=1
GROUP BY c.id, mm.MES
)
INSERT #tError SELECT c.id,437 FROM cteCountMU c WHERE NOT EXISTS(SELECT * FROM #tMU WHERE CodeMU=c.MES AND CountN13=c.CountMU)

DROP TABLE #tMU

go