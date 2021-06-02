USE RegisterCases
go
SET NOCOUNT ON

select p.rf_idFiles,COUNT(p.id) as AmountPatien
from t_File f inner join t_RegisterPatient p on
		f.id=p.rf_idFiles
where f.DateRegistration>'20121001' and p.Fam='мер' 
group by p.rf_idFiles
go