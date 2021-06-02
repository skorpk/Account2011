USE RegisterCases
GO
select f.id,f.CodeM,a.NumberRegister,COUNT(c.id) AS CountCases
FROM dbo.t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
				inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase					
where NOT EXISTS(SELECT * FROM vw_sprV009 WHERE id=c.rf_idV009 AND f.DateRegistration>=DateBeg AND ISNULL(DateEnd,'20150101')>=f.DateRegistration)
	AND f.DateRegistration>'20140101' AND f.DateRegistration<'20140401'
GROUP BY f.id,f.CodeM,a.NumberRegister
ORDER BY f.id--,c.id
	
