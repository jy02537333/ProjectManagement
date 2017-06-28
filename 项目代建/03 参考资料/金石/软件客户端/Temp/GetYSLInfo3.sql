Create PROCEDURE  [dbo].[GetYSLInfo3]
@GZ varchar(50) ,
@CLMC varchar(200) ,
@GG varchar(150) ,
@DW varchar(50) ,
@XMMC varchar(200) ,
@BWMC varchar(100) ,
@JHDAutoID Int ,
@CGKZJ Float output,
@XMYSSL Float output,
@XMYSDJ Float output, 
@BWYSSL Float output,
@BWYSDJ Float output,
@BWXHL Float output,
@XMDHL Float output,
@XMKCL Float output,
@XMYSBL Float output,
@FoundXMCL Bit output,
@FoundBWCL Bit output,
@CanNotSaveByNoYs Bit output,
@CanNotSaveByChaoYs Bit output 
AS
BEGIN  

  declare @Sql_Str Varchar(1000)
  declare @ThisYSDID Int
  declare @ThisXMAutoID Int
  declare @ThisXMPathKey Varchar(255)

  declare @XMYSBL2 Float
  declare @JSFS Varchar(255)
  declare @HZDJID Varchar(255)
  declare @XMYSJE Float
  declare @BWYSJE Float  
  declare @LjCount Int
  
  Set @ThisYSDID=-1
  Set @ThisXMAutoID=''
  Set @ThisXMPathKey='' 
  Set @CanNotSaveByNoYs=0 
  Set @CanNotSaveByChaoYs=0 

  Set @Sql_Str='Declare cur1 Cursor Global For Select AutoID,预算单ID,计划单无预算,计划单超预算,PathKey From 项目表 where 项目名称 ='''+@XMMC+''''
  Exec(@Sql_Str)
  Open cur1 
  Fetch Next From cur1 into @ThisXMAutoID,@ThisYSDID,@CanNotSaveByNoYs,@CanNotSaveByChaoYs,@ThisXMPathKey
  Close cur1
  deallocate cur1

 

  IF @@Fetch_Status<>0 
  Begin
     Return
  End 
  --MainF.OpenCaiLiaoYuSuanContQuy(ThisYSDID,ThisADOQuery);

  Set @CGKZJ=0
  Set @XMYSSL=0
  Set @XMYSDJ=0
  Set @BWYSSL=0
  Set @BWYSDJ=0
  Set @BWXHL=0
  Set @XMDHL=0
  Set @XMKCL=0
  Set @XMYSBL=0
  Set @XMYSBL2=0
 
  IF @ThisYSDID <>-1 
  Begin

    Set @Sql_Str='Declare cur2 Cursor Global For Select 计算方式,汇总单据列表 From 材料预算总表 where AutoID='+LTrim(Str(@ThisYSDID))
    Exec(@Sql_Str)
    Open cur2 
    Fetch Next From cur2 into @JSFS,@HZDJID
    Close cur2
    deallocate cur2 

    Set @HZDJID=';'+Replace(@HZDJID,CHAR(13)+CHAR(10),';')

    IF @@Fetch_Status<>0 
    Begin
       Return
    End 

    IF @JSFS='自定义' or @JSFS='自定义+汇总' 
    Begin
      print @JSFS

      IF @JSFS='自定义' 
      Begin
        Set @Sql_Str='Declare cur3 Cursor Global For Select Count(*) As LjCount, Min(采购控制价) As CGKZJ,Sum(计划用量) As SL,Sum(计划金额) As JE  From 材料预算明细表 where MainID='+LTrim(Str(@ThisYSDID))+' And 工种='''+@GZ+''' And 材料名称='''+@CLMC+''' And 规格='''+@GG+''' And 单位='''+@DW+''''
      End
      
      IF @JSFS<>'自定义'    --'自定义+汇总' 
      Begin
        Set @HZDJID=';'+Replace(@HZDJID,CHAR(13)+CHAR(10),';')
        Set @Sql_Str='Declare cur3 Cursor Global For Select Count(*) As LjCount, Min(采购控制价) As CGKZJ,Sum(计划用量) As SL,Sum(计划金额) As JE  From 材料预算明细表 where 工种='''+@GZ+''' And 材料名称='''+@CLMC+''' And 规格='''+@GG+''' And 单位='''+@DW+''''
        Set @Sql_Str=@Sql_Str+' And ( MainID='+LTrim(Str(@ThisYSDID))+' or CharIndex('';''+LTrim(Str(MainID))+'';'','''+@HZDJID+''')>0 )' 
      End
 
      Exec(@Sql_Str)
      Open cur3 

      Fetch Next From cur3 into @LjCount,@CGKZJ,@XMYSSL,@XMYSJE
    
 
      IF @LjCount>0 
      Begin
        Set @FoundXMCL=1
      End
    
      Close cur3
      deallocate cur3

    End



    IF @CGKZJ Is NULL
    Begin
        Set @CGKZJ=0
    End

    IF @XMYSSL Is NULL
    Begin
      Set @XMYSSL=0
    End

    IF @XMYSJE Is NULL
    Begin
      Set @XMYSJE=0
    End

    IF @XMYSSL<>0
    Begin 
      Set @XMYSDJ=@XMYSJE/@XMYSSL
    End
  End 

  IF (@BWMC<>'') And (@XMMC<>'')    --检查所用部位
  Begin
    Set @Sql_Str='Declare cur5 Cursor Global For Select YSDID From 项目部位分解 where MainID='+LTrim(Str(@ThisXMAutoID)) +' And 部位名称='''+@BWMC+'''' 
    Exec(@Sql_Str)
    Open cur5
    Fetch Next From cur5 into @ThisYSDID  
 
    IF @@Fetch_Status=0 
    Begin 
      Set @Sql_Str='Declare cur6 Cursor Global For Select 计算方式,汇总单据列表 From 材料预算总表 where AutoID='+LTrim(Str(@ThisYSDID))
      Exec(@Sql_Str)
      Open cur6
      Fetch Next From cur6 into @JSFS,@HZDJID

      Set @HZDJID=';'+Replace(@HZDJID,CHAR(13)+CHAR(10),';')

      IF @JSFS='自定义' or @JSFS='自定义+汇总' 
      Begin 
        IF @JSFS='自定义' 
        Begin
          Set @Sql_Str='Declare cur7 Cursor Global For Select Sum(计划用量) As SL,Sum(计划金额) As JE  From 材料预算明细表 where MainID='+LTrim(Str(@ThisYSDID))+' And 工种='''+@GZ+''' And 材料名称='''+@CLMC+''' And 规格='''+@GG+''' And 单位='''+@DW+''''
        End
        IF @JSFS='自定义+汇总'
        Begin
          Set @HZDJID=';'+Replace(@HZDJID,CHAR(13)+CHAR(10),';')
          Set @Sql_Str='Declare cur7 Cursor Global For Select Sum(计划用量) As SL,Sum(计划金额) As JE  From 材料预算明细表 where 工种='''+@GZ+''' And 材料名称='''+@CLMC+''' And 规格='''+@GG+''' And 单位='''+@DW+''''
          Set @Sql_Str=@Sql_Str+' And ( MainID='+LTrim(Str(@ThisYSDID))+' or CharIndex('';''+LTrim(Str(MainID))+'';'','''+@HZDJID+''')>0 )' 
        End

 
        Exec(@Sql_Str)
        Open cur7
   
        Fetch Next From cur7 into @BWYSSL,@BWYSJE


        IF @BWYSSL IS NULL
        Begin
          Set @BWYSSL=0 
        End
        IF @BWYSSL<>0
        Begin 
          Set @FoundBWCL=1
          Set @BWYSDJ=@BWYSJE/@BWYSSL
        End 
      
        Close cur7
        deallocate cur7 
 
      End

      Close cur6
      deallocate cur6
 
    End 

    Close cur5
    Deallocate cur5   
  
  End 

  Set @Sql_Str='Declare cur4 Cursor Global For Select Sum(数量*库房基数) As KCL, Sum(数量*(项目基数+库房基数)) As SL From 材料明细表 where CharIndex('''+@ThisXMPathKey+''',XMPathKey)=1 And 冲销=0 And 工种='''+@GZ+''' And 名称='''+@CLMC+''' And 单位='''+@DW+''''

  IF @GG<>''
  Begin
    Set @Sql_Str=@Sql_Str+' And 规格='''+@GG+'''' 
  End

  Exec(@Sql_Str)
  Open cur4 
  Fetch Next From cur4 into @XMKCL,@XMDHL
  Close cur4
  deallocate cur4
  
  IF @XMKCL Is NULL 
  Begin  
    Set @XMKCL=0
  End

  IF @XMDHL Is NULL 
  Begin  
    Set @XMDHL=0
  End

 
  IF @BWMC<>'' 
  Begin

    Set @Sql_Str='Declare cur8 Cursor Global For Select Count(*) As LjCount, Sum(数量*项目基数) As SL from 材料明细表 where CharIndex('''+@ThisXMPathKey+''',XMPathKey)=1 And 所用部位='''+@BWMC+''' And 冲销=0 And 工种='''+@GZ+''' And 名称='''+@CLMC+''' And 单位='''+@DW+''''
    IF @GG<>'' 
    Begin
       Set @Sql_Str=@Sql_Str+' And 规格='''+@GG+'''' 
    End
 
    Exec(@Sql_Str)
    Open cur8
    Fetch Next From cur8 into @LjCount,@BWXHL
   
    Close cur8
    deallocate cur8

    IF @BWXHL Is NULL 
    Begin  
      Set @BWXHL=0
    End

  End
 

  Set @Sql_Str='Declare cur9 Cursor Global For Select Sum(上报计划量) As SBL From 材料计划明细表 where  CharIndex('''+@ThisXMPathKey+''',JHXMPathKey)=1 '
  Set @Sql_Str=@Sql_Str+' And MainID In (Select AutoID From 材料计划总账表 where 冲销=0   )'
  Set @Sql_Str=@Sql_Str+' And 工种='''+@GZ+''' And 材料名称='''+@CLMC+''' And 单位='''+@DW+''''

  IF @GG<>''
  Begin
    Set @Sql_Str=@Sql_Str+' And 规格='''+@GG+'''' 
  End

  IF @BWMC<>''
  Begin
    Set @Sql_Str=@Sql_Str+' And 所用部位='''+@BWMC+''''
  End

  IF @JHDAutoID<>-1 
  Begin
    Set @Sql_Str=@Sql_Str+' And MainID<>'+LTrim(Str(@JHDAutoID))  
  End

  Exec(@Sql_Str)
  Open cur9
  Fetch Next From cur9 into @XMYSBL
  Close cur9
  deallocate cur9

  IF @XMYSBL Is NULL 
  Begin
    Set @XMYSBL=0
  End


  Set @Sql_Str='Declare cur10 Cursor Global For Select Sum(上报计划量) As SBL From 材料计划明细表 where ( (JHXMPathKey Is NULL) or (JHXMPathKey='''') ) And MainID In (Select AutoID From 材料计划总账表 where CharIndex('''+@ThisXMPathKey+''',XMPathKey)=1 And 冲销=0) '
  Set @Sql_Str=@Sql_Str+' And 工种='''+@GZ+''' And 材料名称='''+@CLMC+''' And 单位='''+@DW+''''
  IF @GG<>'' 
     Set @Sql_Str=@Sql_Str+' And 规格='''+@GG+'''' 
 
  IF @BWMC<>'' 
     Set @Sql_Str=@Sql_Str+' And 所用部位='''+@BWMC+''''
    
  IF @JHDAutoID<>-1 
  Begin
    Set @Sql_Str=@Sql_Str+' And MainID<>'+LTrim(Str(@JHDAutoID))  
  End


  Exec(@Sql_Str)
  Open cur10
  Fetch Next From cur10 into @XMYSBL2
  Close cur10
  deallocate cur10

  IF @XMYSBL2 Is NULL 
  Begin
    Set @XMYSBL2=0
  End

  Set @XMYSBL=@XMYSBL+@XMYSBL2 

EnD
