USE RegisterCases
GO
DECLARE @account varchar(15)='34001-14070-1S'
		,@rf_idF003 char(6)='711001'
		,@month TINYINT=11
		,@year SMALLINT=2013

declare @number int,
		@property tinyint,
		@smo char(5),
		@dateStart date=CAST(@year AS CHAR(4))+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01'
		
select @number=dbo.fn_NumberRegister(@account),@smo=dbo.fn_PrefixNumberRegister(@account),@property=dbo.fn_PropertyNumberRegister(@account)
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	
SELECT @dateStart,@dateEnd 


declare @diag as table (rf_idCase bigint,DS0 char(10),DS1 char(10),DS2 char(10))
declare @id int

select @id=reg.id 
from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack reg on
			f.id=reg.rf_idFilesBack
			and f.CodeM=@rf_idF003 
where reg.ReportMonth=@month AND reg.ReportYear=@year and reg.NumberRegister=@number AND reg.PropertyNumberRegister=@property

SET STATISTICS IO ON

select UPPER(t.ID_Patient)
		,t.id
		,t.GUID_Case
		,t.rf_idV006,t.rf_idV008,t.rf_idDirectMO,t.HopitalisationType
		,t.rf_idMO,t.rf_idV002,t.IsChildTariff,t.NumberHistoryCase,t.DateBegin
		,t.DateEnd		
		,d.DS0
		,d.DS1
		,d.DS2	
		,mes.MES
		,t.rf_idV009
		,t.rf_idV012
		,t.rf_idV004
		,t.IsSpecialCase
		,t.rf_idV010
		,mes.Quantity
		,mes.Tariff
		,t.AmountPayment
		,t.SANK_MEK
		,t.SANK_MEE
		,t.SANK_EKMP
		,t.[Emergency]
		,t.Comments
from (
		select rc.ID_Patient
				,c.id
				,c.GUID_Case
				,c.rf_idV006,c.rf_idV008,c.rf_idDirectMO,c.HopitalisationType,
				c.rf_idMO,c.rf_idV002,c.IsChildTariff,c.NumberHistoryCase,c.DateBegin,c.DateEnd		
				,c.rf_idV009
				,c.rf_idV012
				,c.rf_idV004
				,c.IsSpecialCase
				,c.rf_idV010
				,c.AmountPayment
				,0.00 as SANK_MEK
				,0.00 as SANK_MEE
				,0.00 as SANK_EKMP
				,c.[Emergency]
				,c.Comments
		from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack reg on
					f.id=reg.rf_idFilesBack
					and reg.id=@id
									inner join RegisterCases.dbo.t_RecordCaseBack rec on
						reg.id=rec.rf_idRegisterCaseBack 				
									inner join RegisterCases.dbo.t_PatientBack p on
						rec.id=p.rf_idRecordCaseBack and
						p.rf_idSMO=@smo
									inner join RegisterCases.dbo.t_CaseBack cb on
						rec.id=cb.rf_idRecordCaseBack and
						cb.TypePay=1
									inner join RegisterCases.dbo.t_Case c on
						rec.rf_idCase=c.id
						AND c.DateEnd>=@dateStart AND c.DateEnd<@dateEnd
						AND c.rf_idMO=@rf_idF003
									inner join RegisterCases.dbo.t_RecordCase rc on
						c.rf_idRecordCase=rc.id								
			) t inner join RegisterCases.dbo.vw_Diagnosis d on
					t.id=d.rf_idCase
				left join RegisterCases.dbo.t_Mes mes on
					t.id=mes.rf_idCase
go
SET STATISTICS IO OFF