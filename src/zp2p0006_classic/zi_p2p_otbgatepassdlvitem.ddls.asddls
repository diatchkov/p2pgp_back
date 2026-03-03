@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: inbound delivery item root'

@ObjectModel.semanticKey: [ 'DeliveryDocumentItem' ]
@Metadata.allowExtensions: true

define view entity ZI_P2P_OTBGATEPASSDLVITEM
  as select from ZI_P2P_GatePassDlvItem
  association        to ZR_P2P_OTBGATEPASS            as _OtbGatePass     on  _OtbGatePass.GatePassID = $projection.GatePassID
  association [0..1] to I_SalesOrderItem              as _OrderItem       on  _OrderItem.SalesOrder     = $projection.ReferenceSDDocument
                                                                          and _OrderItem.SalesOrderItem = $projection.ReferenceSDDocumentItem
  association [0..1] to I_Product                     as _Product         on  _Product.Product = $projection.Material
  association [0..1] to ZI_P2P_GPC_SO_QUAN_SUM        as _SalesOrderQuan  on  _SalesOrderQuan.SalesOrder     = $projection.ReferenceSDDocument
                                                                          and _SalesOrderQuan.SalesOrderItem = $projection.ReferenceSDDocumentItem
  association [0..1] to ZI_O2C_BatchClassification    as _BatchClass      on  _BatchClass.Plant           = $projection.Plant
                                                                          and _BatchClass.Material        = $projection.Material
                                                                          and _BatchClass.Batch           = $projection.Batch
                                                                          and _BatchClass.CharcInternalID = $projection.WeightVariable
{

  key GatePassID,
  key GatePassItemID,
  key DeliveryDocument,
  key DeliveryDocumentItem,
      _Item.HigherLvlItmOfBatSpltItm as MainItem,
      ReferenceSDDocument,
      ReferenceSDDocumentItem,

      _Item.Plant as Plant,
      _Item.StorageLocation as StorageLocation,
      _Item.Material as Material,
      _Item.Batch as Batch,
      _Item.ZZPIECECOUNT_DLI         as Billets,
      _Item.ActualDeliveryQuantity,
      _Item.DeliveryQuantityUnit,
      _Item.ZZCreatedTimestamp,
      _Item.ZZChangedTimestamp,
      WeightVariable,
      
      /* Associations */
      _Item,
      _OrderItem,
      _Product,
      _OtbGatePass,
      _SalesOrderQuan,
      _BatchClass
}
