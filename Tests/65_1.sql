USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='254570' and NumberRegister=190102 and ReportYear=2019


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

select mes.rf_idCase,65
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


select mes.rf_idCase,65
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
where t1.CodeM is null
-------------------------------------------------------для общих тариффов
-----применяется для стционара с кодом 101003, 103001, 131001, 171004 после 01.08.2017 т.е для них берем значение из поля rf_idDepartmentMO

select t.id,65,*
from (
		select c.id,mes.MES,cc.DateEnd,t1.LevelPayType, c.IsChild as IsChildTariff,mes.Tariff , c.rf_idV006
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
SELECT * FROM vw_sprPriceLevelMO WHERE CodeM='101004'
SELECT * FROM vw_sprTarrif WHERE MU='st18.002'
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

select mes.rf_idCase,65,c.rf_idV006
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
where t1.CodeM is null

SELECT * FROM vw_sprPriceLevelMO WHERE CodeM='254570'
--В Справочнике медицинских услуг и тарифов для данного медицинского учреждения (если уровень оплаты - индивидуальный), 
--кода медицинской услуги, возраста пациента, уровня оплаты осуществляется поиск действующего на дату окончания лечения тарифа и 
--производится сравнение с представленным значением
-------------------------------------------------------для общих тариффов

--Изменения 17.10.2014

SELECT CodeM, DeptCode,rf_idV006,DateBegin,DateEnd,LevelPayType
INTO #tmpLevel
FROM vw_sprPriceLevelMO 
WHERE CodeM=@codeLPU 


select t.id,65,*
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
	WHERE c.IsCompletedCase=0 AND mes.Price>0
  ) t     
where NOT EXISTS(SELECT 1 FROM vw_sprNotCompletedCaseMUTariff mp WHERE t.MUCode=mp.MU and t.LevelPayType=mp.LevelType and t.IsChildTariff=mp.IsChild and t.DateEnd>=mp.MUPriceDateBeg
					and t.DateEnd<=mp.MUPriceDateEnd and t.Price=mp.Price
				 UNION ALL 
				 SELECT 1 FROM oms_nsi.dbo.PriceMU mp1 WHERE t.MUCode=mp1.CODE_PRICE and t.LevelPayType=ISNULL(mp1.LEVEL_PAY,T.LevelPayType) 
						and t.IsChildTariff=mp1.AGE and t.DateEnd>=mp1.DATE_B and t.DateEnd<=mp1.DATE_E and t.Price=mp1.Price) 
DROP TABLE #tmpLevel
-------------------------------------------------------для индивидуальных тарифов
IF @year<2018
begin
	select c.id,mes.MES,cc.DateEnd,t1.LevelPayType,c.IsChild AS IsChildTariff,mes.Tariff,(CASE WHEN c.rf_idMO IS NOT NULL THEN c.rf_idDepartmentMO ELSE c.rf_idMO END) AS rf_idMO
	INTO #tmpCasePriceMES
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
							and t1.LevelPayType='4'

	 SELECT t.id,65	,*
	FROM #tmpCasePriceMES t																		
	where NOT EXISTS( SELECT * FROM (SELECT CodeM,MU,LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,Price FROM vw_sprCompletedCaseMUTariff 
									 UNION ALL 
									 SELECT CodeM,MU,LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,Price FROM OMS_NSI.dbo.vw_sprCompletedCaseCSGTariff) mp  
					WHERE t.MES=mp.MU and t.rf_idMO=mp.CodeM and t.LevelPayType=mp.LevelType and t.IsChildTariff=mp.IsChild and t.DateEnd>=mp.MUPriceDateBeg
						  and t.DateEnd<=mp.MUPriceDateEnd and t.Tariff=mp.Price)     

	DROP TABLE #tmpCasePriceMES
----------------------------------------------------------------------------------------------------

select c.id,mes.MUCode,cc.DateEnd,t1.LevelPayType, c.IsChild AS IsChildTariff,mes.Price,c.rf_idMO
INTO #tmpCasePrice
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
								inner join dbo.vw_sprPriceLevelMO t1 on
						c.rf_idMO =t1.CodeM
						AND ISNULL(c.rf_idDepartmentMO,0)=ISNULL(t1.DeptCode,0)
						and c.rf_idV006=t1.rf_idV006
						and cc.DateEnd>=t1.DateBegin
						and cc.DateEnd<=t1.DateEnd
						and t1.LevelPayType='4'				
where c.IsCompletedCase=0 AND mes.Price>0

 SELECT t.id,65 FROM #tmpCasePrice t																		
where NOT EXISTS( SELECT * FROM vw_sprNotCompletedCaseMUTariff mp WHERE t.MUCode=mp.MU and t.rf_idMO=mp.CodeM and t.LevelPayType=mp.LevelType
																		and t.IsChildTariff=mp.IsChild and t.DateEnd>=mp.MUPriceDateBeg
																		and t.DateEnd<=mp.MUPriceDateEnd and t.Price=mp.Price)     
DROP TABLE #tmpCasePrice
END