CREATE PROCEDURE  [dbo].[CalcFP_FKSQ_YFK]  
@DYDJ varchar(20) ,
@DJLX varchar(20) ,
@FPBH varchar(500) output,
@FPJE Float output,
@YSQJE Float output,
@YFKJE Float output, 
@DKJE Float output
AS 
  declare @CurFPBH varchar(100) 
  declare @CurFPJE Float 
  declare @Sql_Str Varchar(255)
  Set @FPJE=0
  Set @FPBH='' 

  Set @Sql_Str='Declare cur1 Cursor Global  For Select Sum(对应金额) As DYJE ,发票编号 As FPBH From 发票子表 where 发票对应单据='''+@DYDJ+''' And 冲销=0 Group By 发票编号';
  Exec(@Sql_Str)
  Open cur1
  Fetch Next From cur1 into @CurFPJE,@CurFPBH
  While (@@Fetch_Status=0)
  Begin
    IF @FPBH<>''
    Begin
       Set @FPBH=@FPBH+','
    End
    Set @FPBH=@FPBH+@CurFPBH 
    Set @FPJE=@FPJE+@CurFPJE
    Fetch Next From cur1 into @CurFPJE,@CurFPBH
  End

  Close cur1
  deallocate cur1
 
  Set @Sql_Str='Declare cur2 Cursor Global For Select Sum(金额) As FKJE From 付款申请明细表 where 付款单据类型='''+@DJLX+''' And 付款对应单据='''+@DYDJ+''' And 冲销=0';
  Exec(@Sql_Str)
  Open cur2
  Fetch Next From cur2 into @YSQJE
  Close cur2
  deallocate cur2

  Set @Sql_Str='Declare cur3 Cursor Global For Select Sum(金额) As FKJE From 收付款明细表 where 付款单据类型='''+@DJLX+''' And 付款对应单据='''+@DYDJ+''' And 冲销=0';
  Exec(@Sql_Str)
  Open cur3
  Fetch Next From cur3 into @YFKJE
  Close cur3
  deallocate cur3

  Set @DKJE=0
  IF @DJLX='材料采购单' 
  Begin
    Set @Sql_Str='Declare cur4 Cursor Global For Select Sum(抵扣采购金额) As DKJE From 材料总账表 where 单据类型=''材料退货单'' And 冲销=0 And 抵扣采购单号='''+@DYDJ+'''';
    Exec(@Sql_Str)
    Open cur4
    Fetch Next From cur4 into @DKJE
    Close cur4
    deallocate cur4
  End 