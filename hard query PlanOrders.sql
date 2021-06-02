USE RegisterCases
GO
DECLARE @codeLPU CHAR(6)=101001,
		@monthMin TINYINT=7,
		@monthMax TINYINT=9,
		@year SMALLINT=2013

SET STATISTICS TIME ON		
DECLARE @t AS TABLE(id bigint)
INSERT @t
SELECT cb.id
FROM t_FileBack f INNER JOIN t_RegisterCaseBack r ON
   f.id=r.rf_idFilesBack  
   and f.CodeM=@codeLPU
      INNER JOIN t_RecordCaseBack cb ON
         cb.rf_idRegisterCaseBack=r.id AND
   r.ReportMonth>=@monthMin AND r.ReportMonth<=@monthMax AND
   r.ReportYear=@year
   AND cb.TypePay=1
   
  SELECT DISTINCT cb.id
  FROM @t cb inner loop join t_PatientBack p ON 
   cb.id=p.rf_idRecordCaseBack
      INNER JOIN vw_sprSMO s ON 
   p.rf_idSMO=s.smocod 
   
SET STATISTICS TIME OFF
---------------------------------------------
SET STATISTICS TIME ON	 		
SELECT distinct cb.id
FROM t_FileBack f INNER JOIN t_RegisterCaseBack r ON
   f.id=r.rf_idFilesBack  
   and f.CodeM=@codeLPU
      INNER JOIN t_RecordCaseBack cb ON
         cb.rf_idRegisterCaseBack=r.id AND
   r.ReportMonth>=@monthMin AND r.ReportMonth<=@monthMax AND
   r.ReportYear=@year
   AND cb.TypePay=1
   inner LOOP join t_PatientBack p ON 
   cb.id=p.rf_idRecordCaseBack
      INNER JOIN vw_sprSMO s ON 
   p.rf_idSMO=s.smocod 
 
 SET STATISTICS TIME OFF
---------------------------------------------
   
SET STATISTICS TIME ON	 		
SELECT distinct cb.id
FROM t_FileBack f INNER JOIN t_RegisterCaseBack r ON
   f.id=r.rf_idFilesBack  
   and f.CodeM=@codeLPU
      INNER JOIN t_RecordCaseBack cb ON
         cb.rf_idRegisterCaseBack=r.id AND
   r.ReportMonth>=@monthMin AND r.ReportMonth<=@monthMax AND
   r.ReportYear=@year
   AND cb.TypePay=1
   inner join t_PatientBack p ON 
   cb.id=p.rf_idRecordCaseBack
      INNER JOIN vw_sprSMO s ON 
   p.rf_idSMO=s.smocod 
 
 SET STATISTICS TIME OFF