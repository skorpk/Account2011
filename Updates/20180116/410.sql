USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test410]    Script Date: 25.01.2018 9:47:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test410]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
/*
если RSLT=317, то PR_D_N=0 и во всех составных тегах DS2 (если они имеются) PR_D=0.
*/
insert #tError
select DISTINCT c.id,410
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
where a.rf_idFiles=@idFile AND c.rf_idV009=317 AND ISNULL(c.IsNeedDisp,9)>0

insert #tError
select DISTINCT c.id,410
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
				INNER JOIN dbo.t_DS2_Info d2 ON
		c.id=d2.rf_idCase              
where a.rf_idFiles=@idFile AND c.rf_idV009=317 AND ISNULL(d2.IsNeedDisp,9)>0


 /*
 2.	если (RSLT=355 or RSLT=356), то хотя бы в одном из тегов PR_D_N или PR_D (в составных тегах DS2) значение должно быть отлично от 0
 */
/* отключил по приказу начальства
;WITH cteD
AS
(
SELECT c.id,ISNULL(c.IsNeedDisp,0)+ISNULL(d2.IsNeedDisp,0) AS IsNeedDisp
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
			LEFT JOIN dbo.t_DS2_Info d2 ON
		c.id=d2.rf_idCase          
where a.rf_idFiles=@idFile AND c.rf_idV009 IN(355,356)
)
insert #tError
select DISTINCT id,410 FROM cteD WHERE IsNeedDisp=0
*/
GO
GRANT EXECUTE ON usp_Test410 TO db_RegisterCase