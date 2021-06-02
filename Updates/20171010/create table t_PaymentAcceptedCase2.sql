USE AccountOMS
GO

DROP TABLE t_PaymentAcceptedCase2

CREATE TABLE dbo.t_PaymentAcceptedCase2
(
rf_idCase bigint NOT NULL,
DateRegistration datetime NOT NULL,
idAkt int  NOT NULL,
DocumentDate DATE NOT NULL,
DocumentNumber VARCHAR(25) NOT NULL,
CodeM char (6) COLLATE Cyrillic_General_CI_AS NOT NULL,
Letter char (1) COLLATE Cyrillic_General_CI_AS NOT NULL,
AmountMEK decimal (12, 2) NOT NULL,
AmountMEE decimal (12, 2) NOT NULL,
AmountEKMP decimal (12, 2) NOT NULL,
OrderCheckup tinyint NULL,
TypeCheckup tinyint NULL,
AmountDeduction AS (AmountMEK+AmountMEE +AmountEKMP) 
) 
GO
