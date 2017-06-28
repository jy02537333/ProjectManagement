Create PROCEDURE [dbo].[CalcChengBen4] 
@XMPathKey varchar(100),
@StartDate datetime,
@EndDate datetime,
@KuFangCheck bit,
@HasJiaGongCai bit, 
@ShenHeCheck bit,
@FBCBYiFuKuanShuCheck bit,
@KCFKCheck bit,
@KCFBHTDKGLF_SJCheck bit,
@ZZSTDCBCheck bit,
@QTSRCDCBCheck bit,
@LWYJSGZWZCheck bit,
@FaPiaoJE float output,
@totalcb float output
AS 
  declare @cs Varchar(20)
  declare @Tmpcb1 float
  declare @Tmpcb2 float
  declare @Tmpcb3 float
  declare @DateSql Varchar(1000)
  declare @DateSql_kaoqin Varchar(1000) 
  declare @Sql Varchar(1000)  
  declare @issh bit
  declare @YWDJShenHeSql Varchar(20)  

  set @totalcb=0
  Set @DateSql=''
  Set @DateSql_kaoqin=''
  IF IsNULL(@StartDate,'')<>'' 
  Begin
    Set @DateSql=@DateSql+' And 发生日期 >='''+cast(@StartDate as varchar(80))+''''
    Set @DateSql_kaoqin=@DateSql_kaoqin+' And 考勤日期 >='''+cast(@StartDate as varchar(80))+''''
  End
  IF IsNULL(@EndDate,'')<>'' 
  Begin
    Set @DateSql=@DateSql+' And 发生日期 <='''+cast(@EndDate as varchar(80))+''''
    Set @DateSql_kaoqin=@DateSql_kaoqin+' And 考勤日期 <='''+cast(@EndDate as varchar(80))+''''
  End
 
 
  Set @Sql='Declare cur1 Cursor Global For Select Sum(对应金额) As FPJE From 发票子表 where 对应单据类型=''承包合同'' And 冲销=0 And CharIndex('''+@XMPathKey +''',XMPathKey)=1 ';
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @FaPiaoJE  
  Set @FaPiaoJE=ISNULL(@FaPiaoJE,0) 
  Close cur1
  deallocate cur1 

 
  Set @YWDJShenHeSql='' 
  IF @issh=1 Begin set @YWDJShenHeSql=' And 审核否=1 ' End 

  set @issh=0
  select @issh=启用 From 系统全局设置表 where 设置名称='材料的所有单据只有审核后才可产生库存和用量' 
  
  
--  库房check
  declare @sylw bit
  set @sylw=0
  select @sylw=启用 From 系统全局设置表 where 设置名称='使用劳务管理模块'
  set @Sql=''  
  IF @KuFangCheck=1 Begin set @Sql='Declare cur1 Cursor Global For  Select Sum(金额*(项目基数+库房基数)) As Ljcb from 材料明细表 Where 冲销=0 And (项目基数<>0 or 库房基数<>0) And CharIndex('''+@XMPathKey +''',XMPathKey)=1'  End
  IF @KuFangCheck=0 Begin set @Sql='Declare cur1 Cursor Global For  Select Sum(金额*项目基数) As Ljcb from 材料明细表 Where 冲销=0 And 项目基数<>0 And CharIndex('''+@XMPathKey +''',XMPathKey)=1' End 
  IF @HasJiaGongCai=0 Begin  set @sql=@sql+' And 甲供材=0 ' End 
  Set @Sql=@Sql+' And CharIndex('''+@XMPathKey+''',XMPathKey)=1 '
  Set @Sql=@sql+@DateSql 
  Set @Sql=@Sql+ @YWDJShenHeSql
  IF @ShenHeCheck=1 Begin set @Sql=@Sql+' And MainID In (Select AutoID From 材料总账表 where 审核否=1 )' End 
  Set @Tmpcb1=0
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @Tmpcb1 
  Close cur1
  deallocate cur1 
  Set @totalcb=@totalcb+ISNULL(@tmpcb1,0) 
 

-- 劳务管理
  set @Sql='' 
  IF @sylw=1 
  Begin
    
    IF @LWYJSGZWZCheck=1 Begin
      Set @Sql='Declare cur1 Cursor Global For Select Sum(贷方金额) As LjJE From 现金银行流水账表 where (单据类型=''劳务工资单'' or 单据类型=''劳务预支单'') And 冲销=0 And CharIndex('''+@XMPathKey+''',XMPathKey)=1';
      Set @Sql=@Sql+@DateSql  
      Exec(@Sql)
      Open cur1
      Fetch Next From cur1 into @Tmpcb1 
    End

    IF @LWYJSGZWZCheck=0 Begin
      Set @Sql='Declare cur1 Cursor Global For  Select Sum(工资单价*数量) As Ljgz,Sum(承包款) As CBK from 劳务考勤明细表 Where MainID In (Select AutoID From 劳务考勤总账表 where 冲销=0 And CharIndex('''+@XMPathKey +''',XMPathKey)=1 )'
      IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And MainID In (Select AutoID From 劳务考勤总账表 where 审核否=1 )' End
      Set @Sql=@Sql+@DateSql_kaoqin 
      Exec(@Sql)
      Open cur1
      Fetch Next From cur1 into @Tmpcb1,@Tmpcb2 
    End
    
    Close cur1
    deallocate cur1 
    Set @totalcb=@totalcb+ISNULL(@tmpcb1,0)+ISNULL(@Tmpcb2 ,0)
  End 

-- 外包人工
  set @Sql=''
  IF @FBCBYiFuKuanShuCheck=0 
  Begin
    Set @Sql='Declare cur1 Cursor Global For Select Sum(金额) As Ljcb from 外包人工明细表 Where 冲销=0 And CharIndex('''+@XMPathKey +''',XMPathKey)=1'
    Set @Sql=@Sql+@DateSql
    IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And MainID In (Select AutoID From 外包人工总账表 where 审核否=1 )' End 
  End 
  IF @FBCBYiFuKuanShuCheck=1 
  Begin
    Set @Sql='Declare cur1 Cursor Global For Select Sum(金额) As Ljcb From 收付款明细表 where 冲销=0 And CharIndex('''+@XMPathKey+''',XMPathKey)=1 And 单据类型=''付款单'' And 付款单据类型=''外包人工单'' ' 
    Set @Sql=@Sql+' And MainID Not In (Select AutoID From 收付款总账表 where 冲销=0 And 收付款名称=''履约保证金'') '
    IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And MainID In (Select AutoID From 收付款总账表 where 审核否=1 )' End 
    Set @Sql=@Sql+@DateSql   
  End  
  Set @Tmpcb1=0
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @Tmpcb1 
  Close cur1
  deallocate cur1 
  Set @totalcb=@totalcb+ISNULL(@tmpcb1,0) 
 
 
-- 外包机械 
  Set @Sql='Declare cur1 Cursor Global For Select Sum(金额) As Ljcb from 外包机械明细表 Where 冲销=0 And CharIndex('''+@XMPathKey +''',XMPathKey)=1'
  IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And MainID In (Select AutoID From 外包机械总账表 where 审核否=1 )' End
  Set @Sql=@Sql+@DateSql  
  Set @Tmpcb1=0
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @Tmpcb1 
  Close cur1
  deallocate cur1 
  Set @totalcb=@totalcb+ISNULL(@tmpcb1,0) 

-- 材料租赁
  Set @Sql='Declare cur1 Cursor Global For Select Sum(金额) As Ljcb From 租赁结算明细表 where 冲销=0 And CharIndex('''+@XMPathKey +''',XMPathKey)=1' 
  Set @Sql=@Sql+@DateSql 
  IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And MainID In (Select AutoID From 租赁结算总账表 where 审核否=1 )' End
  Set @Tmpcb1=0
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @Tmpcb1 
  Close cur1
  deallocate cur1 
  Set @totalcb=@totalcb+ISNULL(@tmpcb1,0) 

-- 其它费
  Set @Sql='Declare cur1 Cursor Global For  Select  Sum(金额) As Ljcb From 其它费用明细表 where 冲销=0 ' 
  Set @Sql=@Sql+' And CharIndex('''+@XMPathKey+''',XMPathKey)=1 ' 
  Set @Sql=@Sql+@DateSql 
  IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And MainID In (Select AutoID From 其它费用总账表 where 审核否=1 )' End 
  Set @Tmpcb1=0
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @Tmpcb1 
  Close cur1
  deallocate cur1 
  Set @totalcb=@totalcb+ISNULL(@tmpcb1,0) 

  declare @OffValue bit
  declare @OffName  Varchar(100) 
  declare @OffDefault bit  
  
  Set @OffName='【项目成本】中【固定资产成本】以设备采购、调拨价值为准'
  Set @OffDefault=1
  
  exec ReadPowerSet @OffName,@OffDefault,@OffValue out
 
  IF @OffValue=1 
  Begin
    Set @Sql='Declare cur1 Cursor Global For Select Sum(库存成本变动) As Ljje From 固定设备明细表 where (单据类型=''设备采购单'' or 单据类型=''设备调拨单'' or 单据类型=''设备退货单'') And 冲销=0 '
    Set @Sql=@Sql+' And CharIndex('''+@XMPathKey+''',XMPathKey)=1 ' 
    Set @Sql=@Sql+@DateSql  
    IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And MainID In (Select AutoID From 固定设备总账表 where 审核否=1 )' End
    Exec(@Sql)
    Open cur1
    Fetch Next From cur1 into @Tmpcb1 
    Close cur1
    deallocate cur1 
    Set @totalcb=@totalcb+ISNULL(@tmpcb1,0)  
  End 
  
  IF @OffValue<>1 
  Begin
    --固定设备租赁
	Declare @GZ VarChar(50)
	Declare @MC VarChar(100)
	Declare @GG VarChar(50)
	Declare @DW VarChar(50)
	Declare @ZLDJ float 
	Declare @ZLJE float 
	Declare @LJZLTS float 
	Declare @LastEndDate DateTime
	  
	Set @Sql='Declare cur1 Cursor Global For Select 工种,名称,规格,单位 From 固定设备明细表 where 冲销=0 '
	Set @Sql=@Sql+' And CharIndex('''+@XMPathKey+''',XMPathKey)=1'  
	IF IsNULL(@EndDate,'')<>'' 
	Begin
	  Set @Sql=@Sql+' And 发生日期 <='''+cast(@EndDate as varchar(80))+'''' 
	  Set @LastEndDate=@EndDate
	End
	IF IsNULL(@EndDate,'')='' 
    Begin
	  Set @Sql=@Sql+' And 发生日期 <='''+cast(Convert( DateTime ,(Convert(Int ,GetDate()))) as varchar(80))+'''' 
      Set @LastEndDate=GetDate()        
	End
	IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And MainID In (Select AutoID From 固定设备总账表 where 审核否=1 )' End
	  
	Set @Sql=@Sql+' Group By 工种,名称,规格,单位 '
	Exec(@Sql)
	Open cur1
	Fetch Next From cur1 into @GZ,@MC,@GG,@DW
	While (@@Fetch_Status=0)
	Begin 
	  Exec CalcSheBeiZL @XMPathKey,@GZ,@MC,@GG,@DW,@StartDate,@LastEndDate,@ZLDJ out,@ZLJE out,@LJZLTS out
	  Set @totalcb=@totalcb+ISNULL(@ZLJE,0)         
      Fetch Next From cur1 into @GZ,@MC,@GG,@DW
	End
	Close cur1  
	deallocate cur1 
    
    
    --固定设备盘点
    Set @Sql='Declare cur1 Cursor Global For  Select Sum(金额) As Ljcb From 固定设备明细表 where 单据类型=''设备盘点单''  And 冲销=0 '
    Set @Sql=@Sql+' And CharIndex('''+@XMPathKey+''',XMPathKey)=1 ' 
    Set @Sql=@Sql+@DateSql  
    IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And MainID In (Select AutoID From 固定设备总账表 where 审核否=1 )' End
    Exec(@Sql)
    Open cur1
    Fetch Next From cur1 into @Tmpcb1 
    Close cur1
    deallocate cur1 
    Set @totalcb=@totalcb+ISNULL(@tmpcb1,0) 
 
   --固定设备报损
    Set @Sql='Declare cur1 Cursor Global For Select Sum(金额) As Ljcb From 固定设备明细表 where 单据类型=''设备报损单''  And 冲销=0 '
    Set @Sql=@Sql+' And CharIndex('''+@XMPathKey+''',XMPathKey)=1 ' 
    Set @Sql=@Sql+@DateSql  
    IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And MainID In (Select AutoID From 固定设备总账表 where 审核否=1 )' End
    Exec(@Sql)
    Open cur1
    Fetch Next From cur1 into @Tmpcb1 
    Close cur1
    deallocate cur1 
    Set @totalcb=@totalcb+ISNULL(@tmpcb1,0) 
  End
--运输车辆
  Set @Sql='Declare cur1 Cursor Global For  Select  Sum(金额) As Ljcb from 运输车辆明细表 Where 冲销=0 And CharIndex('''+@XMPathKey +''',XMPathKey)=1'
  Set @Sql=@Sql+@DateSql 
  IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And MainID In (Select AutoID From 运输车辆总账表 where 审核否=1 )' End
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @Tmpcb1 
  Close cur1
  deallocate cur1 
  Set @totalcb=@totalcb+ISNULL(@tmpcb1,0) 

--考勤  
  declare @Ayear Int
  declare @AMmonth Int  
  Set @Sql='Declare cur1 Cursor Global For  Select Sum(合计工*日成本) As HJ,Sum(月成本+承包款) As CBKHJ From 考勤总账表,考勤明细表 where 考勤总账表.AutoID=考勤明细表.MainID And 冲销=0 ' 
  Set @Sql=@Sql+' And CharIndex('''+@XMPathKey+''',XMPathKey)=1 '
  IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And 审核否=1 ' End
  IF IsNULL(@StartDate,'')<>''  
  Begin
    Set @Ayear=Year(@StartDate)
    Set @AMmonth=Month(@StartDate)
    Set @Sql=@Sql+' And (年份>'+cast(@Ayear as varchar(8))+' or (年份='+cast(@Ayear as varchar(8))+' And 月份>='+cast(@AMmonth as varchar(8))+'))'
  End 
  IF IsNULL(@EndDate,'')<>''  
  Begin
    Set @Ayear=Year(@EndDate)
    Set @AMmonth=Month(@EndDate)
    Set @Sql=@Sql+' And (年份<'+cast(@Ayear as varchar(8))+' or (年份='+cast(@Ayear as varchar(8))+' And 月份<='+cast(@AMmonth as varchar(8))+'))'
  End  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @Tmpcb1,@Tmpcb2
  Close cur1
  deallocate cur1 
  Set @totalcb=@totalcb+ISNULL(@tmpcb1,0)+ISNULL(@tmpcb2,0) 

--预支款成本
  Set @Sql='Declare cur1 Cursor Global For  Select Sum(预支款金额) As HJ From 员工预支单 where 冲销=0 ' 
  Set @Sql=@Sql+' And CharIndex('''+@XMPathKey+''',XMPathKey)=1 '
  IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And 审核否=1 ' End
  IF IsNULL(@StartDate,'')<>''  
  Begin
    Set @Ayear=Year(@StartDate)
    Set @AMmonth=Month(@StartDate)
    Set @Sql=@Sql+' And (年份>'+cast(@Ayear as varchar(8))+' or (年份='+cast(@Ayear as varchar(8))+' And 月份>='+cast(@AMmonth as varchar(8))+'))'
  End 
  IF IsNULL(@EndDate,'')<>''  
  Begin
    Set @Ayear=Year(@EndDate)
    Set @AMmonth=Month(@EndDate)
    Set @Sql=@Sql+' And (年份<'+cast(@Ayear as varchar(8))+' or (年份='+cast(@Ayear as varchar(8))+' And 月份<='+cast(@AMmonth as varchar(8))+'))'
  End  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @Tmpcb1 
  Close cur1
  deallocate cur1 
  Set @totalcb=@totalcb+ISNULL(@tmpcb1,0) 

--按月预支款成本
  Set @Sql='Declare cur1 Cursor Global For  Select Sum(预支款金额) As HJ From 按月预支单总账表,按月预支单明细表 where 按月预支单总账表.AutoID=按月预支单明细表.MainID And 冲销=0 '
  Set @Sql=@Sql+' And CharIndex('''+@XMPathKey+''',XMPathKey)=1 '
  IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And 审核否=1 ' End 
  IF IsNULL(@StartDate,'')<>''  
  Begin
    Set @Ayear=Year(@StartDate)
    Set @AMmonth=Month(@StartDate)
    Set @Sql=@Sql+' And (年份>'+cast(@Ayear as varchar(8))+' or (年份='+cast(@Ayear as varchar(8))+' And 月份>='+cast(@AMmonth as varchar(8))+'))'
  End 
  IF IsNULL(@EndDate,'')<>''  
  Begin
    Set @Ayear=Year(@EndDate)
    Set @AMmonth=Month(@EndDate)
    Set @Sql=@Sql+' And (年份<'+cast(@Ayear as varchar(8))+' or (年份='+cast(@Ayear as varchar(8))+' And 月份<='+cast(@AMmonth as varchar(8))+'))'
  End  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @Tmpcb1 
  Close cur1
  deallocate cur1 
  Set @totalcb=@totalcb+ISNULL(@tmpcb1,0) 

--设备维修
  Set @Sql='Declare cur1 Cursor Global For Select  Sum(金额) As Ljcb From 固定设备维修总账表 where 冲销=0  ' 
  Set @Sql=@Sql+' And CharIndex('''+@XMPathKey+''',XMPathKey)=1 '
  Set @Sql=@Sql+@DateSql 
  IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And 审核否=1 ' End
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @Tmpcb1 
  Close cur1
  deallocate cur1 
  Set @totalcb=@totalcb+ISNULL(@tmpcb1,0) 

--设备折旧  
  Set @Sql='Declare cur1 Cursor Global For Select  Sum(金额) As Ljcb From 固定设备折旧总账表 where 冲销=0  '
  Set @Sql=@Sql+' And CharIndex('''+@XMPathKey+''',XMPathKey)=1 ' 
  Set @Sql=@Sql+@DateSql  
  IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And 审核否=1 ' End
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @Tmpcb1 
  Close cur1
  deallocate cur1 
  Set @totalcb=@totalcb+ISNULL(@tmpcb1,0) 

--外包罚款 员工罚款
  IF @KCFKCheck=1 
  Begin
    Set @Sql='Declare cur1 Cursor Global For Select Sum(罚款金额) As Ljcb From 外包罚款单 where 冲销=0 And CharIndex('''+@XMPathKey+''',XMPathKey)=1 '
    Set @Sql=@Sql+@DateSql 
    IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And 审核否=1 ' End
    Exec(@Sql)
    Open cur1
    Fetch Next From cur1 into @Tmpcb1 
    Close cur1
    deallocate cur1 
    Set @totalcb=@totalcb-ISNULL(@tmpcb1,0)
    
    Set @Sql='Declare cur1 Cursor Global For Select Sum(罚款金额) As Ljcb From 员工罚款单 where 冲销=0 And CharIndex('''+@XMPathKey+''',XMPathKey)=1  And 现金支付=1 '
    Set @Sql=@Sql+@DateSql  
    IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And 审核否=1 ' End
    Exec(@Sql)
    Open cur1
    Fetch Next From cur1 into @Tmpcb1 
    Close cur1
    deallocate cur1 
    Set @totalcb=@totalcb-ISNULL(@tmpcb1,0)
  End 

  IF @KCFBHTDKGLF_SJCheck=1 
  Begin
    Set @Sql='Declare cur1 Cursor Global For Select Sum(管理费) As GLF ,Sum(税金) As SJ,Sum(其它费) As QTF From 分包合同代扣管理费税金表 where MainID In (Select AutoID From 分包合同表 where CharIndex('''+@XMPathKey+''',XMPathKey)=1 )'
    IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And 审核否=1 ' End
    Exec(@Sql)
    Open cur1
    Fetch Next From cur1 into @Tmpcb1,@Tmpcb2,@Tmpcb3 
    Close cur1
    deallocate cur1 
    Set @totalcb=@totalcb-(ISNULL(@tmpcb1,0)+ISNULL(@tmpcb2,0)+ISNULL(@tmpcb3,0)) 
  End

  Declare @JinXiang float
  Declare @LjXiaoXiangZZS float 
  
  IF @ZZSTDCBCheck=1
  Begin
    Set @Sql='Declare cur1 Cursor Global For Select Sum(Case When 业务类型=''收进发票'' then 可抵扣税额 Else 0 End) As JinXiang, Sum(Case When 业务类型=''开出发票'' then 可抵扣税额 Else 0 End) As XiaoXiang From 发票主表 where 1=1  '--发票类别=''增值税发票''
    Set @Sql=@Sql+' And AutoID In (Select MainID From 发票子表 where CharIndex('''+@XMPathKey+''',XMPathKey)=1 )' 
    IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And 审核否=1 ' End
    
    Set @Sql=@Sql+@DateSql 
    Exec(@Sql)
    Open cur1
    Fetch Next From cur1 into @JinXiang,@LjXiaoXiangZZS 
    Close cur1
    deallocate cur1 
    Set @totalcb=@totalcb+ISNULL(@LjXiaoXiangZZS,0)-ISNULL(@JinXiang,0)
  End
  

  IF @QTSRCDCBCheck=1
  Begin 
    Set @Sql='Declare cur1 Cursor Global For  Select  Sum(金额) As Ljcb From 其它收入明细表 where 冲销=0 ' 
    Set @Sql=@Sql+' And CharIndex('''+@XMPathKey+''',XMPathKey)=1 ' 
    Set @Sql=@Sql+@DateSql 
    IF @ShenHeCheck=1 Begin Set @Sql=@Sql+' And MainID In (Select AutoID From 其它收入总账表 where 审核否=1 )' End 
    Set @Tmpcb1=0
    Exec(@Sql)
    Open cur1
    Fetch Next From cur1 into @Tmpcb1 
    Close cur1
    deallocate cur1 
    Set @totalcb=@totalcb-ISNULL(@tmpcb1,0) 

  End
