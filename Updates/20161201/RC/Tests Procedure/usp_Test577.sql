USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test577]    Script Date: 26.01.2017 13:35:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test577]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--PRVS
insert #tError
select distinct c.id,577
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						left join vw_sprV004 v on
			m.rf_idV004=v.id
			AND c.DateEnd>=v.DateBeg
			AND c.DateEnd<=v.DateEnd 
where v.id is null

-----------------2014-02-04---------------
--insert #tError
--select distinct c.id,577
--from t_RegistersCase a inner join t_RecordCase r on
--			a.id=r.rf_idRegistersCase
--			and a.rf_idFiles=@idFile
--						inner join t_Case c on
--			r.id=c.rf_idRecordCase
--						inner join t_Meduslugi m on
--			c.id=m.rf_idCase
--						inner join vw_sprMU mu on
--			m.MUCode=mu.MU
--			LEFT JOIN vw_idCaseWithOutPRVSandProfilCompare ce ON
--			c.id=ce.id
--			AND ce.rf_idFiles=@idFile				
--WHERE ce.id IS NULL and c.rf_idV004<>m.rf_idV004
------------2014-02-26
insert #tError
select distinct c.id,577
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase			
			--AND c.IsSpecialCase IS NULL			
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						inner join vw_sprMU mu on
			m.MUCode=mu.MU
			LEFT JOIN vw_idCaseWithOutPRVSandProfilCompare ce ON
			c.id=ce.id
			AND ce.rf_idFiles=@idFile				
WHERE c.rf_idV002<>158 and ce.id IS NULL and c.rf_idV004<>m.rf_idV004
