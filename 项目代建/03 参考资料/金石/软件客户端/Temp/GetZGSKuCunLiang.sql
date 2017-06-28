Create function [dbo].[GetZGSKuCunLiang](@GZ varchar(30) ,@MC varchar(100),@DW varchar(50),@GG varchar(50),@PP varchar(50))
Returns Float
As
Begin
  Declare @KCL Float
  IF @GZ<>'' And @PP<>'' 
  Begin
    Declare cur1 Cursor For (Select Sum(数量*库房基数) As Ljsl From 材料明细表 where 冲销=0 And 工种=@GZ And 名称=@MC And 单位=@DW And 规格=@GG And 品牌=@PP And MainID In (Select AutoID From 材料总账表 where 冲销=0 And IsCK=1)  )
  End Else IF @GZ<>'' 
  Begin
    Declare cur1 Cursor For (Select Sum(数量*库房基数) As Ljsl From 材料明细表 where 冲销=0 And 工种=@GZ And 名称=@MC And 单位=@DW And 规格=@GG And MainID In (Select AutoID From 材料总账表 where 冲销=0 And IsCK=1)  )
  End Else IF @PP<>''
  Begin
    Declare cur1 Cursor For (Select Sum(数量*库房基数) As Ljsl From 材料明细表 where 冲销=0 And 工种=@GZ And 名称=@MC And 单位=@DW And 品牌=@PP And MainID In (Select AutoID From 材料总账表 where 冲销=0 And IsCK=1)  )
  End Else
  Begin
    Declare cur1 Cursor For (Select Sum(数量*库房基数) As Ljsl From 材料明细表 where 冲销=0 And 工种=@GZ And 名称=@MC And 单位=@DW And MainID In (Select AutoID From 材料总账表 where 冲销=0 And IsCK=1)  )
  End
  
  Open cur1
  Fetch Next From cur1 into @KCL
 
  Return ISNULL(@KCL,0) 
 
End