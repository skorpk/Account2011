USE AccountOMS
GO
DECLARE @p_AccountCode INT = NULL ,
    @p_StartDate NVARCHAR(20) = N'20130105',
    @p_EndDate NVARCHAR(20) = N'20131111' ,
    @p_FilialCode INT = null ,
    @p_LPUCode int = 101003 ,
    @p_LPUManualEnteredCode int = null,
    @p_ManualEnteredPacientName NVARCHAR(100) = '' ,
    @p_ManualEnteredPacSurname NVARCHAR(100) = '' ,
    @p_ManualEnteredPacName NVARCHAR(100) = '' ,
    @p_ManualEnteredPacPatronymic NVARCHAR(100) = '' ,
    @p_PatientBirthYear INT = NULL
   
   create TABLE #lpu(CodeM CHAR(6),FilialId TINYINT,filialName VARCHAR(50))

	SELECT @p_FilialCode =CASE WHEN @p_FilialCode = -1 THEN NULL ELSE @p_FilialCode end
		 ,@p_LPUCode =CASE WHEN @p_LPUCode=-1 AND @p_LPUManualEnteredCode=-1 THEN NULL 
							WHEN @p_LPUCode=-1 AND @p_LPUManualEnteredCode>-1 THEN @p_LPUManualEnteredCode 
							WHEN @p_LPUCode>-1 AND @p_LPUManualEnteredCode>-1 THEN @p_LPUManualEnteredCode
				ELSE @p_LPUCode END
		,@p_EndDate=@p_EndDate+' 23:59:59'		
		
  
	INSERT #LPU
	SELECT CodeM, filialCode,filialName 
	FROM dbo.vw_sprT001 
	WHERE CodeM=ISNULL(@p_LPUCode,codeM) AND filialCode=ISNULL(@p_FilialCode,filialCode)
    
    CREATE TABLE #t_tmpCases
                        (
                          caseid BIGINT ,
                          patient NVARCHAR(255) ,
                          dateregistration DATETIME ,
                          codefilial BIGINT ,
                          filialname NVARCHAR(30) ,
                          codemo CHAR(6) ,
                          idrecordcase INT ,
                          hospitalisationtype NVARCHAR(20) ,
                          ischildtarif NVARCHAR(10) ,
                          numberhistorycase NVARCHAR(50) ,
                          datebegin DATE ,
                          dateend DATE ,
                          amountpayment DECIMAL(15, 2) ,
                          rf_idrecordcasepatient INT ,
                          rf_idv009 SMALLINT ,
                          rf_idv012 SMALLINT ,
                          rf_idv002 SMALLINT ,
                          rf_idv006 TINYINT ,
                          rf_idv008 SMALLINT ,
                          rf_idv010 TINYINT ,
                          rf_iddirectmo CHAR(6) ,
                          rf_idv004 INT ,
                          rcpid INT ,
                          birthday DATE ,
                          age INT ,
                          birthplace NVARCHAR(100) ,
                          seriapolis VARCHAR(10) ,
                          numberpolis VARCHAR(20) ,
                          rf_idrecordcase INT ,
                          rf_idV005 TINYINT ,
                          rpid INT ,
                          accountnumber VARCHAR(15) ,
                          accountdate DATE ,
                          attachMO CHAR(6),
                          rf_idFiles int
                        )      
    INSERT #t_tmpCases
            ( caseid ,dateregistration ,codefilial ,filialname ,codemo ,idrecordcase ,hospitalisationtype ,ischildtarif ,
              numberhistorycase ,datebegin ,dateend ,amountpayment ,rf_idrecordcasepatient ,rf_idv009 ,rf_idv012 ,rf_idv002 ,
              rf_idv006 ,rf_idv008 ,rf_idv010 ,rf_iddirectmo ,rf_idv004 ,rcpid ,age ,seriapolis ,numberpolis ,rf_idrecordcase ,
              accountnumber ,accountdate ,attachMO,rf_idFiles)   
    SELECT  c.id 
			,f.DateRegistration AS ��������������� 
			,mo.FilialId AS CodeFilial 
			,mo.filialName AS ������ 
			,f.CodeM AS CodeMO 
			,c.idRecordCase AS ����������� 
			,CASE WHEN c.HopitalisationType = 1 THEN '��������' ELSE '����������' END AS ����������������� 
			,CASE WHEN c.IsChildTariff = 0 THEN '��������' ELSE '�������' END AS ����� 
			,c.NumberHistoryCase AS ���������� 
			,c.DateBegin AS ����� 
			,c.DateEnd AS ������� 
			,c.AmountPayment AS ���������� 
			,c.rf_idRecordCasePatient 
			,c.rf_idV009 
			,c.rf_idV012 
			,c.rf_idV002 
			,c.rf_idV006 
			,c.rf_idV008 
			,c.rf_idV010 
			,c.rf_idDirectMO 
			,c.rf_idV004 
			,rcp.id 
			,c.age AS ������� 
           ,rcp.SeriaPolis AS ����������� 
           ,rcp.NumberPolis AS ����������� 
           ,rcp.id
           ,ra.Account AS ���������� 
           ,ra.[DateRegister] AS ��������� 
           ,rcp.[AttachLPU] AS ��������������, f.id
FROM   dbo.t_File f INNER JOIN #LPU AS mo ON 
					f.CodeM = mo.CodeM	
							INNER JOIN dbo.t_RegistersAccounts ra ON
					f.id=ra.rf_idFiles
					AND ra.PrefixNumberRegister<>'34'
							INNER JOIN dbo.t_RecordCasePatient AS rcp ON
					ra.id=rcp.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					rcp.id=c.rf_idRecordCasePatient						
WHERE   f.DateRegistration >= @p_StartDate AND f.DateRegistration <= @p_EndDate --AND ra.PrefixNumberRegister <> 34
        
                                    
UPDATE c
set c.patient=rp.Fam + ' ' + rp.Im + ' ' + ISNULL(rp.Ot,'') ,c.birthday=rp.BirthDay
		,c.birthplace=rp.BirthPlace ,rf_idV005=rp.rf_idV005,rpid=rp.id 
FROM #t_tmpCases c INNER JOIN dbo.t_RegisterPatient AS rp ON 
			rp.rf_idRecordCase = c.rf_idrecordcase
			AND rp.rf_idFiles=c.rf_idFiles
WHERE rp.Fam LIKE CASE WHEN @p_ManualEnteredPacSurname = '' THEN '%' ELSE @p_ManualEnteredPacSurname END
      AND rp.Im LIKE CASE WHEN @p_ManualEnteredPacName = '' THEN '%' ELSE @p_ManualEnteredPacName END
      AND ( rp.Ot LIKE CASE WHEN @p_ManualEnteredPacPatronymic = '' THEN '%' ELSE @p_ManualEnteredPacPatronymic END OR rp.Ot IS NULL)  


 SELECT --count(*)
                            tmpC.caseid AS CaseId ,
                            tmpC.idrecordcase AS ������ ,
                            tmpC.amountpayment AS ���������� ,
                            v6.Name AS ��������������� ,
                            v8.Name AS ��������� ,
                            dmo.NAM_MOK AS ����������� ,
                            tmpC.hospitalisationtype AS ����������������� ,
                            v2.name AS ������� ,
                            tmpC.ischildtarif AS ����� ,
                            tmpC.numberhistorycase AS ���������� ,
                            tmpC.datebegin AS ����� ,
                            tmpC.dateend AS ������� ,
                            tmpC.amountpayment AS ���������� ,
                            v9.Name AS ��������� ,
                            v12.Name AS ����� ,
                            v4.Name AS ������������������������� ,
                            v10.Name AS ������������ ,
                            tmpC.patient AS ������� ,
                            v5.Name AS ��� ,
                            tmpC.birthday AS ������������ ,
                            tmpC.age AS ������� ,
                            tmpC.birthplace AS ������������� ,
                            rpa.Fam + ' ' + rpa.Im + ' ' + rpa.Ot AS ������������� ,
                            dt.Name AS ������������ ,
                            rpd.SeriaDocument AS ����� ,
                            RTRIM(rpd.NumberDocument) AS ����� ,
                            rpd.SNILS AS ����� ,
                            tmpC.seriapolis AS ����������� ,
                            tmpC.numberpolis AS ����������� ,
                            tmpC.dateregistration AS ��������������� ,
                            tmpC.filialname AS ������ ,
                            tmpC.codemo AS CodeMO ,
                            tmpC.codefilial AS CodeFilial ,
                            mo.NameS AS �� ,
                            d.DS1 AS ����������� ,
                            mkb.Diagnosis AS ������� ,
                            rpd.OKATO AS ���������������� ,
                            rpd.OKATO_place  AS �������������������� ,
                            tmpC.accountnumber ,
                            tmpC.accountdate ,
                            tmpC.attachMO
                    FROM    #t_tmpCases tmpC
                            INNER JOIN OMS_NSI.dbo.sprV002 AS v2 ON tmpC.rf_idV002 = v2.Id
                            INNER JOIN OMS_NSI.dbo.sprV006 AS v6 ON tmpC.rf_idV006 = v6.Id
                            INNER JOIN OMS_NSI.dbo.sprV008 AS v8 ON tmpC.rf_idV008 = v8.Id
                            INNER JOIN OMS_NSI.dbo.sprV010 AS v10 ON tmpC.rf_idV010 = v10.Id
                            INNER JOIN OMS_NSI.dbo.sprV005 AS v5 ON tmpC.rf_idV005 = v5.Id
                            INNER JOIN dbo.vw_Diagnosis AS d ON tmpC.caseid = d.rf_idCase
                            INNER JOIN OMS_NSI.dbo.sprMKB AS mkb ON mkb.DiagnosisCode = d.DS1
                            INNER JOIN dbo.vw_sprT001_Report AS mo ON mo.CodeM = tmpC.codemo
                            LEFT JOIN OMS_NSI.dbo.sprMO AS dmo ON dmo.mcod = tmpC.rf_idDirectMO
                            LEFT JOIN OMS_NSI.dbo.sprV009 AS v9 ON tmpC.rf_idV009 = v9.Id
                            LEFT JOIN OMS_NSI.dbo.sprV012 AS v12 ON tmpC.rf_idV012 = v12.Id
                            LEFT JOIN dbo.t_RegisterPatientAttendant AS rpa ON rpa.rf_idRegisterPatient = tmpC.rpid
                            LEFT JOIN dbo.t_RegisterPatientDocument AS rpd ON rpd.rf_idRegisterPatient = tmpC.rpid
                            LEFT JOIN OMS_NSI.dbo.sprDocumentType AS dt ON rpd.rf_idDocumentType = dt.ID
                            LEFT JOIN OMS_NSI.dbo.sprMedicalSpeciality AS v4 ON tmpC.rf_idV004 = v4.Id

GO 
DROP TABLE #t_tmpCases  
DROP TABLE #LPU                              