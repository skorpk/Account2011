USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test593]    Script Date: 26.01.2017 11:31:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test593]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
---2016-12-21
--1.	Если тег COMENTSL присутствует и если  в CODE_MES1 присутствуют услуги из класса 70.3* или 72.1* или в одном из тегов USL содержится хотя бы одна услуга из класса 2.84*
-- или из класса 2.90.* то в теге  COMENTSL  должно быть представлено одно из следующих значений: 10,  11,  14,  20,  21.
insert #tError
select c.id,593
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase	
						INNER JOIN (SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=72 AND MUUnGroupCode=1
									UNION ALL 
									SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=70 AND MUUnGroupCode=3
									) mc on
				mes.MES=mc.MU						
WHERE c.Comments IS NULL

insert #tError
select c.id,593
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_DispInfo d ON
				c.id=d.rf_idCase                      
WHERE UPPER(d.TypeDisp) IN ('ДВ1','ДВ2') AND NOT EXISTS(SELECT * FROM (VALUES('10'),('11'),('14'),('20'),('21')) v(Code) WHERE v.Code=c.Comments)
-----2016-12-21
--insert #tError
--select c.id,593
--from t_RegistersCase a inner join t_RecordCase r on
--				a.id=r.rf_idRegistersCase
--				and a.rf_idFiles=@idFile
--						inner join t_Case c on
--				r.id=c.rf_idRecordCase	
--						inner join dbo.t_Meduslugi m on
--				c.id=m.rf_idCase	
--						INNER JOIN (SELECT MU FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode IN (84,90)) mc on
--				m.MUCode=mc.MU	
--						LEFT JOIN (VALUES('10'),('11'),('14'),('20'),('21')) v(t)	ON
--				isnull(c.Comments,'99')=v.t	
--WHERE v.T IS null
--если codem=101001 и CODE_MES1 равен одному из следующих значений:  12**304, 12**305, 22**115, 22**116,  то в обязательном порядке должен быть заполнен тег COMENTSL
--и должно быть представлено одно из следующих значений: 0, 1, 2
--insert #tError
--select c.id,593
--from t_File f INNER JOIN t_RegistersCase a ON
--		f.id=a.rf_idFiles
--		and f.id=@idFile
--			  inner join t_RecordCase r on
--				a.id=r.rf_idRegistersCase				
--						inner join t_Case c on
--				r.id=c.rf_idRecordCase	
--						inner join t_MES mes on
--				c.id=mes.rf_idCase	
--						INNER JOIN (SELECT code FROM dbo.vw_sprCSG WHERE code LIKE '12__304'
--									UNION ALL
--									SELECT code FROM dbo.vw_sprCSG WHERE code LIKE '12__305'
--									UNION ALL
--									SELECT code FROM dbo.vw_sprCSG WHERE code LIKE '22__115'
--									UNION ALL
--									SELECT code FROM dbo.vw_sprCSG WHERE code LIKE '22__116'
--									) mc on
--				mes.MES=mc.code		
--						LEFT JOIN (VALUES('0'),('1'),('2')) v(t)	ON
--				isnull(c.Comments,'99')=v.t
--WHERE f.CodeM='101001' AND v.T IS null 



