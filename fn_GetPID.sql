use RegisterCases
go
-------------------------------------------------------------------------------------------------------------
IF OBJECT_ID (N'dbo.fn_GetPID', N'TF') IS NOT NULL
    DROP FUNCTION dbo.fn_GetPID;
GO
CREATE FUNCTION dbo.fn_GetPID(@t as TVP_Insurance READONLY)
RETURNS @pid TABLE
					(
						id bigint,PID int,DateEnd date
					)
AS
begin
/*  ������� ��������� ������ ������ -----------
       fam   im    ot    dr    ss    dn
01   |  +  |  +  | +  |  +  |     |     |
02   |  +  |  +  | +  |     |  +  |     |
03   |  +  |  +  | +  |     |     |  +  |
04   |  +  |  +  |    |  +  |  +  |     |
05   |  +  |  +  |    |  +  |     |  +  |
06   |  +  |  +  |    |     |  +  |  +  |
07   |  +  |     | +  |  +  |  +  |     |
08   |  +  |     | +  |  +  |     |  +  |
09   |  +  |     | +  |     |  +  |  +  |
10   |  +  |     |    |  +  |  +  |  +  |
11   |     |  +  | +  |  +  |  +  |     |
12   |     |  +  | +  |  +  |     |  +  |
13   |     |  +  | +  |     |  +  |  +  |
14   |     |  +  |    |  +  |  +  |  +  |
15   |     |     | +  |  +  |  +  |  +  |
-------------------------------------------*/
declare @tFuond  as table(id int, PID int)
--�� ���	
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
	
insert @pid
select t.id,t.PID,t1.DateEnd
from @tFuond t inner join @t t1 on
		t.id=t1.id
		
	RETURN
end;
go