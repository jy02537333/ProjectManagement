Create PROCEDURE [dbo].[CalcSheBeiZL]
@XMPathKey varchar(100),
@GZ Varchar(50),
@MC Varchar(100),
@GG Varchar(50),
@DW Varchar(50),
@StartDate datetime ,
@EndDate datetime,
@ZLDJ float output,
@ZLJE float output,
@LJZLTS float output
AS  
  declare @DateSql Varchar(200) 
  declare @Sql Varchar(1000)   
  
  declare @FuDate DateTime 
  Set @FuDate=-1 
  
  declare @LastStartDate DateTime  
  Set @LastStartDate=@FuDate
  
  declare @LastSaveCalcedDate DateTime  
  Set @LastSaveCalcedDate=@FuDate
  
  declare @KCL float
  set @KCL=0
  
  Set @LJZLTS=0 
  Set @ZLDJ=0
  Set @ZLJE=0
  
  IF IsNULL(@StartDate,'')<>''   --求出期初库存量 @KCL
  Begin
    Set @Sql='Declare cur_KCL Cursor For Select Sum(变动数量) As SL From 固定设备明细表 where 冲销=0 And CharIndex('''+@XMPathKey+''',XMPathKey)=1  '
    Set @Sql=@Sql+' And 工种='''+@GZ+''' And 名称='''+@MC+''' And 单位='''+@DW+''' And 发生日期 <'''+cast(@StartDate as varchar(80))+'''' 
    Exec(@Sql)-- And 规格='''+@GG+'''
    Open cur_KCL
    Fetch Next From cur_KCL into @KCL  
    Set @KCL=ISNULL(@KCL,0) 
    Close cur_KCL
    deallocate cur_KCL 
    
  End

  --创建 一个临时表 用来存储  每个时间段 的租赁单价

  IF OBJECT_ID('#固定设备租赁单价临时表') is not null  
     Drop Table #固定设备租赁单价临时表

  Create Table #固定设备租赁单价临时表 (开始日期 DateTime,终止日期 DateTime,租赁单价 Float)
 
  Declare @ZLJD varchar(8000) --租赁阶段  
  Set @ZLJD=''
  
   
  Set @Sql='Declare cur_ZLDJ Cursor For Select 租赁单价,Convert ( VARCHAR(8000),租赁阶段) As ZLJD     From 固定设备表 where 1=1 '
  Set @Sql=@Sql+' And 工种='''+@GZ+''' And 设备名称='''+@MC+''' And 规格='''+@GG+''' And 单位='''+@DW+'''' 
  Exec(@Sql)
  Open cur_ZLDJ
  Fetch Next From cur_ZLDJ into @ZLDJ,@ZLJD 
  IF (@@Fetch_Status<>0) 
  Begin 
    Close cur_ZLDJ
    deallocate cur_ZLDJ
    Set @Sql='Declare cur_ZLDJ Cursor For Select 租赁单价,Convert (VARCHAR(8000),租赁阶段) As ZLJD From 固定设备表 where 1=1 '
    Set @Sql=@Sql+' And 工种='''+@GZ+''' And 名称='''+@MC+''' And 单位='''+@DW+'''' 
    Exec(@Sql)
    Open cur_ZLDJ
    Fetch Next From cur_ZLDJ into @ZLDJ,@ZLJD 
  End
  Close cur_ZLDJ
  deallocate cur_ZLDJ 

  Set @ZLDJ=ISNULL(@ZLDJ,0)  
  declare @S varchar(300)
  declare @Str1 varchar(100)
  declare @Str2 varchar(100)
  declare @Str3 varchar(30)
  declare @Date1 DateTime
  declare @Date2 DateTime
  declare @DJ Float
  declare @P Int
  declare @P1 Int 
  Set @P=CharIndex( Char(13)+Char(10),@ZLJD)   
  While (@P>0)  
  Begin 
 
    Set @S=substring(@ZLJD,1,@P-1)   --先截出一行 
    Set @ZLJD=substring(@ZLJD,@P+1,len(@ZLJD)) --保存下面的行数
  
    Set @P1=CharIndex(';',@S)
    Set @Str1=substring(@S,1,@P1-1)    
     
    Set @S=substring(@S,@P1+1,len(@S))   
    Set @P1=CharIndex(';',@S)
    Set @Str2=substring(@S,1,@P1-1)   
    Set @Str3=substring(@S,@P1+1,len(@S))  

    Set @Date1=convert(Datetime,(convert(float,@Str1)))-2
    Set @Date2=convert(Datetime,(convert(float,@Str2)))-2
    Set @DJ= CAST ( @Str3 AS float ) 
  
    Insert into #固定设备租赁单价临时表 values(@Date1,@Date2,@DJ)
    Set @P=CharIndex( Char(13)+Char(10),@ZLJD) 
  
  End
  
 
  declare @DWTS float  
  declare @ZLF float   
  declare @IsFirst bit
  Set @IsFirst=1
  
  declare @BDSL float
  declare @FSRQ datetime
  declare @ThisDate datetime
  
  --OpenZLQuy  先打开 该设备 在该项目的 记录明细 按发生日期排序
  Set @Sql='Declare cur_Detail Cursor For Select 发生日期,变动数量 From 固定设备明细表 where 冲销=0 '
  Set @Sql=@Sql+' And 工种='''+@GZ+''' And 名称='''+@MC+''' And 规格='''+@GG+''' And 单位='''+@DW+'''' 
  Set @Sql=@Sql+' And CharIndex('''+@XMPathKey +''',XMPathKey)=1 '
  IF IsNULL(@StartDate,'')<>'' 
  Begin
    Set @Sql=@Sql+' And 发生日期 >='''+cast(@StartDate as varchar(80))+''''
  End
  IF IsNULL(@EndDate,'')<>'' 
  Begin
    Set @Sql=@Sql+' And 发生日期 <='''+cast(@EndDate as varchar(80))+''''
  End 
  Set @Sql=@Sql+ ' order by 发生日期'   
  Exec(@Sql)
  Open cur_Detail
  Fetch Next From cur_Detail into @FSRQ,@BDSL  
  
  IF @@Fetch_Status<>0
  Begin 
    Exec GetZLJE @KCL,0,@StartDate,@EndDate,@ZLDJ,@DWTS out ,@ZLF out
    Set @DWTS=DateDiff(DD,@StartDate,@EndDate+1)*@KCL
    Set @ZLJE=@ZLJE+@ZLF
    Set @LJZLTS=@LJZLTS+ @DWTS
 

    Close cur_Detail
    deallocate cur_Detail 
    Return
  End 
  
 
	While (@@Fetch_Status=0) 
	Begin
	  Set @DWTS=0
	  Set @ZLF=0
	  Set @BDSL=ISNULL(@BDSL,0) 

	  IF @IsFirst=1 
	  Begin
	    Set @IsFirst=0
		IF IsNULL(@StartDate,'')<>''   --求出期初库存量 @KCL
		Begin
		  Exec GetZLJE @KCL,0,@StartDate,@FSRQ,@ZLDJ,@DWTS out ,@ZLF out --原来的0是BDSL

		  Set @DWTS=(DateDiff(DD,@StartDate,@FSRQ)+1)*@KCL
		  Set @ZLJE=@ZLJE+@ZLF
		  Set @LJZLTS=@LJZLTS+@DWTS
		  Set @LastStartDate= @FSRQ
		  Set @LastSaveCalcedDate= @FSRQ 
	      --Fetch Next From cur_Detail into @FSRQ,@BDSL  
		  --continue
		End    
	  End

	  IF (@LastStartDate<>@FuDate) And ( DateDiff(DD,@EndDate,@FSRQ)>0 )  
	  Begin
		 Break --这里不能用EXIT 因为 LastStartDate可能小于 ByDate
	  End

	  IF (@LastStartDate=@FuDate) 
	  Begin 
		 Exec GetZLJE @KCL,@BDSL,@LastStartDate,@FSRQ,@ZLDJ,@DWTS out ,@ZLF out  
	  End 

	  IF (@LastStartDate<>-1) 
	  Begin
		IF ( DateDiff(DD,@FSRQ,@LastStartDate)=0 ) 
		Begin
		  IF @LastStartDate=@LastSaveCalcedDate     
		  Begin
			 Exec GetZLJE 0,@BDSL,@LastStartDate,@FSRQ,@ZLDJ,@DWTS out ,@ZLF out 
		  End
	         
		  IF @LastStartDate<>@LastSaveCalcedDate
		  Begin
			 Exec GetZLJE @KCL,@BDSL,@LastStartDate,@FSRQ,@ZLDJ,@DWTS out ,@ZLF out 
	      End
		End
		IF ( DateDiff(DD,@FSRQ,@LastStartDate)<>0 ) 
		Begin
		  Set @ThisDate=@LastStartDate+1
		  Exec GetZLJE @KCL,@BDSL,@ThisDate,@FSRQ,@ZLDJ,@DWTS out ,@ZLF out 
		    
		End
	  End
	 
	  Set @LastStartDate=@FSRQ
	  IF @BDSL>0  
	  Begin
		Set @LastSaveCalcedDate =@FSRQ
	  End
	  Set @KCL=@KCL+@BDSL
	  Set @ZLJE=@ZLJE+@ZLF
	  Set @LJZLTS=@LJZLTS+@DWTS
 
	  Fetch Next From cur_Detail into @FSRQ,@BDSL  
	End 

	IF (DateDiff(DD,@LastStartDate,@EndDate)>0 ) 
	Begin
	  Set @DWTS=0
	  Set @ZLF=0
	  Set @ThisDate=@LastStartDate+1
	  Exec GetZLJE @KCL,0,@ThisDate,@EndDate,@ZLDJ,@DWTS out ,@ZLF out
	  Set @DWTS= @KCL*(DateDiff(DD,@LastStartDate,@EndDate)  )
	  Set @ZLJE=@ZLJE+@ZLF
	  Set @LJZLTS=@LJZLTS+ @DWTS 
	End


    Close cur_Detail
    deallocate cur_Detail 
  