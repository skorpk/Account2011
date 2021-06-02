USE [RegisterCases]
GO

/****** Object:  Index [IX_CaseMUCodeV004]    Script Date: 07.05.2018 8:31:33 ******/
CREATE CLUSTERED INDEX IX_MoveMeduslugi ON [dbo].[t_Meduslugi]
(
	[rf_idCase] ASC,
	GUID_MU
	
) ON [RegisterCasesInsurer]
GO


