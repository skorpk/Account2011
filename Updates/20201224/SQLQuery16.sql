USE AccountOMS
GO
DECLARE @account varchar(15)='34-254-2S'
		,@rf_idF003 char(6)='146004'
		,@month TINYINT=12
		,@year SMALLINT=2020

declare @number int,
		@property tinyint,
		@smo char(5),
		@letter CHAR(1)
		
select @number=dbo.fn_NumberRegister(@account),@smo=dbo.fn_PrefixNumberRegister(@account),@property=dbo.fn_PropertyNumberRegister(@account),
		@letter=RIGHT(@account,1)

declare @diag as table (rf_idCase bigint,DS0 char(10),DS1 char(10),DS2 char(10))
declare @id int

select @id=reg.id 
from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack reg on
			f.id=reg.rf_idFilesBack
			and f.CodeM=@rf_idF003 
where reg.ReportMonth=@month and	reg.ReportYear=@year and reg.NumberRegister=@number and	reg.PropertyNumberRegister=@property

SELECT DISTINCT UPPER(t.ID_Patient),t.id		
		,t.GUID_ZSL
		,t.rf_idV006,t.rf_idV008,t.rf_idV014,t.rf_idV018,t.rf_idV019,t.rf_idDirectMO,t.HopitalisationType,t.rf_idMO
			,t.rf_idV002,t.IsChildTariff,t.NumberHistoryCase,t.DateBegin,t.DateEnd,d.DS0
		,d.DS1
		,NULL AS DS2	
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
		,t.IT_SL
		,t.TypeTranslation
		,t.rf_idDoctor
		,t.rf_idSubMO
		,rf_idDepartmentMO
		,t.MSE
		,t.C_ZAB
		,ds.DS_ONK
		,t.GUID_Case
		,t.VB_P
		,t.DateBegin_ZSL
		,t.DateEnd_ZSL		
		,t.HospitalizationPeriod
		,t.AmountPayment_ZSL
		,KD
from (
		select rc.ID_Patient
				,c.id
				,c.GUID_Case
				,c.rf_idV006,c.rf_idV008
				,c.rf_idV014,c.rf_idV018,c.rf_idV019
				,c.rf_idDirectMO,c.HopitalisationType,
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
				,c.IT_SL
				,c.TypeTranslation
				,c.rf_idDoctor, c.rf_idSubMO, c.rf_idDepartmentMO,c.MSE,c.C_ZAB
				,cc.GUID_ZSL,cc.DateBegin AS DateBegin_ZSL,cc.DateEnd AS DateEnd_ZSL,cc.VB_P,cc.HospitalizationPeriod,cc.AmountPayment AS AmountPayment_ZSL
				,c.KD
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
									inner join RegisterCases.dbo.t_RecordCase rc on
						c.rf_idRecordCase=rc.id		
									INNER JOIN RegisterCases.dbo.t_CompletedCase cc ON
						rc.id=cc.rf_idRecordCase						
			) t inner join RegisterCases.dbo.vw_Diagnosis d on
					t.id=d.rf_idCase
				left join RegisterCases.dbo.t_Mes mes on
					t.id=mes.rf_idCase
				LEFT JOIN RegisterCases.dbo.t_DS_ONK_REAB ds ON
					t.id=ds.rf_idCase              

