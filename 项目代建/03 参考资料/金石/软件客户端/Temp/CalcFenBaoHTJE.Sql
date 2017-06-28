Create PROCEDURE [dbo].[CalcFenBaoHTJE]
@htbh Varchar(100),
@zxfssj1 datetime,
@zxfssj2 datetime,
@zxtxsj1 datetime,
@zxtxsj2 datetime,
@fkfssj1 datetime,
@fkfssj2 datetime,
@fktxsj1 datetime,
@fktxsj2 datetime,
@fpje Float output,
@zxje Float output,
@fkje Float output,
@FaKuanje Float output,  
@ShiShouLYBZJ Float output 
As
BEGIN
  Declare @sql Varchar(1000)
  Declare @ZXDateSql Varchar(1000)
  Declare @FKDateSql Varchar(1000)
  Set @ZXDateSql=''
  Set @FKDateSql=''
  IF IsNULL(@zxfssj1,'')<>'' 
  Begin
    Set @ZXDateSql=@ZXDateSql+' And 发生日期 >='+@zxfssj1  
  End
  IF IsNULL(@zxfssj2,'')<>'' 
  Begin
    Set @ZXDateSql=@ZXDateSql+' And 发生日期 <='+@zxfssj2 
  End
  IF IsNULL(@zxtxsj1,'')<>'' 
  Begin  
    Set @ZXDateSql=@ZXDateSql+' And 填写日期 >='+@zxtxsj1  
  End
  IF IsNULL(@zxtxsj2,'')<>'' 
  Begin
    Set @ZXDateSql=@ZXDateSql+' And 填写日期 <='+@zxtxsj2 
  End

  IF IsNULL(@fkfssj1,'')<>'' 
  Begin
    Set @FKDateSql=@FKDateSql+' And 发生日期 >='+@fkfssj1  
  End
  IF IsNULL(@fkfssj2,'')<>'' 
  Begin
    Set @FKDateSql=@FKDateSql+' And 发生日期 <='+@fkfssj2 
  End
  IF IsNULL(@fktxsj1,'')<>'' 
  Begin
    Set @FKDateSql=@FKDateSql+' And 填写日期 >='+@fktxsj1  
  End
  IF IsNULL(@fktxsj2,'')<>'' 
  Begin
    Set @FKDateSql=@FKDateSql+' And 填写日期 <='+@fktxsj2
  End  


  Set @sql='Declare cur1 Cursor Global For Select Sum(对应金额) As FPJE From 发票子表 where 冲销=0 And   '
  Set @sql=@sql+'  (对应单据类型=''外包人工单'' And Exists (Select 对应单据 From 外包人工总账表 where 外包人工总账表.对应单据=发票子表.发票对应单据 And 冲销=0 And 合同编号='''+@htbh+''' ) )'
 
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @fpje
  Close cur1
  deallocate cur1 
  Set @fpje=ISNULL(@fpje ,0)
 
  Set @Sql='Declare cur1 Cursor Global For Select Sum(金额 ) As LjJE From 外包人工明细表 where 合同编号='''+@HTBH+''' And 冲销=0  '
  Set @Sql=@Sql+@ZXDateSql
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @zxje
  Close cur1
  deallocate cur1 
  Set @zxje=ISNULL(@zxje ,0) 

  Set @Sql='Declare cur1 Cursor Global For Select Sum( 金额 ) As LjJE From 收付款总账表 where 合同编号='''+@HTBH+''' And 冲销=0 And  执行合同=''分包合同'' ' 
  Set @Sql=@Sql+@FKDateSql 
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @fkje
  Close cur1
  deallocate cur1 
  Set @fkje=ISNULL(@fkje ,0)  
 
  Set @Sql='Declare cur1 Cursor Global For Select Sum(罚款金额) As LjJE From 外包罚款单 where 合同编号='''+@HTBH+''' And 冲销=0 ' 
  Set @Sql=@Sql+@ZXDateSql
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @FaKuanje
  Close cur1
  deallocate cur1 
  Set @FaKuanje=ISNULL(@FaKuanje ,0)   

  Set @Sql='Declare cur1 Cursor Global For Select Sum( Case When 单据类型=''收款单'' then 金额 Else -金额 End ) As LjJE From 收付款总账表 where 合同编号='''+@HTBH+''' And 冲销=0 And  执行合同=''分包合同''  And 收付款名称=''履约保证金'' ' 
  Set @Sql=@Sql+@FKDateSql 
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @ShiShouLYBZJ
  Close cur1
  deallocate cur1 
  Set @ShiShouLYBZJ=ISNULL(@ShiShouLYBZJ ,0)  


END   
