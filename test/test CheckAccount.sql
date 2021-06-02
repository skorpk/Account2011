use AccountOMS
go
declare @account varchar(15)='34001-4-1',
		@codeMO char(6)='255416',
		@month tinyint=12,
		@year smallint=2011

select dbo.fn_CheckAccount(@account,@codeMO,@month,@year)

select f.CodeM,NumberRegister,ReportMonth,p.rf_idSMO
from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack r on
			f.id=r.rf_idFilesBack
			and f.CodeM=@codeMO
				  inner join RegisterCases.dbo.t_RecordCaseBack rec on
			r.id=rec.rf_idRegisterCaseBack
			--and r.ref_idF003=@codeMO 
			and ReportMonth=@month 
			and ReportYear=@year 
				inner join RegisterCases.dbo.t_PatientBack p on
			rec.id=p.rf_idRecordCaseBack							
--where rtrim(p.rf_idSMO)+'-'+CAST(r.NumberRegister as varchar(6))+'-'+CAST(r.PropertyNumberRegister as CHAR(1))= (case when ISNUMERIC(RIGHT(@account,1))=1 then @account else SUBSTRING(@account,1,LEN(@account)-1) end)
group by f.CodeM,NumberRegister,ReportMonth,p.rf_idSMO