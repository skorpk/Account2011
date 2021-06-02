USE AccountOMS

DECLARE @d DATETIME='20130101'
TRUNCATE TABLE dbo.t_PaidCase
-----------------------------RPD----------------------------------------------------------------------------
INSERT dbo.t_PaidCase( rf_idCase ,DateRegistration ,AmountPaymentAccept ,CodeM ,Letter)
SELECT        sc.rf_idCase, f.DateRegistration, SUM(sc.AmountPayment) AS AmountPaymentAccept, f.CodeM, RIGHT(a.Account, 1) AS Letter
FROM            ExchangeFinancing.dbo.t_DFileIn f INNER JOIN
                         ExchangeFinancing.dbo.t_PaymentDocument p ON f.id = p.rf_idDFile INNER JOIN
                         ExchangeFinancing.dbo.t_SettledAccount a ON p.id = a.rf_idPaymentDocument INNER JOIN
                         ExchangeFinancing.dbo.t_SettledCase sc ON a.id = sc.rf_idSettledAccount
WHERE f.DateRegistration > @d
GROUP BY sc.rf_idCase, f.DateRegistration, f.CodeM, RIGHT(a.Account, 1)
union all
SELECT  pd.rf_idCase ,
        b.date_create AS DatePP,
        pd.S_SL ,
        pdAcc.CODE_MO AS CodeM, a.Letter        
FROM    expertAccounts.dbo.t_PDCase AS pd
	INNER JOIN expertAccounts.dbo.t_PDAccount pdAcc ON pd.rf_idPDAccount = pdAcc.id
	INNER JOIN expertAccounts.dbo.t_PDInfo b ON pdAcc.rf_idPDInfo = b.id
	INNER JOIN expertAccounts.dbo.t_RegistersAccounts a ON pdAcc.rf_idAccount = a.id	        
WHERE   ( a.Letter IS NOT NULL ) and b.date_create >@d
GO
------------------------------RAK----------------------------------------------------------------------------
DECLARE @d DATETIME='20130101'
TRUNCATE TABLE t_PaymentAcceptedCase
INSERT dbo.t_PaymentAcceptedCase( rf_idCase ,DateRegistration ,AmountPaymentAccept ,CodeM ,Letter ,AmountDeduction)
SELECT        rf_idCase, DateRegistration, AmountPaymentAccept, CodeM, Letter, AmountDeduction
FROM            (SELECT        TOP 1 WITH TIES sc.rf_idCase, f.DateRegistration, sc.AmountPaymentAccept, f.CodeM, RIGHT(a.Account, 1) AS Letter, ISNULL(sc.AmountEKMP, 0) 
                                                    + ISNULL(sc.AmountMEE, 0) + ISNULL(sc.AmountMEK, 0) AS AmountDeduction
                          FROM            ExchangeFinancing.dbo.t_AFileIn f INNER JOIN
                                                    ExchangeFinancing.dbo.t_DocumentOfCheckup p ON f.id = p.rf_idAFile INNER JOIN
                                                    ExchangeFinancing.dbo.t_CheckedAccount a ON p.id = a.rf_idDocumentOfCheckup INNER JOIN
                                                    ExchangeFinancing.dbo.t_CheckedCase sc ON a.id = sc.rf_idCheckedAccount
                          WHERE f.DateRegistration >@d
                          ORDER BY ROW_NUMBER() OVER (PARTITION BY f.DateRegistration, a.Account, a.ReportYear, sc.GUID_Case
                          ORDER BY p.DocumentDate DESC, p.DocumentNumber DESC)) t
UNION ALL
SELECT  ec.rf_idCase ,act.dakt,ec.RemovalSumm AS rem ,f.CodeM ,a.Letter,ec.SumCase AS AmountDeduction  
FROM    expertAccounts.dbo.t_ExpertCase ec
        INNER JOIN expertAccounts.dbo.t_ExpertAccount ea ON ea.id = ec.rf_idExpertAccount
        INNER JOIN expertAccounts.dbo.t_Case c ON ec.rf_idCase = c.id
        INNER JOIN expertAccounts.dbo.t_RegistersAccounts A ON ea.rf_idAccount = A.id
        INNER JOIN expertAccounts.dbo.t_File f ON A.rf_idFiles = f.id
        INNER JOIN expertAccounts.dbo.t_ExpertAct act ON ea.id = act.rf_idExpertAccount
        INNER JOIN expertAccounts.dbo.t_ExpertActCase actC ON ec.rf_idCase = actC.rf_idCase
              AND ec.rf_idExpertAccount = actC.rf_idExpertAccount
WHERE ea.rf_typeExpert = 1 AND ea.rf_typek = 1 AND  act.dakt>@d
UNION ALL
SELECT  ec.rf_idCase ,act.dakt,ec.RemovalSumm AS rem ,f.CodeM ,a.Letter,ec.SumCase AS AmountDeduction
FROM    expertAccounts.dbo.t_ExpertCase ec
        INNER JOIN expertAccounts.dbo.t_ExpertAccount ea ON ea.id = ec.rf_idExpertAccount
        INNER JOIN expertAccounts.dbo.t_Case c ON ec.rf_idCase = c.id
        INNER JOIN expertAccounts.dbo.t_RegistersAccounts A ON ea.rf_idAccount = A.id
        INNER JOIN expertAccounts.dbo.t_File f ON A.rf_idFiles = f.id
        INNER JOIN expertAccounts.dbo.t_ExpertAct act ON ea.id = act.rf_idExpertAccount
        INNER JOIN expertAccounts.dbo.t_ExpertActCase actC ON ec.rf_idCase = actC.rf_idCase
                                                              AND ec.rf_idExpertAccount = actC.rf_idExpertAccount
WHERE ea.rf_typeExpert in (2, 3) AND ea.rf_typek = 1 AND  act.dakt>@d AND ec.RemovalSumm > 0     
UNION ALL
SELECT  ec.rf_idCase ,act.dakt,ec.RemovalSumm AS rem ,f.CodeM ,a.Letter,ec.SumCase AS AmountDeduction  
FROM    expertAccounts.dbo.t_ExpertCase ec
        INNER JOIN expertAccounts.dbo.t_ExpertAccount ea ON ea.id = ec.rf_idExpertAccount
        INNER JOIN expertAccounts.dbo.t_Case c ON ec.rf_idCase = c.id
        INNER JOIN expertAccounts.dbo.t_RegistersAccounts A ON ea.rf_idAccount = A.id
        INNER JOIN expertAccounts.dbo.t_File f ON A.rf_idFiles = f.id
        INNER JOIN expertAccounts.dbo.t_ExpertAct act ON ea.id = act.rf_idExpertAccount
        INNER JOIN expertAccounts.dbo.t_ExpertActCase actC ON ec.rf_idCase = actC.rf_idCase
                                                              AND ec.rf_idExpertAccount = actC.rf_idExpertAccount
WHERE   ea.rf_typeExpert = 1 AND ea.rf_typek = 2 AND ec.RemovalSumm > 0   AND  act.dakt>@d
GO