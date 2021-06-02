USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='611001' and NumberRegister=219 and ReportYear=2020

select * from vw_getIdFileNumber where id=@idFile
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6)
		
	
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile


----------------------------------------------------------------------------------------------
SELECT m.MU
INTO #tMU
FROM dbo.vw_sprMUAll m INNER JOIN (VALUES ('4.8.504'), ('4.11.538'),('4.11.539'),('4.12.501'),('4.12.502'),('4.12.521'),('4.12.531'),('4.12.532'),('4.12.533'),('4.12.552'),
											('4.12.553'),('4.12.561'),('4.12.566'),('4.12.591'),('4.12.592'),('4.12.614'),('4.12.616'),('4.12.617'),('4.12.618'),('4.12.621'),
											('4.12.637'),('4.12.669'),('4.12.670'),('4.12.672'),('4.12.675'),('4.12.676'),('4.12.677'),('4.12.678'),('4.12.679'),('4.12.680'),
											('4.12.681'),('4.12.682'),('4.12.683'),('4.12.684'),('4.12.685'),('4.12.686'),('4.12.687'),('4.12.688'),('4.12.689'),('4.12.690'),
											('4.12.691'),('4.12.692'),('4.12.661'),('4.13.501'),('4.13.502'),('4.13.503'),('4.13.504'),('4.13.505'),('4.13.506'),('4.15.501'),
											('4.15.502'),('4.15.503'),('4.15.504'),('4.15.505'),('4.15.506'),('4.15.507'),('4.15.508'),('4.15.509'),('4.15.510'),('4.15.511'),
											('4.15.512'),('4.15.513'),('4.15.514'),('4.15.515'),('4.15.516'),('4.15.517'),('4.15.518'),('4.15.519'),('4.15.520'),('4.15.521'),
											('4.15.522'),('4.15.523'),('4.15.524'),('4.15.525'),('4.15.526'),('4.15.527'),('4.15.528'),('4.15.529'),('4.15.530'),('4.15.531'),
											('4.15.532'),('4.15.533'),('4.15.534'),('4.15.535'),('4.15.536'),('4.15.537'),('4.15.538'),('4.15.539'),('4.15.540'),('4.15.541'),
											('4.15.542'),('4.15.543'),('4.15.544'),('4.15.545'),('4.16.501'),('4.16.502'),('4.16.503'),('4.16.504'),('4.16.505'),('4.16.506'),
											('4.16.507'),('4.16.508'),('4.16.509'),('4.16.510'),('4.16.511'),('4.16.512'),('4.16.513'),('4.16.514'),('4.16.515'),('4.16.516'),
											('4.16.517'),('4.16.518'),('4.16.519'),('4.16.520'),('4.16.521'),('4.16.522'),('4.16.523'),('4.16.524'),('4.16.525'),('4.16.526'),
											('4.16.527'),('4.16.528'),('4.16.529'),('4.16.530'),('4.16.531'),('4.16.532'),('4.16.533'),('4.16.534'),('4.16.535'),('4.16.536'),
											('4.16.537'),('4.16.538'),('4.16.539'),('4.16.540'),('4.17.501'),('4.17.502'),('4.17.503'),('4.17.504'),('4.17.505'),('4.17.506'),
											('4.17.507'),('4.17.508'),('4.17.509'),('4.17.510'),('4.17.511'),('4.17.512'),('4.17.513'),('4.17.514'),('4.17.515'),('4.17.516'),
											('4.17.517'),('4.17.518'),('4.17.519'),('4.17.520'),('4.17.521'),('4.17.522'),('4.17.523'),('4.17.524'),('4.17.525'),('4.17.526'),
											('4.17.527'),('4.17.528'),('4.17.529'),('4.17.530'),('4.17.531'),('4.17.532'),('4.17.533'),('4.17.534'),('4.17.535'),('4.17.536'),
											('4.17.537'),('4.17.538'),('4.17.539'),('4.17.540'),('4.17.541'),('4.17.542'),('4.17.543'),('4.17.544'),('4.17.545'),('4.17.546'),
											('4.17.547'),('4.17.548'),('4.17.549'),('4.17.550'),('4.17.551'),('4.17.552'),('4.17.553'),('4.17.554'),('4.17.555'),('4.17.556'),
											('4.17.557'),('4.17.558'),('4.17.559'),('4.17.560'),('4.17.561'),('4.17.562'),('4.17.563'),('4.17.564'),('4.17.565'),('4.17.566'),
											('4.17.567'),('4.17.568'),('4.17.569'),('4.17.570'),('4.17.571'),('4.17.572'),('4.17.573'),('4.17.574'),('4.17.575'),('4.17.576'),('4.11.540')) v(MU) ON
								m.MU=v.mu
UNION ALL
SELECT IDRB FROM oms_nsi.dbo.v001 WHERE isTelemedicine=1

INSERT #tMU SELECT MU FROM dbo.vw_sprMU WHERE MUGroupCode=60 AND MUUnGroupCode=8
----------------------------------------------------------------------------------------------
IF(SELECT TypeFile FROM dbo.t_File WHERE id=@idFile)='H'
begin

/*
Х	в поле COMENTU указано ќ“ ј«,
Х   когда ћедуслуга не из списка
Х	DATE_IN< DATE_1
Х	«начение в поле LPU на уровне случа€ не равно значению в теге LPU дл€ услуги. 

*/
	select distinct c.id,514,m.MUCode
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile 						
							inner join t_Case c on
				r.id=c.rf_idRecordCase				
							inner join t_Meduslugi m on
				c.id=m.rf_idCase
	WHERE m.rf_idDoctor IS NULL AND m.DateHelpBegin>=c.DateBegin AND c.rf_idMO=m.rf_idMO 
			AND NOT EXISTS(SELECT * FROM #tMU t WHERE t.MU=m.MUCode) AND c.rf_idMO NOT IN('125901' ,'805965')
--ѕри оказании амбулаторной помощи  в  ƒѕ2
IF (@CodeLPU<>'125901' AND  @CodeLPU<>'805965')
BEGIN 
	select distinct c.id,514
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile 						
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase									
	WHERE c.rf_idDoctor IS NULL AND NOT EXISTS(SELECT 1 FROM #tMU t WHERE t.MU=m.MUCode) 
end 
END

IF(SELECT TypeFile FROM dbo.t_File WHERE id=@idFile)='F'
BEGIN
/* 
Х	в поле P_OTK на уровне медуслуги указано значение, большее  0 (раньше было: большее 1),
Х	DATE_IN< DATE_1
Х	«начение в поле LPU на уровне случа€ не равно значению в теге LPU дл€ услуги.

*/
	select distinct c.id,514
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile 						
							inner join t_Case c on
				r.id=c.rf_idRecordCase				
							inner join t_Meduslugi m on
				c.id=m.rf_idCase
	WHERE m.rf_idDoctor IS NULL AND m.DateHelpBegin>=c.DateBegin AND c.rf_idMO=m.rf_idMO AND m.IsNeedUsl=0 
			AND NOT EXISTS(SELECT * FROM #tMU t WHERE t.MU=m.MUCode)
 END
 go
 DROP TABLE #tMU
