USE [AccountOMS]
GO
/****** Object:  StoredProcedure [dbo].[usp_IsCODEExists]    Script Date: 11.03.2019 11:09:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_IsCODEExists]
				@code BIGINT,
				@codeM CHAR(6)
AS
SELECT COUNT(*) 
FROM t_File f INNER JOIN t_RegistersAccounts a ON
		f.id=a.rf_idFiles
WHERE CodeM=@codeM AND a.idRecord=@code
GO
CREATE PROCEDURE usp_IsCODEExists2
				@code int,
				@codeM char(6),
				@year smallint
as
select COUNT(*) 
FROM t_File f INNER JOIN t_RegistersAccounts a ON
		f.id=a.rf_idFiles
WHERE CodeM=@codeM AND a.idRecord=@code AND a.ReportYear=@year

GO
GRANT EXECUTE ON dbo.usp_IsCODEExists2 TO db_AccountOMS

SELECT MAX(idRecord),MIN(idRecord)
FROM t_File f INNER JOIN t_RegistersAccounts a ON
		f.id=a.rf_idFiles
WHERE CodeM='103001' AND a.ReportYear=2019