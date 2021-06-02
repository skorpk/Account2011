USE RegisterCases
GO
if OBJECT_ID('usp_Test455',N'P') is not NULL
	DROP PROCEDURE usp_Test455
GO
CREATE PROC dbo.usp_Test455
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
/*
�������� REGNUM ������ ��������������� �������������� N020 (��� ����������� �� DATE_Z_2 �������).

*/
INSERT #tError
SELECT DISTINCT c.id,455
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				
			  INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase 
			  INNER JOIN dbo.t_DrugTherapy d on
		c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN020 WHERE ID_LEKP=d.rf_idV020 AND DATEBEG<=cc.DateEnd AND DATEEND>=cc.DateEnd)
/*
REGNUM ������ ���� �������� ��� ONK_USL(�.� �� ����������� ��������� ���� � ��� �� �������� � ���������� ����� LEK_PR)
*/
GO
GRANT EXECUTE ON usp_Test455 TO db_RegisterCase