@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: inbound gate pass delivery projection'

@ObjectModel.semanticKey: [ 'DeliveryDocumentItem' ]
@Metadata.allowExtensions: true

define view entity ZC_P2P_INBGATEPASSDLVITEM
  as projection on ZR_P2P_INBGATEPASSDLVITEM
{
  key GatePassID,
  key GatePassItemID,
  key DeliveryDocument,
  key DeliveryDocumentItem,

      @ObjectModel.text.element: [ 'PlantName' ]
      @UI.textArrangement: #TEXT_FIRST
      _Item.Plant,
      _Item._Plant.PlantName                     as PlantName,
  
      @ObjectModel.text.element: [ 'StorageLocationName' ]
      @UI.textArrangement: #TEXT_FIRST
      _Item.StorageLocation,
      _Item._StorageLocation.StorageLocationName as StorageLocationName,

      @ObjectModel.text.element: [ 'MaterialName' ]
      @UI.textArrangement: #TEXT_FIRST
      _Item.Material,
      _Item._Material._Text.MaterialName : localized,
      
      _Product.CountryOfOrigin, 
      
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      _OrderItem.OrderQuantity,
      
      @UI.hidden: true      
      _OrderItem.PurchaseOrderQuantityUnit as OrderQuantityUnit,
      
      @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
      _Item.ActualDeliveryQuantity,
      
      @UI.hidden: true
      _Item.DeliveryQuantityUnit,
    
      _Item.ZZCreatedTimestamp,
      _Item.ZZChangedTimestamp,

      /* Associations */
      _InbGatePassItem : redirected to parent ZC_P2P_INBGATEPASSITEM,
      _InbGatePass     : redirected to ZC_P2P_INBGATEPASS, 
      _Item
}
