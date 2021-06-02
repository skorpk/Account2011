USE RegisterCases
GO
DECLARE @idFile INT
SELECT @idFile=id FROM dbo.vw_getIdFileNumber WHERE CodeM='145516' AND NumberRegister=539 AND ReportYear=2014
SELECT DISTINCT f.id
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			inner join t_Case c on																																					
		r.id=c.rf_idRecordCase												
			inner join t_MES mes on
		c.id=mes.rf_idCase											
where /*a.rf_idFiles=@idFile AND*/ mes.MES LIKE '2.78.%' AND f.DateRegistration>'20140125' AND f.DateRegistration<GETDATE() AND a.ReportYear=2014