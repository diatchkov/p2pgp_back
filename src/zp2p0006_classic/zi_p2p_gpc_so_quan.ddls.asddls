@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: Sales order quantity'

define view entity ZI_P2P_GPC_SO_QUAN
  as select from I_SalesOrderItem       as _SalesOrderItem
    join         I_DeliveryDocumentItem as _DeliveryItem on  _DeliveryItem.ReferenceSDDocument     = _SalesOrderItem.SalesOrder
                                                         and _DeliveryItem.ReferenceSDDocumentItem = _SalesOrderItem.SalesOrderItem
{
  key _SalesOrderItem.SalesOrder                 as SalesOrder,
  key _SalesOrderItem.SalesOrderItem             as SalesOrderItem,
      _DeliveryItem.GoodsMovementStatus          as GoodsMovementStatus,
      _DeliveryItem.ActualDeliveredQtyInBaseUnit as ActualDeliveredQtyInBaseUnit,
      _DeliveryItem.BaseUnit                     as BaseUnit
}
