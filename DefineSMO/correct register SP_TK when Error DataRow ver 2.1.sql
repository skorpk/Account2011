use RegisterCases
go
declare @id int,
		@idFileBack INT
		
select @id=fb.rf_idFiles,@idFileBack=fb.id
from t_FileBack fb inner join t_RegisterCaseBack rcb on
				fb.id=rcb.rf_idFilesBack
					inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							left join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
where p.rf_idRecordCaseBack is null and fb.DateCreate>'20210401'
group by  fb.rf_idFiles,fb.id,fb.CodeM
--ORDER BY fb.CodeM desc

IF EXISTS(
			select fb.rf_idFiles,fb.id,COUNT(recb.id),fb.CodeM
			from t_FileBack fb inner join t_RegisterCaseBack rcb on
							fb.id=rcb.rf_idFilesBack
								inner join t_RecordCaseBack recb on
						rcb.id=recb.rf_idRegisterCaseBack
										inner join t_RecordCase rc on
						recb.rf_idRecordCase=rc.id
										left join t_PatientBack p on
						recb.id=p.rf_idRecordCaseBack
			where p.rf_idRecordCaseBack is null and fb.DateCreate>'20210401' --and fb.id=@idFileBack
			group by  fb.rf_idFiles,fb.id,fb.CodeM	
	)
begin
-----------------------------------------------------------------------------------------------------

		declare @table as table(rf_idRecordCaseBack int)
		declare @tableError as table(rf_idRecordCaseBack int)

		begin transaction
		


		INSERT t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,OKATO,rf_idSMO,ENP,CodeSMO34)
		output inserted.rf_idRecordCaseBack into @table
		select DISTINCT recb.id,zp.ROPDOC,RSPOL,UniqueNumberPolicy,ROKATO,
		CASE WHEN ROKATO<>'18000' THEN '34' ELSE s.SMOKOD END ,zp1.UniqueNumberPolicy,s.SMOKOD
		from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
					rcb.id=recb.rf_idRegisterCaseBack
									inner join t_RecordCase rc on
					recb.rf_idRecordCase=rc.id								
									INNER JOIN dbo.t_CompletedCase cc ON
					rc.id=cc.rf_idRecordCase
									inner join t_Case c on		
					recb.rf_idCase=c.id
									inner join t_RefCasePatientDefine d on
					c.id=d.rf_idCase
									inner join t_CasePatientDefineIteration i on
					d.id=i.rf_idRefCaseIteration
					and i.rf_idIteration in (2,4)	
									inner join dbo.t_CaseDefineZP1Found zp1 on
					d.id=zp1.rf_idRefCaseIteration			
									inner join PolicyRegister.dbo.ZP1 zp on
					zp1.rf_idZP1=zp.ID								
									inner join dbo.vw_sprSMOGlobal s on
					zp1.OGRN_SMO=s.OGRN
					and zp1.OKATO=s.OKATO
					AND cc.DateEnd BETWEEN s.dateBeg AND s.dateEnd
									left join t_PatientBack p on							
					recb.id=p.rf_idRecordCaseBack							
		where rf_idFilesBack=@idFileBack and p.rf_idRecordCaseBack is null
		

		--������� ������� � ������� ��� ����������� � �����������
		INSERT t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,OKATO,rf_idSMO,ENP,CodeSMO34)
		output inserted.rf_idRecordCaseBack into @tableError
		select DISTINCT recb.id,rc.rf_idF008,rc.SeriaPolis,rc.NumberPolis,ps.OKATO,ps.rf_idSMO,ps.ENP,ps.rf_idSMO
		from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
					rcb.id=recb.rf_idRegisterCaseBack
									inner join t_RecordCase rc on
					recb.rf_idRecordCase=rc.id		
									INNER JOIN dbo.t_PatientSMO ps ON
					rc.id=ps.ref_idRecordCase						
									INNER JOIN dbo.t_CompletedCase cc ON
					rc.id=cc.rf_idRecordCase
									inner join t_Case c on		
					recb.rf_idCase=c.id
									inner join t_RefCasePatientDefine d on
					c.id=d.rf_idCase
									inner join t_CasePatientDefineIteration i on
					d.id=i.rf_idRefCaseIteration
					and i.rf_idIteration in (2,4)	
									inner join dbo.t_CaseDefineZP1Found zp1 on
					d.id=zp1.rf_idRefCaseIteration			
									inner join PolicyRegister.dbo.ZP1 zp on
					zp1.rf_idZP1=zp.ID		
									left join t_PatientBack p on							
					recb.id=p.rf_idRecordCaseBack														
		where rf_idFilesBack=@idFileBack and p.rf_idRecordCaseBack is NULL
		AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprSMOGlobal s WHERE zp1.OGRN_SMO=s.OGRN AND zp1.OKATO=s.OKATO AND cc.DateEnd BETWEEN s.dateBeg AND s.dateEnd)



		SELECT @@ROWCOUNT
		--��������� ������ � ������� � ������� ��������� ��� ������ �������
		insert t_CaseBack(rf_idRecordCaseBack,TypePay)
		select t.rf_idRecordCaseBack,1
		from @table t

		insert t_CaseBack(rf_idRecordCaseBack,TypePay)
		select t.rf_idRecordCaseBack,2
		from @tableError t



		delete from @table

		--��������� ������� � ��������
		--��������� ������ � ������� � �������� �� ������� �� ���������� ���

		insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,OKATO,rf_idSMO)
		output inserted.rf_idRecordCaseBack into @table
		select recb.id,rc.rf_idF008,rc.SeriaPolis,rc.NumberPolis,'00000','00'
		from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
					rcb.id=recb.rf_idRegisterCaseBack
									inner join t_RecordCase rc on
					recb.rf_idRecordCase=rc.id				
									inner join t_PatientSMO ps on
					rc.id=ps.ref_idRecordCase				
									inner join t_Case c on		
					recb.rf_idCase=c.id
									inner join t_RefCasePatientDefine d on
					c.id=d.rf_idCase
									inner join t_CasePatientDefineIteration i on
					d.id=i.rf_idRefCaseIteration
					and i.rf_idIteration in (4)	
									inner join t_CaseDefineZP1 zp1 on
					d.id=zp1.rf_idRefCaseIteration			
									inner join PolicyRegister.dbo.ZP1 zp on
					zp1.rf_idZP1=zp.ID														
									left join t_PatientBack p on							
					recb.id=p.rf_idRecordCaseBack
		where rf_idFilesBack=@idFileBack and (p.rf_idRecordCaseBack is null) and (zp.RDBEG is null) and isnull(ps.OKATO,'18000')='18000'
		group by recb.id,rc.rf_idF008,rc.SeriaPolis,rc.NumberPolis



		update cb 
		set cb.TypePay=2
		from @table t inner join t_CaseBack cb on
				t.rf_idRecordCaseBack=cb.rf_idRecordCaseBack

		update cb 
		set cb.TypePay=2
		from @tableError t inner join t_CaseBack cb on
				t.rf_idRecordCaseBack=cb.rf_idRecordCaseBack


		--��������� ������ � ������� � ������� ��������� ��� ������ �� �������
		insert t_CaseBack(rf_idRecordCaseBack,TypePay)
		select distinct t.rf_idRecordCaseBack,2 
		from @table t left join t_CaseBack cb on
				t.rf_idRecordCaseBack=cb.rf_idRecordCaseBack
		where cb.rf_idRecordCaseBack is null

		
		--��������� ������ 57 �� ������� ������� �� �������� �� ���
		insert t_ErrorProcessControl(rf_idCase,rf_idFile,ErrorNumber,DateRegistration)
		select rc.rf_idCase,fb.rf_idFiles,57,GETDATE()
		from @table t inner join t_RecordCaseBack rc on
				t.rf_idRecordCaseBack=rc.id
						inner join t_RegisterCaseBack a on
				rc.rf_idRegisterCaseBack=a.id
						inner join t_FileBack fb on
				a.rf_idFilesBack=fb.id
		group by rc.rf_idCase,fb.rf_idFiles

		insert t_ErrorProcessControl(rf_idCase,rf_idFile,ErrorNumber,DateRegistration)
		select rc.rf_idCase,fb.rf_idFiles,57,GETDATE()
		from @tableError t inner join t_RecordCaseBack rc on
				t.rf_idRecordCaseBack=rc.id
						inner join t_RegisterCaseBack a on
				rc.rf_idRegisterCaseBack=a.id
						inner join t_FileBack fb on
				a.rf_idFilesBack=fb.id
		group by rc.rf_idCase,fb.rf_idFiles

		--EXEC dbo.usp_RegisterSP_TK2019 @idFileBack

		--ROLLBACK
		COMMIT
END 
ELSE
BEGIN
		SELECT '�����'
END

GO 