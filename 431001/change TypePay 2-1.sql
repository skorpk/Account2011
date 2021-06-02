use RegisterCases
go
update  t_CaseBack set TypePay=1 where rf_idRecordCaseBack=1605066
delete from t_ErrorProcessControl where rf_idCase=1624213

select * from t_CaseBack where rf_idRecordCaseBack=1605066