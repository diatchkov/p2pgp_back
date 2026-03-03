@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: Sales order quantity'

define view entity ZI_P2P_GPC_SO_QUAN_SUM
  as select from    I_SalesOrderItem
    left outer join ZI_P2P_GPC_SO_QUAN_DLV as _Delivered on  _Delivered.SalesOrder     = I_SalesOrderItem.SalesOrder
                                                         and _Delivered.SalesOrderItem = I_SalesOrderItem.SalesOrderItem
    left outer join ZI_P2P_GPC_SO_QUAN_TRK as _Truck     on  _Truck.SalesOrder         = I_SalesOrderItem.SalesOrder
                                                         and _Truck.SalesOrderItem     = I_SalesOrderItem.SalesOrderItem
{
  key I_SalesOrderItem.SalesOrder             as SalesOrder,
      I_SalesOrderItem.SalesOrderItem         as SalesOrderItem,
      _Delivered.ActualDeliveredQtyInBaseUnit as DeliveredQuantity,
      _Delivered.BaseUnit                     as DeliveredUnit,
      _Truck.ActualDeliveredQtyInBaseUnit     as TruckQuantity,
      _Truck.BaseUnit                         as TruckUnit
}
