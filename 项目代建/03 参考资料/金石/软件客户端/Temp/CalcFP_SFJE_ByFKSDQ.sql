Create PROCEDURE  [dbo].[CalcFP_SFJE_ByFKSDQ]
@DYDJ Varchar(20) , 
@FPBH varchar(500) output,
@FPJE Float output,
@ShiFuJE Float(20) output
AS
BEGIN 
  declare @CurFPBH varchar(100) 
  declare @CurFPJE Float 
  declare @Sql_Str Varchar(255)
  Set @FPJE=0
  Set @FPBH='' 
  Set @ShiFuJE=0

  Set @Sql_Str='Declare cur1 Cursor Global For Select Sum(对应金额) As DYJE ,发票编号 As FPBH From 发票子表 where 冲销=0 And 发票对应单据 In (Select 付款对应单据 From 付款申请明细表 where 对应单据 = '''+@DYDJ +''' And 冲销=0 ) Group By 发票编号';
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
    
  Set @Sql_Str='Declare cur2 Cursor Global For Select Sum(金额) As Ljje  From 收付款明细表 where MainID In (Select AutoID From 收付款总账表 where 申请单号='''+@DYDJ+''' And 冲销=0)';
  Exec(@Sql_Str)
  Open cur2
  Fetch Next From cur2 into @ShiFuJE  
  Close cur2
  deallocate cur2
 
END
