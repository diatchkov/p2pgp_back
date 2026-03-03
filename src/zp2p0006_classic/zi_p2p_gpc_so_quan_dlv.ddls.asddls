@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: Sales order quantity'

define view entity ZI_P2P_GPC_SO_QUAN_DLV as 
  select from ZI_P2P_GPC_SO_QUAN
{
  key SalesOrder,
  key SalesOrderItem,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      sum( ActualDeliveredQtyInBaseUnit ) as ActualDeliveredQtyInBaseUnit,
      BaseUnit
} where GoodsMovementStatus = 'C'
  group by SalesOrder, SalesOrderItem, BaseUnit

