USE ExchangeFinancing
GO
SELECT distinct sc.rf_idCase, f.DateRegistration,p.id AS idAkt,p.DocumentDate,p.DocumentNumber,
	 f.CodeM, RIGHT(a.Account, 1) AS Letter,sc.AmountEKMP,sc.AmountMEE,sc.AmountMEK,p.OrderCheckup, p.TypeCheckup
FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN ExchangeFinancing.dbo.t_DocumentOfCheckup p ON 
							f.id = p.rf_idAFile 
										INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON 
							p.id = a.rf_idDocumentOfCheckup 
										INNER JOIN ExchangeFinancing.dbo.t_CheckedCase sc ON 
							a.id = sc.rf_idCheckedAccount
WHERE f.DateRegistration>='20160101'