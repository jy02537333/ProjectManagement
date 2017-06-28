Create PROCEDURE CalcNeiBuZiJinYE
  @XMPathkey Varchar(100),
  @fsrq1 datetime,
  @fsrq2 datetime,
  @nbhr Float output,
  @wlsk Float output,
  @byjjr Float output,
  @byjhh Float output,
  @grhh Float output,
  @gcjr Float output,
  @gchr Float output,
  @nbhc Float output,
  @byjjc Float output,
  @byjhc Float output,
  @grjc Float output,
  @gcjc Float output,
  @gchc Float output,
  @wlfk Float output,
  @sfyggz Float output,
  @bqjy Float output 
AS
BEGIN
  Declare @sql Varchar(1000)
  Declare @sqldate Varchar(1000) 
  Set @sqldate=''
  IF IsNULL(@fsrq1,'')<>'' 
  Begin
    Set @sqldate=@sqldate+' And 发生日期 >='''+cast(@fsrq1 as varchar(80))+''''
  End
  IF IsNULL(@fsrq2,'')<>'' 
  Begin
    Set @sqldate=@sqldate+' And 发生日期 <='''+cast(@fsrq2 as varchar(80))+''''
  End

  --内部划入 nbhr
  Set @sql='Declare cur1 Cursor Global For select sum(划入金额) from 资金划拨单明细表 where 冲销=0 And CharIndex('''+@XMPathkey+''',HRXMPathkey)>0 ' 
  Set @Sql=@Sql+@sqldate 
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @nbhr
  Close cur1
  deallocate cur1 
  Set @nbhr=ISNULL(@nbhr,0)

  --往来收款 @wlsk 
  Set @sql='Declare cur1 Cursor Global For select SUM(金额) from 收付款明细表 where 单据类型=''收款单'' And 冲销=0 And CharIndex('''+@XMPathkey+''',XMPathkey)>0 ' 
  Set @Sql=@Sql+@sqldate 
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @wlsk
  Close cur1         
  deallocate cur1 
  Set @wlsk=ISNULL(@wlsk,0)
 
  Set @byjjr=0
  Set @byjhh=0
--  --备用金借入
--  Set @sql='Declare cur1 Cursor Global For select SUM(金额) from 员工借款还款单 where 类别=''借款'' And 冲销=0 And CharIndex('''+@XMPathkey+''',BYJXMPathkey)>0  ' 
--  Set @Sql=@Sql+@sqldate 
--  Exec(@Sql)
--  Open cur1
--  Fetch Next From cur1 into @byjjr
--  Close cur1
--  deallocate cur1 
--  Set @byjjr=ISNULL(@byjjr,0) 
--
--  --备用金还回
--  Set @sql='Declare cur1 Cursor Global For select SUM(金额) from 员工借款还款单 where 类别=''还款'' And 冲销=0 And CharIndex('''+@XMPathkey+''',XMPathkey)>0  ' 
--  Set @Sql=@Sql+@sqldate 
--  Exec(@Sql)
--  Open cur1
--  Fetch Next From cur1 into @byjhh
--  Close cur1
--  deallocate cur1 
--  Set @byjhh=ISNULL(@byjhh,0) 

  --个人还回
  Set @sql='Declare cur1 Cursor Global For select SUM(金额) from 员工借款还款单 where 类别=''还款'' And 冲销=0 And CharIndex('''+@XMPathkey+''',XMPathkey)>0  ' 
  Set @Sql=@Sql+@sqldate  --+' And ((备用金项目名称 Is NULL) or (备用金项目名称='''')) '
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @grhh
  Close cur1
  deallocate cur1 
  Set @grhh=ISNULL(@grhh,0) 

  --工程借入
  Set @sql='Declare cur1 Cursor Global For select SUM(金额) from 工程借还款单 where 冲销=0 And 单据类型=''工程借款单'' And 类别=''借入'' And CharIndex('''+@XMPathkey+''',XMPathkey)>0 '
  Set @Sql=@Sql+@sqldate 
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @gcjr
  Close cur1
  deallocate cur1 
  Set @gcjr=ISNULL(@gcjr,0)


  --工程还入
  Set @sql='Declare cur1 Cursor Global For select SUM(金额) from 工程借还款单 where 冲销=0 And 单据类型=''工程还款单'' And 类别=''还入'' And CharIndex('''+@XMPathkey+''',XMPathkey)>0 '
  Set @Sql=@Sql+@sqldate 
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @gchr
  Close cur1
  deallocate cur1 
  Set @gchr=ISNULL(@gchr,0)

  --内部划出 
  Set @sql='Declare cur1 Cursor Global For select sum(划出金额) from 资金划拨单总账表 where 冲销=0 And CharIndex('''+@XMPathkey+''',HCXMPathKey)>0 '
  Set @Sql=@Sql+@sqldate 
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @nbhc
  Close cur1
  deallocate cur1 
  Set @nbhc=ISNULL(@nbhc,0)

  Set @byjjc=0
  Set @byjhc=0
--  --备用金借出
--  Set @sql='Declare cur1 Cursor Global For select SUM(金额) from 员工借款还款单 where 类别=''借款'' And 冲销=0  And CharIndex('''+@XMPathkey+''',XMPathkey)>0 ' 
--  Set @Sql=@Sql+@sqldate 
--  Exec(@Sql)
--  Open cur1
--  Fetch Next From cur1 into @byjjc
--  Close cur1
--  deallocate cur1 
--  Set @byjjc=ISNULL(@byjjc,0)
--
--  --备用金还出
--  Set @sql='Declare cur1 Cursor Global For select SUM(金额) from 员工借款还款单 where 类别=''还款'' And 冲销=0  And CharIndex('''+@XMPathkey+''',BYJXMPathkey)>0 ' 
--  Set @Sql=@Sql+@sqldate 
--  Exec(@Sql)
--  Open cur1
--  Fetch Next From cur1 into @byjhc
--  Close cur1
--  deallocate cur1 
--  Set @byjhc=ISNULL(@byjhc,0)


  --个人借出
  Set @sql='Declare cur1 Cursor Global For select SUM(金额) from 员工借款还款单 where 类别=''借款'' And 冲销=0  And CharIndex('''+@XMPathkey+''',XMPathkey)>0 ' 
  Set @Sql=@Sql+@sqldate   --' And ( (备用金项目名称 Is NULL) or (备用金项目名称='''')) '
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @grjc
  Close cur1
  deallocate cur1 
  Set @grjc=ISNULL(@grjc,0)

  --工程借出
  Set @sql='Declare cur1 Cursor Global For select SUM(金额) from 工程借还款单 where 冲销=0 And 单据类型=''工程借款单'' And 类别=''借出'' And CharIndex('''+@XMPathkey+''',XMPathkey)>0 '
  Set @Sql=@Sql+@sqldate 
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @gcjc
  Close cur1
  deallocate cur1 
  Set @gcjc=ISNULL(@gcjc,0)

  --工程还出
  Set @sql='Declare cur1 Cursor Global For select SUM(金额) from 工程借还款单 where 冲销=0 And 单据类型=''工程还款单'' And 类别=''还出'' And CharIndex('''+@XMPathkey+''',XMPathkey)>0 '
  Set @Sql=@Sql+@sqldate 
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @gchc
  Close cur1
  deallocate cur1 
  Set @gchc=ISNULL(@gchc,0)

  --往来付款  
  Set @sql='Declare cur1 Cursor Global For select SUM(贷方金额) from 现金银行流水账表 where  冲销=0 And CharIndex('''+@XMPathkey+''',XMPathkey)>0 '
  Set @sql=@sql+' And 单据类型<>''工程借款单'' And 单据类型<>''工程还款单'' And 单据类型<>''员工借款单'' And 单据类型<>''员工还款单'' And 单据类型<>''现金调拨单'' And 单据类型<>''银行调拨单'' And 单据类型<>''银行存取款单'' And 单据类型<>''按月预支单'' And 单据类型<>''员工预支单'' And 单据类型<>''工资发放单'' '
  Set @Sql=@Sql+@sqldate 
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @wlfk
  Close cur1
  deallocate cur1
  Set @wlfk=ISNULL(@wlfk,0)

  --实付员工工资  
  Set @sql='Declare cur1 Cursor Global For select SUM(贷方金额) from 现金银行流水账表 where  冲销=0 And CharIndex('''+@XMPathkey+''',XMPathkey)>0 '
  Set @sql=@sql+' And 单据类型=''按月预支单'' And 单据类型=''员工预支单'' And 单据类型=''工资发放单'' '
  Set @Sql=@Sql+@sqldate 
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @sfyggz
  Close cur1
  deallocate cur1
  Set @sfyggz=ISNULL(@sfyggz,0)

  Set @bqjy=0
  Set @bqjy=@nbhr+@wlsk+@byjhh+@byjjr+@grhh+@gcjr+@gchr-@nbhc-@byjjc-@byjhh-@grjc-@gcjc-@gchc-@wlfk-@sfyggz
END

 