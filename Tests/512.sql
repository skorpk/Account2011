USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='103001' AND ReportYear=2021 AND NumberRegister=106


SELECT distinct ErrorNumber FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile --GROUP BY ErrorNumber ORDER BY countCase desc
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

select c.id,512,m.MUSurgery
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase						
WHERE m.MUSurgery IS NOT NULL AND NOT EXISTS(SELECT * FROM vw_sprV001_DentalMU v WHERE IDRB=m.MUSurgery AND m.DateHelpEnd BETWEEN v.DATEBEG AND v.DATEEND /*COLLATE Latin1_General_BIN*/)

SELECT * FROM dbo.vw_sprV001_DentalMU WHERE  IDRB='A08.20.017'
--Если значение не совпадает со значением в теге CODE_USL или не соответствует номенклатуре медицинских услуг (V001)
 
select c.id,512
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013
			AND a.ReportYear<2019
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
						INNER JOIN vw_sprV001_DentalMU v ON
			m.MUSurgery=v.IDRB
WHERE m.MUSurgery IS NOT NULL AND m.MUSurgery<>m.MUCode	

 
select c.id,512
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
WHERE m.MUSurgery IS NOT NULL AND NOT EXISTS(SELECT 1 FROM vw_sprV001_DentalMU v WHERE v.IDRB=m.MUSurgery)
--не ввели в действие т.к. вылетает весь диализ
--отменил 16.04.2020 по  причине того что коды из V001 могут оказываться в разных условиях МП
--и многих таким услугам соответствует наш код МУ с тарифом
--15.07.2020 брались не все случаи. не подвергались проверке случаи у которых VID_VME был пустой

select DISTINCT c.id,512
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2018
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase			
						INNER JOIN dbo.vw_sprMU mm1 ON
			m.MUCode=mm1.MU
			AND c.rf_idV006=mm1.rf_idV006				                
WHERE m.MUSurgery IS NOT NULL AND m.MUCode<>m.MUSurgery AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMU mm WHERE m.MUSurgery=mm.NomenclMUCode AND m.MUCode=mm.MU AND c.rf_idV006=mm.rf_idV006) 
--2020-04-14 Для услуг из V001 c установленным соответствием услугам из территориального справочника медуслуг в теге VID_VME 
--указывается код услуги из Номенклатуры, а в поле CODE_USL указывается соответствующий код из территориального справочника медуслуг.


select DISTINCT c.id,512
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2018
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase				
						INNER JOIN dbo.vw_sprMU mm ON
			m.MUSurgery=mm.NomenclMUCode		                
			AND c.rf_idV006=mm.rf_idV006
WHERE m.MUSurgery IS NOT NULL AND m.MUCode=m.MUSurgery AND EXISTS(SELECT 1 FROM dbo.vw_sprMU mm1 WHERE m.MUSurgery=mm1.NomenclMUCode  AND m.MUCode<>mm1.MU AND c.rf_idV006=mm1.rf_idV006) 
/*
Если поле не заполнено, то:
по паре значений: значение в поле CODE_USL и значение в поле USL_OK, определяем наличие записи в таблице с установленным соответствием (из предыдущего абзаца). 
Если запись присутствует, то значение в поле VID_VME  должно соответствовать значению, установленному в указанной таблице
*/

select DISTINCT c.id,512
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2018
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase				
						INNER JOIN dbo.vw_sprMU mm ON
			m.MUCode=mm.MU
			AND c.rf_idV006=mm.rf_idV006
WHERE m.MUSurgery IS NULL AND mm.NomenclMUCode IS NOT null
----SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=125673098
----SELECT * FROM dbo.t_MES WHERE rf_idCase=125671419
--SELECT * FROM vw_sprMU WHERE NomenclMUCode='A04.12.005.006'
--SELECT * FROM vw_sprMU WHERE MU='4.20.702'
----SELECT * FROM oms_nsi.dbo.V001 WHERE IDRB='A26.08.019.001'

