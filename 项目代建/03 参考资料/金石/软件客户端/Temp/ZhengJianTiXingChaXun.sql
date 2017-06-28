Create PROCEDURE [dbo].[ZhengJianTiXingChaXun] 
@CurUser varchar(20)    
AS 
    IF OBJECT_ID('#证件提醒表') is not null  
       drop table #证件提醒表
 
    Create Table #证件提醒表 (ZJAutoID Int ,证件状态 [nvarchar] (50),提醒备注 [nvarchar] (255),证件名称 [nvarchar] (50),
    持证人姓名 [nvarchar] (30),有效时间 SmallDateTime,提醒人 [nvarchar] (100),对应单据 [nvarchar] (20),单据类型 [nvarchar] (20),DJAutoID Int)
     
   Declare @ZJMC varchar(100)
   Declare @CZRXM varchar(50)
   Declare @TXBZ varchar(1000)
   Declare @TQTXTS Int
   Declare @YXSJ SmallDateTime
   Declare @ZJAutoID Int
   Declare @Sql varchar(1000)
   Declare @Sql2 varchar(1000)
   
   Declare @DYDJ varchar(20)
   Declare @DJLX varchar(20)
   Declare @DJAutoID Int
   Declare @TXR varchar(100)
   
   Declare @ADYDJ varchar(20)
   Declare @ADJLX varchar(20)
   Declare @ADJAutoID Int
   
   Declare @YJGHRQ SmallDateTime
   Declare @JHR varchar(20)
   
   Declare @TXZT varchar(100)
   Declare @TXXX varchar(100)
   
  --  AutoID,项目名称,结算,审核,合同编号,合同名称,验收总额控制,甲方,乙方,施工开始时间,施工结束时间,合同签订日期'
  --  报送金额,合同金额,内容付款基数,付款限额,工程概况,其它约束条件,应收履约保证金,扣管理费费率,扣利润费率,扣其它费费率'
 
    Set @sql='Declare cur_ZhengJian Cursor Global For Select 证件名称,持证人姓名,提醒人,提醒备注,提前提醒天数,有效时间,AutoID From 证件表 where 1=1'
    IF @CurUser<>'' 
    Begin
      Set @sql=@sql+' And CharIndex('''+@CurUser+''',提醒人)>0 '
    End
    
    Exec(@Sql)
    Open cur_ZhengJian
    Fetch Next From cur_ZhengJian into @ZJMC,@CZRXM,@TXR,@TXBZ,@TQTXTS,@YXSJ,@ZJAutoID
    
    While (@@Fetch_Status=0)
    Begin  
      Set @TXZT=''
      Set @TXXX=''
      Set @TXBZ=IsNULL(@TXBZ,'')
      IF (@TQTXTS>0) And ( DATEDIFF(day,  getdate(),@YXSJ-@TQTXTS)<1 )
      Begin
        Set @TXZT='证件到期'
        IF @TXBZ=''
        Begin
          Set @TXBZ='1、证件到期，请检查是否需要年检'
        End
        Set @TXXX=@TXBZ
      End
        
      Set @DYDJ=''
      Set @DJLX=''
      Set @DJAutoID=-1
        
      Set @sql2='Declare cur_YeWu Cursor Global For Select Top 1 对应单据,单据类型,AutoID,预计归还日期,借还人 From 证件明细表 where 冲销=0 And 证件名称='''+@ZJMC+''' And 持证人姓名='''+@CZRXM+''' order by 发生日期 DESC'
      Exec(@Sql2)
      Open cur_YeWu
      Fetch Next From cur_YeWu into @ADYDJ,@ADJLX,@ADJAutoID,@YJGHRQ,@JHR
      IF (@@Fetch_Status=0)
      Begin
        IF (@ADJLX='证件借出单') And ( DATEDIFF(day,  getdate(),@YJGHRQ)<1 )
        Begin
          IF @TXZT<>''
          Begin
            Set @TXZT=@TXZT+'、'
          End
          IF @TXXX<>''
          Begin
            Set @TXXX=@TXXX+'。'
          End
          
          Set @TXZT=@TXZT+'未还到期'
          Set @TXXX=@TXXX+'2、借出人：'+@JHR+'，约定归还日期：'+  CONVERT(varchar(100), @YJGHRQ, 23) 
          IF  DATEDIFF(day,  getdate(),@YJGHRQ)=0 
          Begin
            Set @TXXX=@TXXX+'（今天）'
          End
          IF  DATEDIFF(day,  getdate(),@YJGHRQ)<0
          Begin
              Set @TXXX=@TXXX+'，已超：'+ LTrim(Str(DATEDIFF(day, @YJGHRQ, getdate())))+'天'
          End
       
          Set @DYDJ=@ADYDJ
          Set @DJLX=@ADJLX
          Set @DJAutoID=@ADJAutoID
        End
           
      End
 

      Close cur_YeWu
      Deallocate cur_YeWu

      -- Create Table  (AutoID Int ,证件状态 [nvarchar] (50),提醒备注 [nvarchar] (255),证件名称 [nvarchar] (50),
      -- 持证人姓名 [nvarchar] (30),原始单据 [nvarchar] (20),单据类型 [nvarchar] (20),ZJAutoID Int)
      IF (@TXZT<>'')
      Begin
        Insert into #证件提醒表 values(@ZJAutoID,@TXZT,@TXXX,@ZJMC,@CZRXM,@YXSJ,@TXR,@DYDJ,@DJLX,@DJAutoID)
      End
  
      Fetch Next From cur_ZhengJian into @ZJMC,@CZRXM,@TXR,@TXBZ,@TQTXTS,@YXSJ,@ZJAutoID

    End
    
    Close cur_ZhengJian
    deallocate cur_ZhengJian
      
    Select * from #证件提醒表