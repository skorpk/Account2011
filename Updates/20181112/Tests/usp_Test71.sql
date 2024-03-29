USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test71]    Script Date: 28.12.2018 13:58:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test71]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

--ID_C
--дубликаты по ID_C
insert #tError
select distinct c1.id,71
from (
		select c.id,cc.GUID_ZSL
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join dbo.t_CompletedCase cc on
				    r.id=cc.rf_idRecordCase							
		where a.rf_idFiles=@idFile
		) c1 inner join (
							select c.GUID_ZSL
							from t_RegistersCase a inner join t_RecordCase r on
										a.id=r.rf_idRegistersCase
													inner join dbo.t_CompletedCase c on
										r.id=c.rf_idRecordCase
							where a.rf_idFiles=@idFile		
							group by c.GUID_ZSL
							having COUNT(*)>1
						) c2 on c1.GUID_ZSL=c2.GUID_ZSL

--ID_PAC

--поиск дубликатов по ID_PAC в файле с людьми
insert #tError
select distinct c1.id,71
from(
		select c.id,r.ID_Patient
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase								
		where a.rf_idFiles=@idFile
	) c1 inner join (
					 select ID_Patient 
					 from t_RegisterPatient 
					 where rf_idFiles=@idFile
					 group by ID_Patient	
					 having COUNT(*)>1
					) c2 on c1.ID_Patient=c2.ID_Patient
--поиск не корректных значений в поле dbo.t_RegisterPatient.ID_Patient
insert #tError
select distinct c1.id,71
from(
		select c.id,r.ID_Patient
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase								
		where a.rf_idFiles=@idFile
	) c1 inner join (
					 select ID_Patient 
					 from t_RegisterPatient 
					 where rf_idFiles=@idFile and ID_Patient in ('','0')
					 group by ID_Patient	
					) c2 on c1.ID_Patient=c2.ID_Patient
--дубликаты по IDSERV
insert #tError
select distinct c1.id,71
from(
		select c.id,m.id as IDSERV
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
				   				inner join t_Meduslugi m on
					c.id=m.rf_idCase
		where a.rf_idFiles=@idFile
	) c1 inner join (
						select m.id
						from t_RegistersCase a inner join t_RecordCase r on
										a.id=r.rf_idRegistersCase
											inner join t_Case c on																																					
								r.id=c.rf_idRecordCase
											inner join t_Meduslugi m on
								c.id=m.rf_idCase			
											left join t_MES mes on
								m.rf_idCase=mes.rf_idCase
						where a.rf_idFiles=@idFile and mes.rf_idCase is null
						group by m.id
						having COUNT(*)>1
					) c2 on c1.IDSERV=c2.id
					
