USE RegisterCases
go
declare @idFile int
select @idFile=id from vw_getIdFileNumber where CodeM='255627' and NumberRegister= and ReportYear=2013

select ErrorNumber,COUNT(rf_idCase) from t_ErrorProcessControl where rf_idFile=@idFile group by ErrorNumber

select t.id,65,mp.CodeM,t.MUCode,t.rf_idMO,LevelPayType,t.IsChildTariff,t.DateEnd,t.Price
from (
		select c.id,mes.MUCode,c.DateEnd,t1.LevelPayType,c.IsChildTariff,mes.Price,c.rf_idMO
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
								inner join t_Meduslugi mes on
						c.id=mes.rf_idCase
								inner join vw_sprMU m on
						mes.MUCode=m.MU								
								inner join dbo.vw_sprPriceLevelMO t1 on
						c.rf_idMO=t1.CodeM
						and c.rf_idV006=t1.rf_idV006
						and c.DateEnd>=t1.DateBegin
						and c.DateEnd<=t1.DateEnd
						and t1.LevelPayType=4
								left join t_MES m1 on
						mes.rf_idCase=m1.rf_idCase
		where m1.rf_idCase is null
		) t left join vw_sprNotCompletedCaseMUTariff mp on
				t.MUCode=mp.MU
				and t.rf_idMO=mp.CodeM
				and t.LevelPayType=mp.LevelType
				and t.IsChildTariff=mp.IsChild
				and t.DateEnd>=mp.MUPriceDateBeg
				and t.DateEnd<=mp.MUPriceDateEnd
				and t.Price=mp.Price
where mp.MU is null
select mes.rf_idCase,65,2
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
					inner join t_MES mes on
			c.id=mes.rf_idCase
where mes.Tariff=0		
--на дату окончания лечения определяется уровень оплаты для данного медицинского учреждения  и  представленного в случае условия оказания 
select mes.rf_idCase,65,3
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
					inner join t_MES mes on
			c.id=mes.rf_idCase
where mes.Tariff is null

--определяется возраст (на дату начала лечения) пациента: если возраст меньше 18, то применяются детские тарифы, если возраст пациента не меньше 18, то применяются взрослые тарифы
select mes.rf_idCase,65,4
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
						left join dbo.vw_sprPriceLevelMO t1 on
				c.rf_idMO=t1.CodeM
				and c.DateEnd>=t1.DateBegin
				and c.DateEnd<=t1.DateEnd
where t1.CodeM is null
-------------------------------------------------------для общих тариффов
select t.id,65,5
from (
		select c.id,mes.MES,c.DateEnd,t1.LevelPayType,c.IsChildTariff,mes.Tariff
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
								inner join t_MES mes on
						c.id=mes.rf_idCase
								inner join vw_sprMUCompletedCase m on
						mes.MES=m.MU
								inner join dbo.vw_sprPriceLevelMO t1 on
						c.rf_idMO=t1.CodeM
						and c.rf_idV006=t1.rf_idV006
						and c.DateEnd>=t1.DateBegin
						and c.DateEnd<=t1.DateEnd
						and t1.LevelPayType<>4
		) t left join vw_sprCompletedCaseMUTariff mp on
				t.MES=mp.MU
				and t.LevelPayType=mp.LevelType
				and t.IsChildTariff=mp.IsChild
				and t.DateEnd>=mp.MUPriceDateBeg
				and t.DateEnd<=mp.MUPriceDateEnd
				and t.Tariff=mp.Price
where mp.MU is null
-------------------------------------------------------для индивидуальных тарифов
select t.id,65,6
from (
		select c.id,mes.MES,c.DateEnd,t1.LevelPayType,c.IsChildTariff,mes.Tariff,c.rf_idMO
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
								inner join t_MES mes on
						c.id=mes.rf_idCase
								inner join vw_sprMUCompletedCase m on
						mes.MES=m.MU
								inner join dbo.vw_sprPriceLevelMO t1 on
						c.rf_idMO=t1.CodeM
						and c.rf_idV006=t1.rf_idV006
						and c.DateEnd>=t1.DateBegin
						and c.DateEnd<=t1.DateEnd
						and t1.LevelPayType=4
		) t left join vw_sprCompletedCaseMUTariff mp on
				t.MES=mp.MU
				and t.rf_idMO=mp.CodeM
				and t.LevelPayType=mp.LevelType
				and t.IsChildTariff=mp.IsChild
				and t.DateEnd>=mp.MUPriceDateBeg
				and t.DateEnd<=mp.MUPriceDateEnd
				and t.Tariff=mp.Price
where mp.MU is null


select distinct c.id,65,7
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
--Проверка тарифов
--на дату окончания лечения определяется уровень оплаты для данного медицинского учреждения  и  представленного в случае условия оказания 
select mes.rf_idCase,65,8
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_Meduslugi mes on
				c.id=mes.rf_idCase
						left join dbo.vw_sprPriceLevelMO t1 on
				c.rf_idMO=t1.CodeM
				and c.DateEnd>=t1.DateBegin
				and c.DateEnd<=t1.DateEnd
where t1.CodeM is null
--В Справочнике медицинских услуг и тарифов для данного медицинского учреждения (если уровень оплаты - индивидуальный), 
--кода медицинской услуги, возраста пациента, уровня оплаты осуществляется поиск действующего на дату окончания лечения тарифа и 
--производится сравнение с представленным значением
-------------------------------------------------------для общих тариффов
select t.id,65,9
from (
		select c.id,mes.MUCode,c.DateEnd,t1.LevelPayType,c.IsChildTariff,mes.Price
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
								inner join t_Meduslugi mes on
						c.id=mes.rf_idCase
								inner join vw_sprMU m on
						mes.MUCode=m.MU
								inner join dbo.vw_sprPriceLevelMO t1 on
						c.rf_idMO=t1.CodeM
						and c.rf_idV006=t1.rf_idV006
						and c.DateEnd>=t1.DateBegin
						and c.DateEnd<=t1.DateEnd
						and t1.LevelPayType<>4
								left join t_MES m1 on
						mes.rf_idCase=m1.rf_idCase
		where m1.rf_idCase is null
		) t left join vw_sprNotCompletedCaseMUTariff mp on
				t.MUCode=mp.MU
				and t.LevelPayType=mp.LevelType
				and t.IsChildTariff=mp.IsChild
				and t.DateEnd>=mp.MUPriceDateBeg
				and t.DateEnd<=mp.MUPriceDateEnd
				and t.Price=mp.Price
where mp.MU is null

-------------------------------------------------------для индивидуальных тарифов
select t.id,65,t.MUCode,t.rf_idMO,LevelPayType,t.IsChildTariff,t.DateEnd,t.Price
from (
		select c.id,mes.MUCode,c.DateEnd,t1.LevelPayType,c.IsChildTariff,mes.Price,c.rf_idMO
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
								inner join t_Meduslugi mes on
						c.id=mes.rf_idCase
								inner join vw_sprMU m on
						mes.MUCode=m.MU								
								inner join dbo.vw_sprPriceLevelMO t1 on
						c.rf_idMO=t1.CodeM
						and c.rf_idV006=t1.rf_idV006
						and c.DateEnd>=t1.DateBegin
						and c.DateEnd<=t1.DateEnd
						and t1.LevelPayType=4
								left join t_MES m1 on
						mes.rf_idCase=m1.rf_idCase
		where m1.rf_idCase is null
		) t left join vw_sprNotCompletedCaseMUTariff mp on
				t.MUCode=mp.MU
				and t.rf_idMO=mp.CodeM
				and t.LevelPayType=mp.LevelType
				and t.IsChildTariff=mp.IsChild
				and t.DateEnd>=mp.MUPriceDateBeg
				and t.DateEnd<=mp.MUPriceDateEnd
				and t.Price=mp.Price
where mp.MU is null

select mes.rf_idCase,557,c.GUID_Case
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_Meduslugi mes on
				c.id=mes.rf_idCase
						inner join vw_sprMU mu on
				mes.MUCode=mu.MU
						left join dbo.vw_sprNotCompletedCaseMUDate t1 on
			mes.MUCode=t1.MU
			and c.DateEnd>=t1.DateBeg
			and c.DateEnd<=t1.DateEnd
where t1.MU is null

select rf_idCase,554
from (
		select m.rf_idCase,m.MUCode
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
							inner join t_Case c on
					r.id=c.rf_idRecordCase
							inner join t_Meduslugi m on
					c.id=m.rf_idCase							
	  ) t inner join dbo.vw_sprMUCompletedCase t1 on
			t.MUCode=t1.MU

go