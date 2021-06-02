USE RegisterCases
go
ALTER TABLE dbo.t_Meduslugi DROP column [PacientQuantity]
ALTER TABLE dbo.t_Meduslugi ADD [PacientQuantity]  AS (case when [MUCode] like '55.1.%' AND [DateHelpBegin]=[DateHelpEnd] then 1 when [MUCode] like '55.1.%' AND [DateHelpBegin]<>[DateHelpEnd] then datediff(day,[DateHelpBegin],[DateHelpEnd])+1  end)
	