USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT--=127080

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='125902' AND ReportYear=2021 AND NumberRegister=1

SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile									  


--select * from vw_getIdFileNumber where id=@idFile
declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

SELECT DISTINCT c.id,581,p.id,p.ID_Patient
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase			  
			  join t_Case c on
		r.id=c.rf_idRecordCase					  		
		AND c.DateEnd>='20210101'			
				JOIN dbo.t_RefRegisterPatientRecordCase rf ON
         r.id=rf.rf_idRecordCase
				JOIN dbo.t_RegisterPatient p ON
         rf.rf_idRegisterPatient=p.id
		 AND p.rf_idFiles=f.id							
where a.rf_idFiles=@idFile AND r.rf_idF008<>3 AND EXISTS(SELECT 1 
									  FROM t_RegisterPatientDocument d JOIN oms_nsi.dbo.sprDocumentType dt ON
												d.rf_idDocumentType=dt.ID
									  WHERE d.rf_idRegisterPatient=p.id AND ISNULL(dt.Seria,'S') NOT LIKE 'S%'
									  AND LEN(ISNULL(d.SeriaDocument,''))=0 
									  UNION ALL
                                      SELECT 1 
									  FROM t_RegisterPatientDocument d 
									  WHERE d.rf_idRegisterPatient=p.id AND LEN(ISNULL(d.NumberDocument,''))=0 
									  )
--SELECT * FROM dbo.t_RegisterPatientDocument WHERE rf_idRegisterPatient IN(134736196,134739773,134740223)

SELECT *
FROM oms_nsi.dbo.sprDocumentType ORDER BY id