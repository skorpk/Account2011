USE RegisterCases
go

CREATE TABLE #tNomencl(code VARCHAR(20), typeSPR TINYINT, dateBeg DATE, dateEnd date)
INSERT #tNomencl( code,typeSPR,dateBeg,dateEnd ) SELECT codeNomenclMU,2,dateBeg,dateEnd FROM oms_nsi.dbo.sprNomenclMUBodyParts

CREATE TABLE #tUsl (rf_idV006 TINYINT, rf_idV008 SMALLINT)
INSERT #tUsl( rf_idV006, rf_idV008 ) VALUES  ( 1,31),(2,null)

SELECT DISTINCT f.id,f.CodeM,a.NumberRegister,m.Comments
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth>10
		AND a.ReportYear=2019
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								             
		AND c.DateEnd>='20190101'
				INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase				
				INNER JOIN #tUsl u ON
		c.rf_idV006=u.rf_idV006
		AND c.rf_idV008=ISNULL(u.rf_idV008,c.rf_idV008) 
			  INNER JOIN dbo.t_Meduslugi m ON			  
		c.id=m.rf_idCase			  
			  INNER JOIN #tNomencl n ON
		m.MUSurgery=n.code            
where f.DateRegistration>'20191101' AND f.TypeFile='H' AND typeSPR=2  AND  len(ISNULL(m.Comments,''))>0 
ORDER BY id
GO

DROP TABLE #tNomencl
GO
DROP TABLE #tUsl