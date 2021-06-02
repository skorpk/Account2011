USE RegisterCases
GO
DROP INDEX [IX_CaseID] ON [dbo].[t_ErrorProcessControl]
GO
DROP INDEX [IX_ErrorNumber_RefCase] ON [dbo].[t_ErrorProcessControl]
GO
ALTER TABLE dbo.t_ErrorProcessControl ALTER COLUMN ErrorNumber VARCHAR(12) NOT NULL
GO
CREATE NONCLUSTERED INDEX [IX_ErrorNumber_RefCase] ON [dbo].[t_ErrorProcessControl]
(
	[rf_idFile] ASC,
	[ErrorNumber] ASC
)
INCLUDE ( 	[rf_idCase]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_CaseID] ON [dbo].[t_ErrorProcessControl]
(
	[rf_idCase] ASC
)
INCLUDE ( 	[ErrorNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
