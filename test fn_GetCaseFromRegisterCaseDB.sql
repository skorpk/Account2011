declare @account varchar(15)='34001-1-1',
		@rf_idF003 char(6)='340032',
		@month tinyint=11,
		@year smallint=2011
		
		
--select BINARY_CHECKSUM(*)
--from dbo.fn_GetCaseFromRegisterCaseDB(@account,@rf_idF003,@month,@year)
--select * 
--from dbo.fn_GetMeduslugiFromRegisterCaseDB(@account,@rf_idF003,@month,@year)

select dbo.fn_CheckAccount(@account,@rf_idF003,@month,@year)
--	select CHECKSUM('Good'),CHECKSUM('Good')
--else 
--	select 'Bad'
	
	
	

/*
declare @number int,
		@property tinyint,
		@smo char(5)
		
select @number=SUBSTRING(@account,7,1),@property=SUBSTRING(@account,9,1),@smo=LEFT(@account,5)

select c.GUID_Case,m.id,m.GUID_MU,m.rf_idMO,m.rf_idV002,m.IsChildTariff,m.DateHelpBegin,m.DateHelpEnd,m.DiagnosisCode,
		m.MUCode,m.Quantity,m.Price,m.TotalPrice,m.rf_idV004
from t_RegisterCaseBack reg inner join t_RecordCaseBack rec on
				reg.id=rec.rf_idRegisterCaseBack and
				reg.ref_idF003=@rf_idF003 and
				reg.ReportMonth=@month and
				reg.ReportYear=@year and
				reg.NumberRegister=@number and
				reg.PropertyNumberRegister=@property
							inner join t_PatientBack p on
				rec.id=p.rf_idRecordCaseBack 
				and	p.rf_idSMO=@smo
							inner join t_CaseBack cb on
				rec.id=cb.rf_idRecordCaseBack and
				cb.TypePay=1
							inner join t_Case c on
				rec.rf_idCase=c.id
							inner join t_Meduslugi m on
				c.id=m.rf_idCase
							left join t_Mes mes on
				c.id=mes.rf_idCase
where mes.rf_idCase is null
*/							
