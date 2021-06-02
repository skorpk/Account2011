USE AccountOMS
GO
declare @account varchar(15)='34007-1251-0F',
		@rf_idF003 char(6)='145516',
		@month TINYINT=1,
		@year SMALLINT =2019


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
SELECT @id
SELECT DISTINCT UPPER(t.ID_Patient)
		,t.id
		,t.GUID_Case
		,t.rf_idV006,t.rf_idV008
		,t.rf_idV014
		--,t.rf_idDirectMO
		,t.rf_idMO
		,t.rf_idV002
		,t.NumberHistoryCase
		,t.DateBegin
		,t.DateEnd		
		,d.DS1
		,t.IsFirstDS
		,t.IsNeedDisp	
		,mes.MES
		,t.rf_idV009
		,t.rf_idV012
		,t.rf_idV004
		,t.rf_idV010
		,mes.Quantity
		,mes.Tariff
		,t.AmountPayment		
		,t.Comments
		,t.rf_idDoctor
		,t.rf_idSubMO
		-----------------
		,t.GUID_ZSL
		,t.DateBegin_ZSL
		,t.DateEnd_ZSL
		,t.AmountPayment_ZSL
		,t.rf_idV025
		,t.IsMobileTeam
		,t.TypeFailure
from (
		select rc.ID_Patient
				,c.id
				,c.GUID_Case
				,c.rf_idV006
				,c.rf_idV008
				,c.rf_idV014				
				,c.rf_idDirectMO
				,c.rf_idMO
				,c.rf_idV002
				,c.NumberHistoryCase
				,c.DateBegin
				,c.DateEnd	
				,c.IsFirstDS
				,c.IsNeedDisp	
				,c.rf_idV009
				,c.rf_idV012
				,c.rf_idV004
				,c.rf_idV010
				,c.AmountPayment				
				,c.Comments
				,c.rf_idDoctor
				,c.rf_idSubMO
				,cc.GUID_ZSL,cc.DateBegin AS DateBegin_ZSL,cc.DateEnd AS DateEnd_ZSL,cc.AmountPayment AS AmountPayment_ZSL,pv.rf_idV025, di.IsMobileTeam, di.TypeFailure
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
									left JOIN RegisterCases.dbo.t_PurposeOfVisit pv ON
						c.id=pv.rf_idCase
									inner JOIN RegisterCases.dbo.t_DispInfo di ON
						c.id=di.rf_idCase
			) t inner join RegisterCases.dbo.vw_Diagnosis d on
					t.id=d.rf_idCase
				left join RegisterCases.dbo.t_Mes mes on
					t.id=mes.rf_idCase
GO

