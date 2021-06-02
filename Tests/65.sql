USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='101001' AND ReportYear=2021 AND NumberRegister=27

SET STATISTICS TIME ON

SELECT ErrorNumber,COUNT(rf_idCase) AS CountCase FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber ORDER BY countCase desc
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

select mes.rf_idCase,65
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
					inner join t_MES mes on
			c.id=mes.rf_idCase
where mes.Tariff=0	

--на дату окончания лечения определяется уровень оплаты для данного медицинского учреждения  и  представленного в случае условия оказания 

select mes.rf_idCase,65,mes.*
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
					inner join t_MES mes on
			c.id=mes.rf_idCase
where mes.Tariff is null

--определяется возраст (на дату начала лечения) пациента: если возраст меньше 18, то применяются детские тарифы, если возраст пациента не меньше 18, то применяются взрослые тарифы
-----применяется для стционара с кодом 101003, 103001, 131001, 171004 после 01.08.2017 т.е для них берем значение из поля rf_idDepartmentMO

select mes.rf_idCase,65,c.rf_idMO,c.rf_idDepartmentMO,c.rf_idV006,'Error',cc.DateEnd
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase
						inner join t_MES mes on
				c.id=mes.rf_idCase
						left join dbo.vw_sprPriceLevelMO t1 on
				c.rf_idMO =t1.CodeM
				AND ISNULL(c.rf_idDepartmentMO,0)=ISNULL(t1.DeptCode,0)
				AND c.rf_idV006=t1.rf_idV006
				and cc.DateEnd>=t1.DateBegin
				and cc.DateEnd<=t1.DateEnd
where t1.CodeM is NULL 

SELECT * FROM vw_sprPriceLevelMO WHERE CodeM='101001' AND rf_idV006=1 AND DeptCode=102
-------------------------------------------------------для общих тариффов
--SELECT * FROM dbo.vw_sprPriceLevelMO WHERE CodeM='103001' AND DeptCode=111

-----применяется для стционара с кодом 101003, 103001, 131001, 171004 после 01.08.2017 т.е для них берем значение из поля rf_idDepartmentMO

SELECT DISTINCT t.id,65,t.*,'error1'
from (
		select c.id,mes.MES,cc.DateEnd,t1.LevelPayType, c.IsChild as IsChildTariff,mes.Tariff,c.GUID_Case,c.idRecordCase
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
								INNER JOIN dbo.t_CompletedCase cc ON
						r.id=cc.rf_idRecordCase
								inner join t_MES mes on
						c.id=mes.rf_idCase
								inner join (SELECT MU FROM dbo.vw_sprMUCompletedCase
											 UNION ALL SELECT code FROM vw_sprCSG
											 ) m on
						mes.MES=m.MU
								inner join dbo.vw_sprPriceLevelMO t1 on
						c.rf_idMO =t1.CodeM
						AND ISNULL(c.rf_idDepartmentMO,0)=ISNULL(t1.DeptCode,0)
						and c.rf_idV006=t1.rf_idV006
						and cc.DateEnd>=t1.DateBegin
						and cc.DateEnd<=t1.DateEnd
						and t1.LevelPayType<>'4'
		) t left join vw_sprTarrif mp on
				t.MES=mp.MU
				and t.LevelPayType=ISNULL(mp.LevelType,t.LevelPayType)
				and t.IsChildTariff=mp.IsChild
				and t.DateEnd>=mp.MUPriceDateBeg
				and t.DateEnd<=mp.MUPriceDateEnd
				and t.Tariff=mp.Price
where mp.MU is null
ORDER BY t.idRecordCase

--SELECT * FROM vw_sprTarrif WHERE MU='st07.001' AND LevelType='3.3' ORDER BY MUPriceDateBeg,MUPriceDateEnd
--SELECT GUID_Case FROM dbo.t_Case WHERE id=115494316
-------------------------------------------------------для индивидуальных тарифов

--TARIF
--02.08.2016
--Если в качестве услуги представлена хирургическая операция (класс А16 из Номенклатуры медицинских услуг) или Классификатора стоматологических услуг, 
--	то тариф должен быть равен 0

select distinct c.id,65
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase	
						inner join oms_NSI.dbo.V001	vm on
			m.MUCode=vm.IDRB						
where m.Price<>0


select distinct c.id,65
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase	
						inner join oms_NSI.dbo.sprDentalMU	vm on
			m.MUCode=vm.code
where m.Price<>0

--Проверка тарифов
--на дату окончания лечения определяется уровень оплаты для данного медицинского учреждения  и  представленного в случае условия оказания 

select mes.rf_idCase,65,c.rf_idMO, c.rf_idV006,cc.DateEnd,c.rf_idV006
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase
						inner join t_Meduslugi mes on
				c.id=mes.rf_idCase
						left join dbo.vw_sprPriceLevelMO t1 on
				c.rf_idMO=t1.CodeM
				AND c.rf_idV006=t1.rf_idV006
				and cc.DateEnd>=t1.DateBegin
				and cc.DateEnd<=t1.DateEnd
where t1.CodeM is NULL

--SELECT * FROM vw_sprPriceLevelMO WHERE CodeM='103001'
--В Справочнике медицинских услуг и тарифов для данного медицинского учреждения (если уровень оплаты - индивидуальный), 
--кода медицинской услуги, возраста пациента, уровня оплаты осуществляется поиск действующего на дату окончания лечения тарифа и 
--производится сравнение с представленным значением
-------------------------------------------------------для общих тариффов

--Изменения 17.10.2014

SELECT CodeM, DeptCode,rf_idV006,DateBegin,DateEnd,LevelPayType
INTO #tmpLevel
FROM vw_sprPriceLevelMO 
WHERE CodeM=@codeLPU 

SELECT mu,mp.LevelType,mp.IsChild,mp.MUPriceDateBeg,mp.MUPriceDateEnd,mp.Price
into #tMU
FROM vw_sprNotCompletedCaseMUTariff mp WHERE mp.MUPriceDateBeg>='20200101'


select t.id,'error',MUCode,t.LevelPayType,t.Price
from (
  select c.id,mes.MUCode,cc.DateEnd,t1.LevelPayType,c.IsChild AS IsChildTariff,mes.Price
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase
								INNER JOIN dbo.t_CompletedCase cc ON
						r.id=cc.rf_idRecordCase	
								inner join t_Meduslugi mes on
						c.id=mes.rf_idCase
								inner join vw_sprMU m on
						mes.MUCode=m.MU
								inner join #tmpLevel t1 on
						c.rf_idMO =t1.CodeM
						AND ISNULL(c.rf_idDepartmentMO,0)=ISNULL(t1.DeptCode,0)
						and c.rf_idV006=t1.rf_idV006
						and cc.DateEnd>=t1.DateBegin
						and cc.DateEnd<=t1.DateEnd
						and t1.LevelPayType<>'4'
	WHERE c.IsCompletedCase=0 --AND mes.Price>0
  ) t     
where NOT EXISTS(SELECT 1 FROM #tMU mp WHERE t.MUCode=mp.MU and t.LevelPayType=mp.LevelType and t.IsChildTariff=mp.IsChild and t.DateEnd>=mp.MUPriceDateBeg
					and t.DateEnd<=mp.MUPriceDateEnd and t.Price=mp.Price
				 UNION ALL 
				 SELECT 1 FROM oms_nsi.dbo.PriceMU mp1 WHERE t.MUCode=mp1.CODE_PRICE and t.LevelPayType=ISNULL(mp1.LEVEL_PAY,T.LevelPayType) 
						and t.IsChildTariff=mp1.AGE and t.DateEnd>=mp1.DATE_B and t.DateEnd<=mp1.DATE_E and t.Price=mp1.Price) 
PRINT('Last')
--SELECT  * FROM vw_sprNotCompletedCaseMUTariff mp WHERE mp.MU ='60.8.1'
--SELECT * FROM oms_nsi.dbo.PriceMU mp1 WHERE mp1.CODE_PRICE ='60.8.42'

go
DROP TABLE #tmpLevel
GO
DROP TABLE #tMU
-------------------------------------------------------для индивидуальных тарифов

SET STATISTICS TIME OFF