select sc.rf_idCase, f.DateRegistration,SUM(sc.AmountPayment) AS AmountPaymentAccept,f.CodeM,RIGHT(a.Account,1) AS Letter
FROM ExchangeFinancing.dbo.t_DFileIn f INNER JOIN ExchangeFinancing.dbo.t_PaymentDocument p ON
														f.id=p.rf_idDFile
																	INNER JOIN ExchangeFinancing.dbo.t_SettledAccount a ON
														p.id=a.rf_idPaymentDocument
																	INNER JOIN ExchangeFinancing.dbo.t_SettledCase sc ON
														a.id=sc.rf_idSettledAccount
WHERE a.ReportYear>2012
GROUP BY sc.rf_idCase, f.DateRegistration,f.CodeM,RIGHT(a.Account,1)
UNION ALL
SELECT ec.rf_idCase,b.DatePP ,pd.S_SL,f.CodeM,a.Letter	 
FROM expertAccounts.dbo.t_ExpertCase ec INNER JOIN expertAccounts.dbo.t_ExpertAccount ea ON 
					ea.id = ec.rf_idExpertAccount
										INNER JOIN expertAccounts.dbo.t_Case c ON 
					ec.rf_idCase = c.id        
										INNER JOIN expertAccounts.dbo.t_RegistersAccounts A ON 
					ea.rf_idAccount = A.id		
										INNER JOIN expertAccounts.dbo.t_File f ON
					a.rf_idFiles=f.id			    
										INNER JOIN expertAccounts.dbo.t_ExpertAct act ON
					ea.id = act.rf_idExpertAccount									
										INNER JOIN expertAccounts.dbo.t_ExpertPays ep ON 
					act.rf_idExpertAccount = ep.rf_idExpertAccount
										INNER JOIN expertAccounts.dbo.t_BuhPay b ON 
					ep.rf_idBuhPay = b.id
										INNER JOIN expertAccounts.dbo.t_PDCase pd ON 
					c.id = pd.rf_idCase
WHERE a.Letter IS NOT null