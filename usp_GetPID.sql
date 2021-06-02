use RegisterCases
go
-------------------------------------------------------------------------------------------------------------
IF OBJECT_ID (N'usp_GetPID', N'P') IS NOT NULL
    DROP procedure dbo.usp_GetPID;
GO
CREATE PROCEDURE dbo.usp_GetPID
(
	@t as TVP_Insurance READONLY
)
as

/*  матрица сочетаний ключей поиска -----------
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
create table #tFound (id int, PID int)

CREATE UNIQUE NONCLUSTERED INDEX IX_tFound_id on #tFound(id) WITH IGNORE_DUP_KEY

--по ЕНП	
	insert #tFound
    select t.id,p.ID 
    from PolicyRegister.dbo.People p inner join @t t on
			p.ENP=t.ENP
    --H01
     insert #tFound
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM and p.IM=t.IM and isnull(p.OT,'')=isnull(t.OT,'') and p.DR=t.DR 
	
	--H02
	 insert #tFound
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on
		p.FAM=t.FAM and p.IM=t.IM 
		and isnull(p.OT,'')=isnull(t.OT,'') 
		and p.SS=t.SS				
	
   --H03
     insert #tFound
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM 
		and p.IM=t.IM 
		and isnull(p.OT,'')=isnull(t.OT,'') 
		and p.DOCN=t.DOCN    
	    
    --H04
     insert #tFound
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM 
		and p.IM=t.IM 
		and p.DR=t.DR 
		and p.SS=t.SS     
	
	--H05
	 insert #tFound
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM and p.IM=t.IM and p.DR=t.DR and p.DOCN=t.DOCN
	
	--H06    
	 insert #tFound
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM 
		and p.IM=t.IM 
		and p.DR=t.DR 
		and p.DOCN=t.DOCN 
		and p.SS=t.SS
	
	--H07
     insert #tFound
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM 
		and p.DR=t.DR 
		and isnull(p.OT,'')=isnull(t.OT,'')
		and p.SS=t.SS
		
	--H08
     insert #tFound
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM and p.DR=t.DR and isnull(p.OT,'')=isnull(t.OT,'') and p.DOCN=t.DOCN
	    
    --H09
     insert #tFound
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM 
		and isnull(p.OT,'')=isnull(t.OT,'') 
		and p.DOCN=t.DOCN 
		and p.SS=t.SS
		
 --H10   
     insert #tFound
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.FAM=t.FAM 
		and p.DR=t.DR 
		and p.DOCN=t.DOCN 
		and p.SS=t.SS
			 
    --H11
    insert #tFound
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.IM=t.IM 
		and isnull(p.OT,'')=isnull(t.OT,'') 
		and p.DR=t.DR 
		and p.SS=t.SS
	

    --H12
    insert #tFound
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.IM=t.IM 
		and isnull(p.OT,'')=isnull(t.OT,'') 
		and p.DR=t.DR 
		and p.DOCN=t.DOCN
	
	 --H13
    insert #tFound
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.IM=t.IM 
		and isnull(p.OT,'')=isnull(t.OT,'') 
		and p.SS=t.SS 
		and p.DOCN=t.DOCN
	
   
    --H14
    insert #tFound
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		p.IM=t.IM 
		and  p.DR=t.DR 
		and p.DOCN=t.DOCN 
		and p.SS=t.SS
	
    --H15
    insert #tFound
     select t.id,p.ID 
     from PolicyRegister.dbo.People p inner join @t t on 
		isnull(p.OT,'')=isnull(t.OT,'') 
		and p.DR=t.DR 
		and p.DOCN=t.DOCN 
		and p.SS=t.SS
	--поиск по HISTENP, HISTFDR, HISTUDL
	--по ЕНП	
	insert #tFound
    select t.id,p.ID 
    from PolicyRegister.dbo.HISTENP p inner join @t t on
			p.ENP=t.ENP	
	--2
	insert #tFound
     select t.id,p.ID 
     from PolicyRegister.dbo.HISTFDR p inner join @t t on 
		p.FAM=t.FAM and p.IM=t.IM and isnull(p.OT,'')=isnull(t.OT,'') and p.DR=t.DR 
	
	--3
	 insert #tFound
     select t.id,p.ID 
     from vw_HISTPEOPLE p inner join @t t on 
		p.FAM=t.FAM 
		and p.IM=t.IM 
		and isnull(p.OT,'')=isnull(t.OT,'') 
		and p.DOCN=t.DOCN  	
	
	--4
	 insert #tFound
     select t.id,p.ID 
     from vw_HISTPEOPLE p inner join @t t on 
		p.FAM=t.FAM and p.IM=t.IM and p.DR=t.DR and p.DOCN=t.DOCN
	
	--5
	 insert #tFound
     select t.id,p.ID 
     from vw_HISTPEOPLE p inner join @t t on 
		p.FAM=t.FAM and isnull(p.OT,'')=isnull(t.Ot,'') and p.DR=t.DR and p.DOCN=t.DOCN	
		
	 --6
	 insert #tFound
     select t.id,p.ID 
     from vw_HISTPEOPLE p inner join @t t on 
		p.IM=t.IM 
		and isnull(p.OT,'')=isnull(t.OT,'') 
		and p.DR=t.DR 
		and p.DOCN=t.DOCN	
		
--------------------------------------------------------------------
------04.10.2014 добавленна кологка начала случая		
	insert #tPeople(rf_idRefCaseIteration,PID,DateEnd,DateBegin)
	select t.id,t.PID,t1.DateEnd,c.DateBegin
	from #tFound t inner join @t t1 on
			t.id=t1.id
					inner join t_RefCasePatientDefine r on
			t.id=r.id
						inner join t_Case c on
			r.rf_idCase=c.id
	group by t.id,t.PID,t1.DateEnd,c.DateBegin
go