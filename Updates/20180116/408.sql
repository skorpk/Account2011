USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test404]    Script Date: 17.01.2018 9:17:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROC [dbo].[usp_Test408]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
select DISTINCT c.id,408
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMOMP_OMP v WHERE c.rf_idMO=v.CodeM AND ISNULL(c.rf_idSubMO,'bla-bla')=ISNULL(v.LPU1,'bla-bla'))

insert #tError
select DISTINCT c.id,408
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
			INNER JOIN dbo.t_Meduslugi m ON 
		c.id=m.rf_idCase
where a.rf_idFiles=@idFile AND c.rf_idSubMO<>m.rf_idSubMO

go