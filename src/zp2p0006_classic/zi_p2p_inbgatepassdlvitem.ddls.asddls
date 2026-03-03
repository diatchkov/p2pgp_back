@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: inbound delivery item root'

@ObjectModel.semanticKey: [ 'DeliveryDocumentItem' ]
@Metadata.allowExtensions: true

define view entity ZI_P2P_INBGATEPASSDLVITEM
  as select from ZI_P2P_GatePassDlvItem
  association        to ZR_P2P_INBGATEPASS     as _InbGatePass on  _InbGatePass.GatePassID = $projection.GatePassID
  association [0..1] to I_DeliveryDocumentItem as _Item        on  _Item.DeliveryDocument     = $projection.DeliveryDocument
                                                               and _Item.DeliveryDocumentItem = $projection.DeliveryDocumentItem
  association [0..1] to I_PurchaseOrderItem    as _OrderItem   on  _OrderItem.PurchaseOrder     = $projection.ReferenceSDDocument
                                                               and _OrderItem.PurchaseOrderItem = $projection.ReferenceSDDocumentItem
  association [0..1] to I_Product              as _Product     on  _Product.Product = $projection.material

{

  key GatePassID,
  key GatePassItemID,
  key DeliveryDocument,
  key DeliveryDocumentItem,
      ReferenceSDDocument,
      cast( right(ReferenceSDDocumentItem, 5) as numc5 ) as ReferenceSDDocumentItem,

      _Item.Material,
      _Item.Plant,
      _Item.StorageLocation,
      _Item.ZZCreatedTimestamp,
      _Item.ZZChangedTimestamp,

      /* Associations */
      _Item,
      _OrderItem,
      _Product,
      _InbGatePass
}
