USE [AccountOMS]
GO
/****** Object:  StoredProcedure [dbo].[usp_selectCases]    Script Date: 11/12/2013 10:31:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_selectCases]
    @p_AccountCode INT = NULL ,
    @p_StartDate VARCHAR(10) = NULL ,
    @p_EndDate VARCHAR(20) = NULL ,
    @p_FilialCode INT = -1 ,
    @p_LPUCode INT = -1 ,
    @p_LPUManualEnteredCode INT = -1 ,--имеет боле высокий приоритет чем данные в переменной @p_LPUCode
    @p_ManualEnteredPacientName NVARCHAR(100) = '' ,
    @p_ManualEnteredPacSurname NVARCHAR(100) = '' ,
    @p_ManualEnteredPacName NVARCHAR(100) = '' ,
    @p_ManualEnteredPacPatronymic NVARCHAR(100) = '' ,
    @p_PatientBirthYear INT = NULL
AS 
    BEGIN
        IF ( @p_AccountCode IS NOT NULL ) 
            BEGIN
                CREATE TABLE #t_tmpAccs ( id INT, rf_idFiles INT )

                INSERT  INTO #t_tmpAccs
                        SELECT  ra.id ,
                                ra.rf_idFiles
                        FROM    dbo.t_RegistersAccounts ra
                        WHERE   ra.[rf_idFiles] = @p_AccountCode

                SELECT  c.id AS CaseId ,
                        c.idRecordCase AS Случай ,
                        v6.Name AS УсловияОказания ,
                        v8.Name AS ВидПомощи ,
                        dmo.NAM_MOK AS Направление ,
                        CASE WHEN c.HopitalisationType = 1 THEN 'Плановая'
                             ELSE 'Экстренная'
                        END AS ТипГоспитализации ,
                        v2.name AS Профиль ,
                        CASE WHEN c.IsChildTariff = 0 THEN 'Взрослый'
                             ELSE 'Детский'
                        END AS Тариф ,
                        c.NumberHistoryCase AS НомерКарты ,
                        c.DateBegin AS Начат ,
                        c.DateEnd AS Окончен ,
                        c.AmountPayment AS Выставлено ,
                        v9.Name AS Результат ,
                        v12.Name AS Исход ,
                        v4.Name AS СпециальностьМедРаботника ,
                        v10.Name AS СпособОплаты ,
                        rp.Fam + ' ' + rp.Im + ' ' + ISNULL(rp.Ot, '') AS Пациент ,
                        v5.Name AS Пол ,
                        rp.BirthDay AS ДатаРождения ,
                        c.age AS Возраст ,
                        rp.BirthPlace AS МестоРождения ,
                        rpa.Fam + ' ' + rpa.Im + ' ' + ISNULL(rpa.Ot, '') AS Представитель ,
                        dt.Name AS ТипДокумента ,
                        rpd.SeriaDocument AS Серия ,
                        RTRIM(rpd.NumberDocument) AS Номер ,
                        rpd.SNILS AS СНИЛС ,
                        rcp.SeriaPolis AS СерияПолиса ,
                        rcp.NumberPolis AS НомерПолиса ,
                        f.DateRegistration AS ДатаРегистрации ,
                        fil.FilialId AS CodeFilial ,
                        f.CodeM AS CodeMO ,
                        fil.filialName AS Филиал ,
                        mo2.NameS AS МО ,
                        d.DS1 AS КодДиагноза ,
                        mkb.Diagnosis AS Диагноз ,
                        rpd.OKATO AS АдресРегистрации ,
                        rpd.OKATO_place AS АдресМестаЖительства ,
                        rcp.[AttachLPU] AS МОПрикрепления
                FROM    dbo.t_Case AS c	INNER JOIN dbo.t_RecordCasePatient AS rcp ON 
									c.rf_idRecordCasePatient = rcp.id
						INNER JOIN dbo.#t_tmpAccs AS ra ON 
									rcp.rf_idRegistersAccounts = ra.id
						INNER JOIN dbo.t_File AS f ON 
									ra.rf_idFiles = f.id
                        INNER JOIN OMS_NSI.dbo.tMO AS mo1 ON 
									f.CodeM = LEFT(mo1.tfomsCode,6)
                        INNER JOIN OMS_NSI.dbo.tFilial AS fil ON 
									mo1.rf_FilialId = fil.FilialId
                        INNER JOIN dbo.t_RegisterPatient AS rp ON 
									rp.rf_idRecordCase = rcp.id
                        INNER JOIN OMS_NSI.dbo.sprV002 AS v2 ON 
									c.rf_idV002 = v2.Id
                        INNER JOIN OMS_NSI.dbo.sprV006 AS v6 ON 
									c.rf_idV006 = v6.Id
                        INNER JOIN OMS_NSI.dbo.sprV008 AS v8 ON 
									c.rf_idV008 = v8.Id
                        INNER JOIN OMS_NSI.dbo.sprV010 AS v10 ON 
									c.rf_idV010 = v10.Id
                        INNER JOIN OMS_NSI.dbo.sprV005 AS v5 ON 
									rp.rf_idV005 = v5.Id
                        INNER JOIN dbo.vw_Diagnosis AS d ON 
									c.id = d.rf_idCase
                        INNER JOIN OMS_NSI.dbo.sprMKB AS mkb ON mkb.DiagnosisCode = d.DS1
                        INNER JOIN dbo.vw_sprT001_Report AS mo2 ON mo2.CodeM = f.CodeM
                        LEFT JOIN OMS_NSI.dbo.sprMO AS dmo ON dmo.mcod = c.rf_idDirectMO
                        LEFT JOIN OMS_NSI.dbo.sprV009 AS v9 ON c.rf_idV009 = v9.Id
                        LEFT JOIN OMS_NSI.dbo.sprV012 AS v12 ON c.rf_idV012 = v12.Id
                        LEFT JOIN dbo.t_RegisterPatientAttendant AS rpa ON rpa.rf_idRegisterPatient = rp.id
                        LEFT JOIN dbo.t_RegisterPatientDocument AS rpd ON rpd.rf_idRegisterPatient = rp.id
                        LEFT JOIN OMS_NSI.dbo.sprDocumentType AS dt ON rpd.rf_idDocumentType = dt.ID
                        LEFT JOIN OMS_NSI.dbo.sprMedicalSpeciality AS v4 ON c.rf_idV004 = v4.Id
                ORDER BY c.idRecordCase

            END
  
  
        ELSE 
---------------------------------------------------------------------------------
IF ( @p_AccountCode IS NULL ) 
BEGIN
   create TABLE #lpu(CodeM CHAR(6),FilialId TINYINT,filialName VARCHAR(50))
                    
	SELECT @p_FilialCode =CASE WHEN @p_FilialCode = -1 THEN NULL ELSE (SELECT filialCode FROM dbo.vw_sprFilial WHERE FilialId=@p_FilialCode) end
		 ,@p_LPUCode =CASE WHEN @p_LPUCode=-1 AND @p_LPUManualEnteredCode=-1 THEN NULL 
							WHEN @p_LPUCode=-1 AND @p_LPUManualEnteredCode>-1 THEN @p_LPUManualEnteredCode 
							WHEN @p_LPUCode>-1 AND @p_LPUManualEnteredCode>-1 THEN @p_LPUManualEnteredCode
				ELSE @p_LPUCode END
		,@p_EndDate=@p_EndDate+' 23:59:59'		
		  
   
	INSERT #LPU
	SELECT CodeM, filialCode,filialName 
	FROM dbo.vw_sprT001 
	WHERE CodeM=ISNULL(@p_LPUCode,codeM) AND filialCode=ISNULL(@p_FilialCode,filialCode)
	ORDER BY CodeM
	
    
    CREATE TABLE #t_tmpCases
                        (
                          caseid BIGINT ,
                          patient NVARCHAR(255) ,
                          dateregistration DATETIME ,
                          codefilial TINYINT ,
                          filialname NVARCHAR(30) ,
                          codemo CHAR(6) ,
                          idrecordcase INT ,
                          hospitalisationtype VARCHAR(20) ,
                          ischildtarif VARCHAR(10) ,
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
					,f.DateRegistration AS ДатаРегистрации 
					,mo.FilialId AS CodeFilial 
					,mo.filialName AS Филиал 
					,f.CodeM AS CodeMO 
					,c.idRecordCase AS НомерСлучая 					
					,CAST(CASE WHEN c.HopitalisationType = 1 THEN 'Плановая' ELSE 'Экстренная' END AS varchar(20)) AS ТипГоспитализации 
					,CAST(CASE WHEN c.IsChildTariff = 0 THEN 'Взрослый' ELSE 'Детский' END AS VARCHAR(20)) AS Тариф 
					,c.NumberHistoryCase AS НомерКарты 
					,c.DateBegin AS Начат 
					,c.DateEnd AS Окончен 
					,c.AmountPayment AS Выставлено 
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
					,c.age AS Возраст 
				   ,rcp.SeriaPolis AS СерияПолиса 
				   ,rcp.NumberPolis AS НомерПолиса 
				   ,rcp.id
				   ,ra.Account AS НомерСчета 
				   ,ra.[DateRegister] AS ДатаСчета 
				   ,rcp.[AttachLPU] AS МОПрикрепления, f.id
		FROM   dbo.t_File f INNER JOIN #LPU AS mo ON 
					f.CodeM = mo.CodeM	
							INNER JOIN dbo.t_RegistersAccounts ra ON
					f.id=ra.rf_idFiles
					AND ra.PrefixNumberRegister<>'34'
							INNER JOIN dbo.t_RecordCasePatient AS rcp ON
					ra.id=rcp.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					rcp.id=c.rf_idRecordCasePatient	
					AND c.DateEnd<@p_EndDate																
		WHERE   f.DateRegistration >= @p_StartDate AND f.DateRegistration <= @p_EndDate-- AND ra.PrefixNumberRegister <> '34'
                                    
			UPDATE c
			set c.patient=rp.Fam + ' ' + rp.Im + ' ' + ISNULL(rp.Ot,'') ,c.birthday=rp.BirthDay
					,c.birthplace=rp.BirthPlace ,rf_idV005=rp.rf_idV005,rpid=rp.id 
			FROM #t_tmpCases c INNER JOIN dbo.t_RegisterPatient AS rp ON 
						rp.rf_idRecordCase = c.rf_idrecordcase
						AND rp.rf_idFiles=c.rf_idFiles
			WHERE rp.Fam LIKE CASE WHEN @p_ManualEnteredPacSurname = '' THEN '%' ELSE @p_ManualEnteredPacSurname END
				  AND rp.Im LIKE CASE WHEN @p_ManualEnteredPacName = '' THEN '%' ELSE @p_ManualEnteredPacName END
				  AND ( rp.Ot LIKE CASE WHEN @p_ManualEnteredPacPatronymic = '' THEN '%' ELSE @p_ManualEnteredPacPatronymic END OR rp.Ot IS NULL)  


				SELECT 
                            tmpC.caseid AS CaseId ,
                            tmpC.idrecordcase AS Случай ,
                            tmpC.amountpayment AS Выставлено ,
                            v6.Name AS УсловияОказания ,
                            v8.Name AS ВидПомощи ,
                            dmo.NAM_MOK AS Направление ,
                            tmpC.hospitalisationtype AS ТипГоспитализации ,
                            v2.name AS Профиль ,
                            tmpC.ischildtarif AS Тариф ,
                            tmpC.numberhistorycase AS НомерКарты ,
                            tmpC.datebegin AS Начат ,
                            tmpC.dateend AS Окончен ,
                            tmpC.amountpayment AS Выставлено ,
                            v9.Name AS Результат ,
                            v12.Name AS Исход ,
                            v4.Name AS СпециальностьМедРаботника ,
                            v10.Name AS СпособОплаты ,
                            tmpC.patient AS Пациент ,
                            v5.Name AS Пол ,
                            tmpC.birthday AS ДатаРождения ,
                            tmpC.age AS Возраст ,
                            tmpC.birthplace AS МестоРождения ,
                            rpa.Fam + ' ' + rpa.Im + ' ' + rpa.Ot AS Представитель ,
                            dt.Name AS ТипДокумента ,
                            rpd.SeriaDocument AS Серия ,
                            RTRIM(rpd.NumberDocument) AS Номер ,
                            rpd.SNILS AS СНИЛС ,
                            tmpC.seriapolis AS СерияПолиса ,
                            tmpC.numberpolis AS НомерПолиса ,
                            tmpC.dateregistration AS ДатаРегистрации ,
                            tmpC.filialname AS Филиал ,
                            tmpC.codemo AS CodeMO ,
                            tmpC.codefilial AS CodeFilial ,
                            mo.NameS AS МО ,
                            d.DS1 AS КодДиагноза ,
                            mkb.Diagnosis AS Диагноз ,
                            rpd.OKATO AS АдресРегистрации ,
                            rpd.OKATO_place  AS АдресМестаЖительства ,
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
               
                    DROP TABLE #t_tmpCases  
                    DROP TABLE #LPU      
                END
  
  
    END
