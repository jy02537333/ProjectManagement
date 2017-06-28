Create PROCEDURE [dbo].[GetXiangMuHetJE5] 
@XMPathKey varchar(100),
@WhereHTBH varchar(100),
@CanCalcFaPiao bit,
@StartDate datetime,
@EndDate datetime,
@Msg Varchar(1000) output,
@LjHTJE float output,--累计合同金额
@LjHTJSJE float output,--累计合同决算金额
@YingFuLYBZJ float output,
@YiFuLYBZJ float output,
@YiShouKuan float output,
@ShuiJiJE float output,
@GLFJE float output,
@QYFZJJJE float output,
@ResultJE float output 
AS 
BEGIN
  Declare @Sql Varchar(1000)
  Declare @Sql2 Varchar(1000)
  Declare @Sql3 Varchar(1000)
  Declare @Sql4 Varchar(1000)
  Declare @Sql5 Varchar(1000)
  Declare @Sql6 Varchar(1000)
  Declare @MC Varchar(100)
  Declare @HTBH Varchar(100)
  Declare @IsQiYong bit
  Declare @je decimal(38, 2)
  Declare @HTJE Float
  Declare @HTJSJE Float    
  Declare @GLF Float
  Declare @SJ Float
  Declare @JGCJE Float
  Declare @ZJEMsg Varchar(1000)    
  Declare @LjShouKuan Float
  Declare @YSBZJ Float
  Declare @LjYiFuBZJ Float
  Declare @ShuiLv Float
  Declare @GLFShuiLv Float
  Declare @QYFZJJShuiLv Float  
  Declare @c_YiShouKuan Float
 
  --临时变量↓
  Declare @sjsd Float
  Declare @sjje Float
  Declare @jsje Float
  Declare @jssd Float 
  Declare @yssd Float
  Declare @ysje Float
  Declare @jdzfje Float
  Declare @jdsdje Float
  Declare @jdsbje Float
  Declare @jgckcgck bit
  Declare @ZBJ Float
  Declare @BXQ Int 
  Declare @JGYSRQ DateTime
 
  --临时变量↑ --Set @WhereHTBH=''--Set @CanCalcFaPiao=1 
  Set @Msg=''  
  Set @LjHTJE=0 
  Set @LjHTJSJE=0 
  Set @YingFuLYBZJ=0
  Set @YiFuLYBZJ=0
  Set @YiShouKuan=0
  Set @ShuiJiJE=0
  Set @GLFJE=0
  Set @QYFZJJJE=0
  Set @ResultJE=0 

  IF @XMPathKey='' 
  Begin 
    return 
  End

  Set @ZJEMsg=''
  Set @Sql='Declare cur1 Cursor Global For Select 合同编号,合同金额,期初已收款,审计审定,审计金额,决算审定,决算金额,'
  Set @Sql=@Sql+'预算审定,预算金额,进度支付金额,进度审定金额,进度申报金额,税率,管理费税率,企业发展基金税率,代扣管理费,'
  Set @Sql=@Sql+'代扣税金,甲供材扣除工程款,应付履约保证金,竣工验收日期,保修期,质保金 From 承包合同表 where 1=1 ' 
  Set @Sql2='Declare cur2 Cursor Global For Select 名称,启用 From 承包合同待收款计算顺序表 order by 顺序' 
  Declare @iscbhtbhzxm bit
  set @iscbhtbhzxm=0
  select @iscbhtbhzxm=启用 From 系统全局设置表 where 设置名称='承包合同应收款计算中不含子项目的承包合同' 

  Declare @kcissh bit
  Set @kcissh=0                                          
  select @kcissh=启用 From 系统全局设置表 where 设置名称='材料的所有单据只有审核后才可产生库存和用量'
   
  IF @iscbhtbhzxm=1 Begin Set @Sql=@Sql+' And XMPathKey='''+@XMPathKey+'''' End
  IF @iscbhtbhzxm=0 Begin Set @Sql=@Sql+' And CharIndex('''+@XMPathKey+''',XMPathKey)=1 ' End
  IF @WhereHTBH<>'' Begin Set @Sql=@Sql+' And 合同编号='''+@WhereHTBH+''' ' End

  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @HTBH,@HTJE,@c_YiShouKuan,@sjsd,@sjje,@jssd,@jsje,@yssd,@ysje,@jdzfje,@jdsdje,@jdsbje,
  @ShuiLv,@GLFShuiLv,@QYFZJJShuiLv,@GLF,@SJ,@jgckcgck,@YSBZJ,@JGYSRQ,@BXQ,@ZBJ
  
  While (@@Fetch_Status=0)
  Begin
    Set @je=0     
    Set @HTJSJE=0 
    Set @HTJE=ISNULL(@HTJE,0)  
    Set @c_YiShouKuan=ISNULL(@c_YiShouKuan,0) 
    Set @sjsd=ISNULL(@sjsd,0) 
    Set @sjje=ISNULL(@sjje,0) 
    Set @jssd=ISNULL(@jssd,0) 
    Set @jsje=ISNULL(@jsje,0) 
    Set @yssd=ISNULL(@yssd,0) 
    Set @ysje=ISNULL(@ysje,0) 
    Set @jdzfje=ISNULL(@jdzfje,0) 
    Set @jdsdje=ISNULL(@jdsdje,0) 
    Set @jdsbje=ISNULL(@jdsbje,0)  
    Set @ShuiLv=ISNULL(@ShuiLv,0)  
    Set @GLFShuiLv=ISNULL(@GLFShuiLv,0) 
    Set @QYFZJJShuiLv=ISNULL(@QYFZJJShuiLv,0) 
    Set @GLF=ISNULL(@GLF,0) 
    Set @SJ=ISNULL(@SJ,0) 
    Set @jgckcgck=ISNULL(@jgckcgck,0) 
    Set @YSBZJ=ISNULL(@YSBZJ,0)  

    Set @YiShouKuan=@YiShouKuan+@c_YiShouKuan
    IF @ZJEMsg<>'' Begin Set @ZJEMsg=@ZJEMsg+'+' End
    Set @ZJEMsg=@ZJEMsg+'('
    Exec(@Sql2)
    Open cur2 --这个是合同计算顺序
    Fetch Next From cur2 into @MC,@IsQiYong 
    While (@@Fetch_Status=0)
    Begin 
      IF @IsQiYong=1 
      Begin
        IF (@MC='发票金额') And @CanCalcFaPiao=1 
        Begin
          Set @Sql3='Declare cur3 Cursor Global For Select Sum(对应金额) As FPJE From 发票子表 where 对应单据类型=''承包合同'' And 冲销=0 And 发票对应单据='''+@HTBH+''' '
          Exec(@Sql3)
          Open cur3   
          Fetch Next From cur3 into @JE 
          Close cur3
          deallocate cur3

          Set @JE=ISNULL(@JE,0) 
          IF @JE>0  
          Begin
            Set @Msg=@Msg+'  在承包合同['+@HTBH+']中，有发票金额：'+ LTrim(Str(@JE,30,2))
            Set @ZJEMsg=@ZJEMsg+LTrim(Str(@JE,30,2))
            Break
          End
		End--end IF (@MC='发票金额') And @CanCalcFaPiao=1 


        IF (@MC='进度填报产值') 
        Begin
          Set @Sql3='Select 项目部位完成进度确认工程量清单表.MainID,完成量,综合单价 From 项目部位工程量清单表,项目部位完成进度确认工程量清单表 where 项目部位工程量清单表.AutoID = 项目部位完成进度确认工程量清单表.ToAutoID ' ;
          Set @Sql3='Declare cur3 Cursor Global For Select Sum(完成量*综合单价) As LJWCL From ('+@Sql3+') As K Where K.MainID In ( Select AutoID From 项目部位完成进度确认表 Where 对应合同编号='''+@HTBH+''' )';

          Exec(@Sql3)
          Open cur3   
          Fetch Next From cur3 into @JE 
          Close cur3
          deallocate cur3

          Set @JE=ISNULL(@JE,0) 
          IF @JE>0  
          Begin
            Set @Msg=@Msg+'  在承包合同['+@HTBH+']中，进度填报产值：'+ LTrim(Str(@JE,30,2))
            Set @ZJEMsg=@ZJEMsg+LTrim(Str(@JE,30,2))
            Break
          End
 
        End 


 
        IF (@MC='审计审定') And (@sjsd<>0) 
        Begin
           Set @HTJSJE=@sjsd
           Set @JE=@sjsd
           Set @Msg=@Msg+'  在承包合同['+@HTBH+']中，有审计审定金额：'+LTrim(Str(@JE,30,2))
           Set @ZJEMsg=@ZJEMsg+LTrim(Str(@JE,30,2))
           Break
        End 

        IF (@MC='审计金额') And (@sjje<>0)
        Begin
           Set @HTJSJE=@sjje
           Set @JE=@sjje
           Set @Msg=@Msg+'  在承包合同['+@HTBH+']中，有审计金额：'+LTrim(Str(@JE,30,2))
           Set @ZJEMsg=@ZJEMsg+LTrim(Str(@JE,30,2))
           Break
        End
    
        IF (@MC='决算审定') And (@jssd<>0)
        Begin
           Set @HTJSJE=@jssd
           Set @JE=@jssd
           Set @Msg=@Msg+'  在承包合同['+@HTBH+']中，有决算审定金额：'+LTrim(Str(@JE,30,2))
           Set @ZJEMsg=@ZJEMsg+LTrim(Str(@JE,30,2))
           Break
        End

        IF (@MC='决算金额') And (@jsje<>0)
        Begin
           Set @HTJSJE=@jsje
           Set @JE=@jsje
           Set @Msg=@Msg+'  在承包合同['+@HTBH+']中，有决算金额：'+LTrim(Str(@JE,30,2))
           Set @ZJEMsg=@ZJEMsg+LTrim(Str(@JE,30,2))
           Break
        End

        IF (@MC='预算审定') And (@yssd<>0)
        Begin
           Set @JE=@yssd
           Set @Msg=@Msg+'  在承包合同['+@HTBH+']中，有预算审定金额：'+LTrim(Str(@JE,30,2))
           Set @ZJEMsg=@ZJEMsg+LTrim(Str(@JE,30,2)) 
           Break
        End

        IF (@MC='预算金额') And (@ysje<>0)
        Begin
           Set @JE=@ysje
           Set @Msg=@Msg+'  在承包合同['+@HTBH+']中，有预算金额：'+LTrim(Str(@JE,30,2))
           Set @ZJEMsg=@ZJEMsg+LTrim(Str(@JE,30,2))
           Break
        End 

        IF (@MC='进度支付金额') And (@jdzfje<>0)
        Begin
           Set @JE=@jdzfje
           Set @Msg=@Msg+'  在承包合同['+@HTBH+']中，有进度支付金额：'+LTrim(Str(@JE,30,2)) 
           Set @ZJEMsg=@ZJEMsg+LTrim(Str(@JE,30,2))
           Break
        End

        IF (@MC='进度审定金额') And (@jdsdje<>0)
        Begin
           Set @JE=@jdsdje
           Set @Msg=@Msg+'  在承包合同['+@HTBH+']中，有进度审定金额：'+LTrim(Str(@JE,30,2))
           Set @ZJEMsg=@ZJEMsg+LTrim(Str(@JE,30,2))
           Break
        End

        IF (@MC='进度申报金额') And (@jdsbje<>0)
        Begin
           Set @JE=@jdsbje
           Set @Msg=@Msg+'  在承包合同['+@HTBH+']中，有进度申报金额：'+LTrim(Str(@JE,30,2)) 
           Set @ZJEMsg=@ZJEMsg+LTrim(Str(@JE,30,2))
           Break
        End
  
        IF (@MC='合同金额') And (@HTJE<>0)
        Begin
           Set @JE=@HTJE
           Set @Msg=@Msg+'  在承包合同['+@HTBH+']中，有合同金额：'+LTrim(Str(@JE,30,2))
           Set @ZJEMsg=@ZJEMsg+LTrim(Str(@JE,30,2))      
           Break
        End 
      End--end If @IsQiYong 

      Fetch Next From cur2 into @MC,@IsQiYong  
    End
    Close cur2
    deallocate cur2 
     
 
    Set @ShuiJiJE=@ShuiJiJE+@JE*@ShuiLv/100
    Set @GLFJE=@GLFJE+@JE*@GLFShuiLv/100
    Set @QYFZJJJE=@QYFZJJJE+@JE*@QYFZJJShuiLv/100

    Set @GLF=ISNULL(@GLF,0) 
    IF @GLF<>0  
    Begin
       Set @Msg=@Msg+'，代扣管理费：'+LTrim(Str(@GLF,30,2))
       Set @ZJEMsg=@ZJEMsg+'-'+LTrim(Str(@GLF,30,2))
       Set @JE=@JE-@GLF
    End 
     
    Set @SJ=ISNULL(@SJ,0) 
    IF @SJ<>0
    Begin
       Set @Msg=@Msg+'，代扣税金：'+LTrim(Str(@SJ,30,2)) 
       Set @ZJEMsg=@ZJEMsg+'-'+LTrim(Str(@SJ,30,2))
       Set @JE=@JE-@SJ
    End
    
    IF @jgckcgck=1
    Begin
      Set @JGCJE=0
      Set @Sql4='Declare cur4 Cursor Global For Select Sum(金额*(库房基数+项目基数)) As Ljje From 材料明细表 where 冲销=0 And (单据类型=''材料甲供单'' or 单据类型=''甲供退货单'') And 合同编号='''+@HTBH+''''
      IF @kcissh=1 Begin Set @Sql4=@Sql4+' And 审核否=1 '  End  
      Exec(@Sql4)
      Open cur4   
      Fetch Next From cur4 into @JGCJE  
      Close cur4
      deallocate cur4

      Set @JGCJE=ISNULL(@JGCJE,0) 
      IF @JGCJE<>0  
      Begin
         Set @Msg=@Msg+'，扣甲供材：'+LTrim(Str(@JGCJE,30,2))
         Set @ZJEMsg=@ZJEMsg+'-'+LTrim(Str(@JGCJE,30,2))
         Set @JE=@JE-@JGCJE
      End 
    End
    
    Set @ResultJE=@ResultJE+@JE  
    Set @LjHTJE=@LjHTJE+@HTJE  
    Set @LjHTJSJE=@LjHTJSJE+@HTJSJE  
 
    IF @YSBZJ<>0  
    Begin
      Set @Msg=@Msg+'，应付履约保证金：'+LTrim(Str(@YSBZJ,30,2))
      Set @ZJEMsg=@ZJEMsg+'-'+LTrim(Str(@YSBZJ,30,2))
      Set @YingFuLYBZJ=@YingFuLYBZJ+@YSBZJ
    End    
  
    Set @Sql5='Declare cur5 Cursor Global For Select Sum(金额) As Ljje From 收付款总账表 where 合同编号='''+@HTBH+''' And 冲销=0 And 单据类型=''付款单'' And 执行合同=''承包合同'' And 收付款名称=''履约保证金'''
    Exec(@Sql5)
    Open cur5   
    Fetch Next From cur5 into @LjYiFuBZJ  
    Close cur5
    deallocate cur5

    Set @LjYiFuBZJ=ISNULL(@LjYiFuBZJ,0) 
    IF @LjYiFuBZJ<>0  
    Begin
      Set @Msg=@Msg+'，已付履约保证金：'+LTrim(Str(@LjYiFuBZJ,30,2))
      Set @ZJEMsg=@ZJEMsg+'+'+LTrim(Str(@LjYiFuBZJ,30,2))
      Set @YiFuLYBZJ=@YiFuLYBZJ+@LjYiFuBZJ 
    End 
   

    Set @Sql6='Declare cur6 Cursor Global For Select Sum(金额) As Ljje From 收付款总账表 where 合同编号='''+@HTBH+''' And 冲销=0 And 单据类型=''收款单'' And 执行合同=''承包合同'' '
    IF IsNULL(@StartDate,'')<>'' 
    Begin
      Set @Sql6=@Sql6+' And 发生日期 >='''+cast(@StartDate as varchar(80))+'''' 
    End
    IF IsNULL(@EndDate,'')<>'' 
    Begin
      Set @Sql6=@Sql6+' And 发生日期 <='''+cast(@EndDate as varchar(80))+'''' 
    End 
    Exec(@Sql6)
    Open cur6   
    Fetch Next From cur6 into @LjShouKuan  
    Close cur6  
    deallocate cur6

    Set @LjShouKuan=ISNULL(@LjShouKuan,0) 
    IF @LjShouKuan<>0  
    Begin  
      Set @Msg=@Msg+'，已收工程款：'+LTrim(Str(@LjShouKuan,30,2))
      Set @ZJEMsg=@ZJEMsg+'-'+LTrim(Str(@LjShouKuan,30,2))
      Set @YiShouKuan=@YiShouKuan+@LjShouKuan 
    End  
   
    Set @ZJEMsg=@ZJEMsg+')' 
    
    
  
  IF (Year(@JGYSRQ)>1990) And (@ZBJ<>0)  
  Begin 
    IF GetDate()<@JGYSRQ+@BXQ 
       Set @ResultJE=@ResultJE-@ZBJ
  End

  Fetch Next From cur1 into @HTBH,@HTJE,@c_YiShouKuan,@sjsd,@sjje,@jssd,@jsje,@yssd,@ysje,@jdzfje,@jdsdje,@jdsbje,
  @ShuiLv,@GLFShuiLv,@QYFZJJShuiLv,@GLF,@SJ,@jgckcgck,@YSBZJ,@JGYSRQ,@BXQ,@ZBJ
  
  End-- 第一循环
  Close cur1
  deallocate cur1 

  IF @ZJEMsg<>'' 
  Begin
    Set @Msg=@Msg+'  待收工程款合计='+ @ZJEMsg +'='+LTrim(Str(@ResultJE-@YingFuLYBZJ+@YiFuLYBZJ-@YiShouKuan,30,2))
  End
END
