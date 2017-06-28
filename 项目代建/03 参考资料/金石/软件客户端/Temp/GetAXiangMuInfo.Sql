Create PROCEDURE [dbo].[GetAXiangMuInfo] 
@XMPathKey varchar(100),
@StartDate datetime,
@EndDate datetime,
@KuFangCheck bit,--包括库存成本
@HasJiaGongCai bit, --包括甲供材成本
@ShenHeCheck bit,--以审核成本为准
@FBCBYiFuKuanShuCheck bit,--分包成本以付款数为准 
@KCFKCheck bit,--扣除分包罚款和又交纳现金的员工罚款
@KCFBHTDKGLF_SJCheck bit,--扣队分包合同中的扣缴费用
@ZZSTDCBCheck bit,--增值税冲抵成本
@QTSRCDCBCheck bit,--其它收入冲减成本
@LWYJSGZWZCheck bit  --劳务成本以结算工资为准
AS 
 
  declare @FaPiaoJE float
  declare @TotalCB float  
  declare @TotalCB_BenQi float   
  
  IF OBJECT_ID('#单项目临时表') is not null  
      drop table #单项目临时表
  
 --以下主要是计算 累计发票 和累计成本
    Exec CalcChengBen3 @XMPathKey,Null,Null,@KuFangCheck ,@HasJiaGongCai, @ShenHeCheck ,@FBCBYiFuKuanShuCheck
   ,@KCFKCheck,@KCFBHTDKGLF_SJCheck,@ZZSTDCBCheck,@QTSRCDCBCheck,@LWYJSGZWZCheck,@FaPiaoJE out, @TotalCB out
   
 --以下主要是计算 本期成本
    Exec CalcChengBen3 @XMPathKey,@StartDate,@EndDate,@KuFangCheck ,@HasJiaGongCai, @ShenHeCheck ,@FBCBYiFuKuanShuCheck
   ,@KCFKCheck,@KCFBHTDKGLF_SJCheck,@ZZSTDCBCheck,@QTSRCDCBCheck,@LWYJSGZWZCheck,@FaPiaoJE out,@TotalCB_BenQi out
   
    declare @YingFuLYBZJ float
    declare @YiFuLYBZJ float
    declare @YiShouKuan float
    declare @ShuiJiJE float 
    declare @GLFJE float    
    declare @QYFZJJJE float
    declare @YingShouGCK float
    declare @HTJE float
    declare @HTJSJE float -- 决算金额
    declare @Msg Varchar(1000)
    
    declare @LiRunLv Varchar(20) --利润率
    declare @FZJJJY float        --发展基金结余
    declare @JLR float           --净利润
    declare @JLRLv Varchar(20)   --净利润率 计算 税金，管理费， 企业发展基金  这个问题当时 是上海亿佳提的
    declare @WeiShouKuan float   
    declare @LiRun float 
    declare @SYFZJJ float
    
    declare @DateSql Varchar(400) 
    declare @sqlA Varchar(800)
    declare @sqlB Varchar(800) 
    declare @sql Varchar(2000) 
 
    declare @XMAutoID Int
    declare @ZGCL float
    declare @XMMC Varchar(800) 
    declare @XMJL Varchar(100) 
    
  --以下计算项目相关数据
    Exec GetXiangMuHetJE5 @XMPathKey,'',1,Null,Null,@Msg out ,@HTJE out,@HTJSJE out ,@YingFuLYBZJ out,@YiFuLYBZJ out, @YiShouKuan out,@ShuiJiJE out,@GLFJE out,@QYFZJJJE out,@YingShouGCK out 
     
    Set @WeiShouKuan=@YingShouGCK -(@YingFuLYBZJ-@YiFuLYBZJ )-@YiShouKuan
    Set @LiRun=@YingShouGCK-@TotalCB
        
    Set @sql='Declare cur1 Cursor Global For Select Sum(金额) As Ljje From 其它费用明细表 where 名称=''发展基金使用'' And 冲销=0 And CharIndex('''+@XMPathKey+''',XMPathKey)=1 '
    Exec(@Sql)
    Open cur1
    Fetch Next From cur1 into @SYFZJJ  
    Close cur1
    deallocate cur1  
    Set @SYFZJJ=ISNULL(@SYFZJJ,0)
      
    Set @JLR=@LiRun-@ShuiJiJE-@GLFJE-@QYFZJJJE+@SYFZJJ
    
    Set @LiRunLv=''  --利润率
    Set @JLRLv=''    --净利润率
    IF @YingShouGCK<>0 
    Begin
      Set @LiRunLv=LTrim(Str(@LiRun*100/@YingShouGCK,30,2))+'%';    
      Set @JLRLv = LTrim(Str(@JLR*100/@YingShouGCK,30,2))+'%'
    End


   

    Set @FZJJJY=@QYFZJJJE-@SYFZJJ  --发展基金结余
  
    --先获取项目信息
    Set @sql='Declare cur1 Cursor Global For Select AutoID,项目名称,建筑面积,项目经理 From 项目表 where PathKey='''+@XMPathKey+''''
    Exec(@Sql)
    Open cur1
    Fetch Next From cur1 into @XMAutoID,@XMMC,@ZGCL,@XMJL
    Close cur1
    deallocate cur1 

    Set @DateSql=''
    --整理日期条件变量@DateSql
    IF IsNULL(@StartDate,'')<>'' 
    Begin
      Set @DateSql=@DateSql+' And 确认日期 >='''+cast(@StartDate as varchar(80))+'''' 
    End
    IF IsNULL(@EndDate,'')<>'' 
    Begin
      Set @DateSql=@DateSql+' And 确认日期 <='''+cast(@EndDate as varchar(80))+''''
    End
  
    --获取本期进度填报产值
    declare @TBCZ_BenQi float 
    
 
    Set @SqlA='Select 完成量,ToAutoID From 项目部位完成进度确认工程量清单表 where MainID In (Select AutoID From 项目部位完成进度确认表 where 1=1 '
    Set @SqlA=@SqlA+@DateSql 
    Set @SqlA=@SqlA+' And MainID In (Select AutoID From 项目部位分解 where MainID ='+LTrim(str(@XMAutoID))+ ') )' 
    Set @SqlB='Select 综合单价,AutoID From 项目部位工程量清单表 where MainID In (Select AutoID From 项目部位分解 where MainID='+LTrim(str(@XMAutoID))+')' ;
    Set @Sql='Select * From ('+@SqlA+') As A,('+@SqlB+') As B where A.ToAutoID=B.AutoID '
    Set @Sql='Declare cur1 Cursor Global For Select Sum(完成量*综合单价) As TBCZ From ('+LTrim(@Sql)+') As K '
 
    Exec(@Sql)
    Open cur1
    Fetch Next From cur1 into @TBCZ_BenQi  
    Close cur1
    deallocate cur1  
    Set @TBCZ_BenQi=ISNULL(@TBCZ_BenQi,0)     
    
    --获取累计进度填报产值
     declare @TBCZ float
    Set @SqlA='Select 完成量,ToAutoID From 项目部位完成进度确认工程量清单表 where MainID In (Select AutoID From 项目部位完成进度确认表 where 1=1 '
    Set @SqlA=@SqlA+' And MainID In (Select AutoID From 项目部位分解 where MainID ='+LTrim(str(@XMAutoID))+ ') )' 
    Set @SqlB='Select 综合单价,AutoID From 项目部位工程量清单表 where MainID In (Select AutoID From 项目部位分解 where MainID ='+LTrim(str(@XMAutoID))+')' 
    Set @Sql='Select * From ('+@SqlA+') As A,('+@SqlB+') As B where A.ToAutoID=B.AutoID ';
    Set @Sql='Declare cur1 Cursor Global For Select Sum(完成量*综合单价) As TBCZ From ('+@Sql+') As K ';
 
    Exec(@Sql)
    Open cur1
    Fetch Next From cur1 into @TBCZ   
    Close cur1
    deallocate cur1  
    Set @TBCZ=ISNULL(@TBCZ,0)      
     
    --获取本期预算填报产值
    declare @YSCZ float
    Set @Sql='Declare cur1 Cursor Global For Select Sum(合价) As YSCZ From 项目部位工程量清单表 where MainID In (Select AutoID From 项目部位分解 where MainID ='+LTrim(str(@XMAutoID))+')' ;
    Exec(@Sql)
    Open cur1
    Fetch Next From cur1 into @YSCZ   
    Close cur1
    deallocate cur1 
    Set @YSCZ=ISNULL(@YSCZ,0)  
    
    declare @CZWCBFB Varchar(20)  --计算产值完成百分比
    declare @CZWCBFB_BenQi Varchar(20)  --计算产值完成百分比
    Set @CZWCBFB=''
    Set @CZWCBFB_BenQi=''
    IF @YSCZ<>0 
    Begin
      Set @CZWCBFB = LTrim(Str(@TBCZ*100/@YSCZ,30,2))+'%'
      Set @CZWCBFB_BenQi = LTrim(Str(@TBCZ_BenQi*100/@YSCZ,30,2))+'%'
    End
     
    declare @YSKBFB Varchar(20)  --计算已收款百分比
    Set @YSKBFB=''
    
    IF (@HTJSJE=0) And (@HTJE<>0) 
    Begin
      Set @YSKBFB = LTrim(Str(@YiShouKuan*100/@HTJE,30,2))+'%'
    End
    
    IF @HTJSJE<>0 
    Begin
      Set @YSKBFB = LTrim(Str(@YiShouKuan*100/@HTJSJE,30,2))+'%'
    End 
      
    Create Table #单项目临时表 (AutoID Int ,项目名称 [nvarchar] (100),项目经理 [nvarchar] (100),总工程量 float ,应收工程款 float,
    应付履约保证金 float,已付履约保证金 float,已收款 float,未收款 float,本期成本 float,本期填报产值 float,累计成本 float,
    累计填报产值 float,累计预算产值 float,利润 float,利润率 [nvarchar] (20),合同金额 float,合同决算金额 float, 开出发票 float,
    管理费 float,税金 float ,发展基金 float,发展基金使用 float,发展基金结余 float,净利润 float, 净利润率 [nvarchar] (20),
    已收款百分比 [nvarchar] (20), 本期产值完成百分比 [nvarchar] (20),产值完成百分比 [nvarchar] (20),  备注 [nvarchar] (1000) )
 
    insert into #单项目临时表
    values(@XMAutoID,@XMMC,@XMJL,@ZGCL,@YingShouGCK,
    @YingFuLYBZJ,@YiFuLYBZJ, @YiShouKuan ,@WeiShouKuan ,@TotalCB_BenQi,@TBCZ_BenQi,@TotalCB,
    @TBCZ,@YSCZ,@LiRun, @LiRunLv ,@HTJE,@HTJSJE,@FaPiaoJE,
    @GLFJE,@ShuiJiJE,@QYFZJJJE,@SYFZJJ,@FZJJJY,@JLR,@JLRLv,
    @YSKBFB ,@CZWCBFB_BenQi,@CZWCBFB,@Msg)
    
 
    Select * From #单项目临时表 
  
   