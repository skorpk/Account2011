use RegisterCases
go
declare @t as TVP_Insurance



insert @t
select t.id,case when rc.rf_idF008=3 then rc.SeriaPolis else null end,p.Fam,p.Im,p.Ot,p.BirthDay,p.BirthPlace,pd.SNILS,null,pd.NumberDocument,null,
		c.DateEnd
from t_RefCasePatientDefine t inner join t_Case c on
		t.rf_idCase=c.id 
		and t.rf_idFiles=21		
				inner join t_RegisterPatient p on
		t.rf_idRegisterPatient=p.id
				inner join t_RecordCase rc on
		p.rf_idRecordCase=rc.id
				left join t_RegisterPatientDocument pd on
		p.id=pd.rf_idRegisterPatient
  
 --exec usp_GetPID @t 
 --select * from dbo.fn_GetPID(@t)
  
  declare @tFuond as table(id int, PID int)
--ОН емо	
	insert @tFuond
    select t.id,p.ID 
    from PolicyRegister.dbo.People p inner join @t t on
			p.ENP=t.ENP
    --H01
     insert @tFuond
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM and p.IM=t.IM and isnull(p.OT,'')=isnull(t.OT,'') and p.DR=t.DR 
						left join @tFuond tf on
		t.id=tf.id
	where tf.id is null
	--H02
	 insert @tFuond
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM and p.IM=t.IM and isnull(p.OT,'')=isnull(t.OT,'') and p.SS=t.SS
						left join @tFuond tf on
		t.id=tf.id
	where tf.id is null 
    --H03
     insert @tFuond
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM and p.IM=t.IM and isnull(p.OT,'')=isnull(t.OT,'') and p.DOCN=t.DOCN    
						left join @tFuond tf on
		t.id=tf.id
	where tf.id is null
    
    --H04
     insert @tFuond
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM and p.IM=t.IM and p.DR=t.DR and p.SS=t.SS     
						left join @tFuond tf on
		t.id=tf.id
	where tf.id is null
	--H05
	 insert @tFuond
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM and p.IM=t.IM and p.DR=t.DR and p.DOCN=t.DOCN
						left join @tFuond tf on
		t.id=tf.id
	where tf.id is null
	--H06    
	 insert @tFuond
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM and p.IM=t.IM and p.DR=t.DR and p.DOCN=t.DOCN and p.SS=t.SS
						left join @tFuond tf on
		t.id=tf.id
	where tf.id is null
	--H07
     insert @tFuond
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM and p.DR=t.DR and isnull(p.OT,'')=isnull(t.OT,'') and p.SS=t.SS
						left join @tFuond tf on
		t.id=tf.id
	where tf.id is null
	
	--H08
     insert @tFuond
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM and p.DR=t.DR and isnull(p.OT,'')=isnull(t.OT,'') and p.DOCN=t.DOCN
						left join @tFuond tf on
		t.id=tf.id
	where tf.id is null
    
    --H09
     insert @tFuond
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM and isnull(p.OT,'')=isnull(t.OT,'') and p.DOCN=t.DOCN and p.SS=t.SS
						left join @tFuond tf on
		t.id=tf.id
	where tf.id is null
	
 --H10   
     insert @tFuond
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM and p.DR=t.DR and p.DOCN=t.DOCN and p.SS=t.SS
						left join @tFuond tf on
		t.id=tf.id
	 where tf.id is null
	 
    --H11
    insert @tFuond
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.IM=t.IM and isnull(p.OT,'')=isnull(t.OT,'') and p.DR=t.DR and p.SS=t.SS
						left join @tFuond tf on
		t.id=tf.id
	 where tf.id is null

    --H12
    insert @tFuond
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.IM=t.IM and isnull(p.OT,'')=isnull(t.OT,'') and p.DR=t.DR and p.DOCN=t.DOCN
						left join @tFuond tf on
		t.id=tf.id
	 where tf.id is null
	 --H13
    insert @tFuond
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.IM=t.IM and isnull(p.OT,'')=isnull(t.OT,'') and p.SS=t.SS and p.DOCN=t.DOCN
						left join @tFuond tf on
		t.id=tf.id
	 where tf.id is null
   
    --H14
    insert @tFuond
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.IM=t.IM and  p.DR=t.DR and p.DOCN=t.DOCN and p.SS=t.SS
						left join @tFuond tf on
		t.id=tf.id
	 where tf.id is null
    --H15
    insert @tFuond
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		isnull(p.OT,'')=isnull(t.OT,'') and p.DR=t.DR and p.DOCN=t.DOCN and p.SS=t.SS
						left join @tFuond tf on
		t.id=tf.id
	 where tf.id is null

select * from @tFuond