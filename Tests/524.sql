USE RegisterCases
GO
DECLARE @idFile INT


select @idFile=id FROM dbo.vw_getIdFileNumber WHERE ReportYear=2019 AND CodeM='151005' AND NumberRegister=48--DateRegistration>'20160425' AND CountSluch>1000
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6)
		
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod=rc.rf_idMO
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))

select DISTINCT c.id,524
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd<'20190101'
			  INNER JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase						  		
where a.rf_idFiles=@idFile AND d.DiagnosisGroup='O04' AND d.TypeDiagnosis=1 AND c.rf_idV002 IN (136,137) AND ISNULL(c.Comments,'9') NOT IN('3','4')


select DISTINCT c.id,524
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd>='20190101'
			  INNER JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase						  		
where a.rf_idFiles=@idFile AND d.DiagnosisGroup='O04' AND d.TypeDiagnosis=1 AND c.rf_idV002 IN (136,137) AND c.Comments IS NULL


select DISTINCT c.id,524,c.Comments
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd>='20190101'
			  INNER JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase						  		
where a.rf_idFiles=@idFile AND d.DiagnosisGroup='O04' AND c.rf_idV006=3 AND d.TypeDiagnosis=1 AND c.rf_idV002 IN (136,137) AND c.Comments IS NOT NULL AND DATALENGTH(c.Comments)!=3


select DISTINCT c.id,524
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd>='20190101'
			  INNER JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase						  		
where a.rf_idFiles=@idFile AND d.DiagnosisGroup='O04' AND d.TypeDiagnosis=1 AND c.rf_idV002 IN (136,137) AND c.Comments IS NOT NULL AND c.rf_idV006=3 AND c.rf_idV008 IN(1,11,12,13) 
	AND DATALENGTH(c.Comments)=3 AND c.Comments NOT IN('3:;','4:;')


select DISTINCT c.id,524, c.rf_idV006,c.Comments
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd>='20190101'
			  INNER JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase						  		
where a.rf_idFiles=@idFile AND d.DiagnosisGroup='O04' AND d.TypeDiagnosis=1 AND c.rf_idV002 IN (136,137) AND c.Comments IS NOT NULL AND 
		(c.rf_idV006<>3 or c.rf_idV008 IN(1,11,12,13))	AND c.Comments NOT IN('3','4')

go
