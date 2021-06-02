USE RegisterCases
GO
create table #tError (rf_idCase bigint,ErrorNumber smallint)

INSERT #tError( rf_idCase, ErrorNumber )
VALUES  ( 105753684,406)

SELECT cc.id,e.ErrorNumber
FROM #tError e INNER JOIN t_Case c ON 
		e.rf_idCase=c.id
				INNER JOIN t_Case cc ON
		c.rf_idRecordCase=cc.rf_idRecordCase              

GO
DROP TABLE #tError