USE RegisterCases
go
create FUNCTION [dbo].IsCompletedCase(@id bigint)
RETURNS tinyint
AS 
begin
	return(
			select case when COUNT(*)=0 then 0 else 1 end from t_MES where rf_idCase=@id
			)
end
go
alter table t_Case add IsCompletedCase as (dbo.IsCompletedCase(id))
go