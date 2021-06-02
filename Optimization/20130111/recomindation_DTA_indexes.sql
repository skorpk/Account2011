use [RegisterCases]
go

CREATE CLUSTERED INDEX IX_PatientBack_idRecordCaseBack ON [dbo].[t_PatientBack] 
(
	[rf_idRecordCaseBack] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON) ON [PRIMARY]
go

CREATE CLUSTERED INDEX IX_CaseBack_idRecordCaseBack ON [dbo].[t_CaseBack] 
(
	[rf_idRecordCaseBack] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON) ON [PRIMARY]
go

CREATE CLUSTERED INDEX IX_ErrorProcessControl_ErrorNumber ON [dbo].[t_ErrorProcessControl] 
(
	[ErrorNumber] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go
