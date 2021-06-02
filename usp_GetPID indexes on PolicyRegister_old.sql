USE [PolicyRegister]
GO

/****** Object:  Index [IX_PEOPLE_SS]    Script Date: 02/05/2012 09:20:37 ******/
CREATE NONCLUSTERED INDEX [IX_PEOPLE_SS_FAM_OT_IM_Case] ON [dbo].[PEOPLE] 
(
	[SS] ASC,
	FAM ASC,
	IM ASC,
	OT ASC
) INCLUDE (DR) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PEOPLE_SS_FAM_DOCN_IM_DR_Case] ON [dbo].[PEOPLE] 
(
	[SS] ASC,
	FAM ASC,
	IM ASC,
	OT ASC,
	DR ASC,
	DOCN ASC
) INCLUDE (PID) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PEOPLE_FIODR_DOCN_Cases] ON [dbo].[PEOPLE] 
(
	[FAM] ASC,
	[IM] ASC,
	[OT] ASC,
	[DR] ASC	
) INCLUDE(DOCN) ON [PRIMARY]
GO
--drop index IX_PEOPLE_FIODR_DOCN ON [dbo].[PEOPLE] 
CREATE NONCLUSTERED INDEX [IX_PEOPLE_IM_OT_DR_DOCN_Case] ON [dbo].[PEOPLE] 
(
	DOCN ASC
) INCLUDE(IM,OT,DR,FAM) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_POLIS_PID_Cases] ON [dbo].[POLIS] 
(
	PID ASC,
	Q ASC,
	DBEG ASC,
	OKATO ASC,
	DEND ASC,
	DSTOP ASC
) INCLUDE(POLTP,SPOL,NPOL) ON [PRIMARY]
GO