use RegisterCases
go
IF OBJECT_ID (N'dbo.GetTypePay', N'FN') IS NOT NULL
    DROP FUNCTION dbo.GetTypePay;
GO
CREATE FUNCTION dbo.GetTypePay(@id bigint)
RETURNS tinyint
AS 
begin
	return(
			select top 1 TypePay from t_CaseBack where rf_idRecordCaseBack=@id
			)
end
go
alter table t_RecordCaseBack add TypePay as dbo.GetTypePay(id)
go
