USE oms_nsi
GO
--DROP  INDEX IX_OKATO2 ON dbo.sprOKATO
--ALTER TABLE dbo.sprOKATO DROP COLUMN [OKATO2]

ALTER TABLE dbo.sprOKATO ADD [OKATO2]  AS (case when [kod3]<>'000' OR [kod3]='000' AND ([razdel]=(1) OR [razdel] IS NULL) then (([ter]+[kod1])+[kod2])+[kod3] else '0' end)
GO
CREATE NONCLUSTERED INDEX IX_OKATO2
ON [dbo].[sprOKATO] ([OKATO2])