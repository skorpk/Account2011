USE RegisterCases
GO
BEGIN TRANSACTION
DELETE FROM dbo.t_AgeMU2
FROM dbo.t_AgeMU2 a INNER JOIN (VALUES('70.3.97',36),('70.3.98',36),('70.3.97',39),('70.3.98',39) ) v(MU,Age) ON
				a.MU=v.MU
				AND a.age=v.age

INSERT dbo.t_AgeMU2
        ( MU, Sex, Age )
VALUES  ('70.3.99',1,36),('70.3.100',1,36),('70.3.99',1,39),('70.3.100',1,39),
		('70.3.198',1,45),('70.3.199',1,45),('70.3.200',1,45),('70.3.201',1,45),('70.3.202',2,66)


commit

