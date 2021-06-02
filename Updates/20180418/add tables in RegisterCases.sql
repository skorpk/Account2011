USE RegisterCases
GO

CREATE TABLE dbo.t_DirectionDate(
	rf_idCase bigint NOT NULL,
	DirectionDate DATE NOT null	
) ON RegisterCases

GO 
ALTER TABLE dbo.t_DirectionDate  WITH CHECK ADD  CONSTRAINT FK_DirectionDate_Cases FOREIGN KEY(rf_idCase)
REFERENCES dbo.t_Case (id)
ON DELETE CASCADE
GO 
ALTER TABLE t_DirectionDate CHECK CONSTRAINT FK_DirectionDate_Cases
GO
------------------------------------------------------------
ALTER TABLE dbo.t_SlipOfPaper ADD NumberTicket VARCHAR(20) NULL
GO
------------------------------------------------------------
CREATE TABLE dbo.t_ProfileOfBed(
	rf_idCase bigint NOT NULL,
	rf_idV020 SMALLINT NOT null	
) ON RegisterCases

GO 
ALTER TABLE dbo.t_ProfileOfBed  WITH CHECK ADD  CONSTRAINT FK_ProfileOfBed_Cases FOREIGN KEY(rf_idCase)
REFERENCES dbo.t_Case (id)
ON DELETE CASCADE
GO 
ALTER TABLE t_ProfileOfBed CHECK CONSTRAINT FK_ProfileOfBed_Cases
GO
------------------------------------------------------------
--DROP TABLE t_PurposeOfVisit
CREATE TABLE dbo.t_PurposeOfVisit(
	rf_idCase bigint NOT NULL,
	rf_idV025 VARCHAR(3) NULL,
	DN TINYINT null
) ON RegisterCases

GO 
ALTER TABLE dbo.t_PurposeOfVisit  WITH CHECK ADD  CONSTRAINT FK_PurposeOfVisit_Cases FOREIGN KEY(rf_idCase)
REFERENCES dbo.t_Case (id)
ON DELETE CASCADE
GO 
ALTER TABLE t_PurposeOfVisit CHECK CONSTRAINT FK_PurposeOfVisit_Cases
GO
------------------------------------------------------------
CREATE TABLE dbo.t_CombinationOfSchema(
	rf_idCase bigint NOT NULL,
	rf_idV024 VARCHAR(10) NOT NULL
) ON RegisterCases

GO 
ALTER TABLE dbo.t_CombinationOfSchema  WITH CHECK ADD  CONSTRAINT FK_CombinationOfSchema_Cases FOREIGN KEY(rf_idCase)
REFERENCES dbo.t_Case (id)
ON DELETE CASCADE
GO 
ALTER TABLE t_CombinationOfSchema CHECK CONSTRAINT FK_CombinationOfSchema_Cases
GO
GRANT INSERT,SELECT ON dbo.t_DirectionDate TO db_RegisterCase;
GRANT INSERT,select ON dbo.t_CombinationOfSchema TO db_RegisterCase;
GRANT INSERT,select ON dbo.t_PurposeOfVisit TO db_RegisterCase;
GRANT INSERT,select ON dbo.t_ProfileOfBed TO db_RegisterCase;
