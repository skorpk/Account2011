USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test557]    Script Date: 31.12.2018 12:41:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test557]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
---557
--4.	по дате окончания лечения проводится проверка на правомочность применения медицинской организацией указанного кода законченного случая. Проверка проводится в соответствии со справочником разрешенных к применению медицинских услуг
---------------11.04.2014 disable---------------
insert #tError
select mes.rf_idCase,557
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase                      
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
						left join (SELECT * FROM dbo.vw_sprCompletedCaseMUDate UNION ALL SELECT * FROM dbo.vw_sprCSGValid ) t1 on
			(CASE WHEN c.DateEnd>'20170731' AND c.DateEnd<'20180101' AND c.rf_idV006=1 AND c.rf_idMO IN ('101003', '103001', '131001', '171004') THEN c.rf_idDepartmentMO ELSE c.rf_idMO END)=t1.CodeM
			AND mes.MES=t1.MU
			and cc.DateEnd>=t1.DateBeg
			and cc.DateEnd<=t1.DateEnd
where t1.MU is null
--	если на  дату окончания лечения медицинская услуга не разрешена к применению данному медицинскому учреждению

---------------26.03.2013 disable---------------
insert #tError				
select mes.rf_idCase,557
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
				INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase  
				--AND c.IsCompletedCase=0
						inner join t_Meduslugi mes on
				c.id=mes.rf_idCase	
						INNER JOIN dbo.vw_sprMU sm ON
				mes.MUCode=sm.MU			
where NOT EXISTS(SELECT * FROM dbo.vw_sprNotCompletedCaseMUDate t1 WHERE t1.CodeM=c.rf_idMO AND t1.MU=mes.MUCode and t1.DateBeg <=cc.DateEnd and t1.DateEnd>=cc.DateEnd)
--смотрим есть ли медуслуга в справочнике.
insert #tError				
select mes.rf_idCase,557
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_Meduslugi mes on
				c.id=mes.rf_idCase					
where NOT EXISTS(SELECT * FROM dbo.vw_sprMU_V001_Dental t1 WHERE t1.MU=mes.MUCode )
