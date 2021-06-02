USE RegisterCases
GO
ALTER TABLE dbo.t_RecordCaseBack DROP COLUMN TypePay

ALTER TABLE dbo.t_RecordCaseBack ADD [TypePay] AS ([dbo].[GetTypePay]([id]))