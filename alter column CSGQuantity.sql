USE RegisterCases
go

ALTER TABLE dbo.t_Meduslugi DROP COLUMN CSGQuantity

ALTER TABLE dbo.t_Meduslugi ADD CSGQuantity AS (case when [MUCode] like '1.11.%' AND [DateHelpBegin]=[DateHelpEnd] then (1) when [MUCode] like '1.11.%' AND [DateHelpBegin]<>[DateHelpEnd] then datediff(day,[DateHelpBegin],[DateHelpEnd])  end) 