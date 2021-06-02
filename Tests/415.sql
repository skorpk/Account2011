USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='805958' AND ReportYear=2019 AND NumberRegister=2408


declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6),
		@typeFile char(1)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO, @typeFile=UPPER(f.TypeFile)
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile

SELECT DISTINCT c.id,415
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180501'		
where a.rf_idFiles=@idFile AND c.rf_idV006<3 AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.t_ProfileOfBed WHERE rf_idCase=c.id)

--проверка на соответствие профиля медицинской помощи и прокиля койки
SELECT DISTINCT c.id,415,p.rf_idV020,c.rf_idV002
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180501'		
				INNER JOIN dbo.t_ProfileOfBed p ON
		c.id=p.rf_idCase
where a.rf_idFiles=@idFile AND c.rf_idV006<3 AND f.TypeFile='H' 
		AND NOT EXISTS(SELECT 1 FROM dbo.vw_Profil_ProfileK WHERE Profil=c.rf_idV002 AND Profil_K=p.rf_idV020 AND c.DateEnd>=dateBeg AND c.DateEnd<=dateEnd)

SELECT * FROM dbo.vw_Profil_ProfileK  WHERE Profil=53
SELECT * FROM dbo.vw_Profil_ProfileK  WHERE Profil_K=53

--SELECT * FROM vw_sprv002 WHERE id IN(5,81)

SELECT * FROM oms_nsi.dbo.sprV020 WHERE code IN(34,35,36)

--SELECT * FROM oms_nsi.dbo.sprV020 WHERE code IN(34,35,36)

