USE AccountOMS
GO
CREATE TABLE t_NextVisitDate(rf_idCase BIGINT NOT null, DateVizit DATE NOT null)
go
ALTER TABLE [dbo].t_NextVisitDate  WITH CHECK ADD  CONSTRAINT [FK_NextVisitDate_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].t_NextVisitDate CHECK CONSTRAINT [FK_NextVisitDate_Cases] 
GO