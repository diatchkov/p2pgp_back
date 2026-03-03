@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: outbound gate pass delivery projection'

@ObjectModel.semanticKey: [ 'DeliveryDocumentItem' ]
@Metadata.allowExtensions: true

define view entity ZC_P2P_OTBGATEPASSDLVITEM
  as projection on ZR_P2P_OTBGATEPASSDLVITEM
{
  key GatePassID,
  key GatePassItemID,
  key DeliveryDocument,
  key DeliveryDocumentItem,
      MainItem, 
      
      @ObjectModel.text.element: [ 'PlantName' ]
      @UI.textArrangement: #TEXT_ONLY
      Plant,
      _Item._Plant.PlantName                     as PlantName,

      @ObjectModel.text.element: [ 'StorageLocationName' ]
      @UI.textArrangement: #TEXT_FIRST
      StorageLocation,
      _Item._StorageLocation.StorageLocationName as StorageLocationName,

      @ObjectModel.text.element: [ 'MaterialName' ]
      @UI.textArrangement: #TEXT_ONLY
      Material,
      _Item._Material._Text.MaterialName : localized,

      Batch,

      Billets,

      @Semantics.quantity.unitOfMeasure: 'BatchUOM'
      BatchWeight,
      BatchUOM,

      _Product.CountryOfOrigin,

      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      _OrderItem.OrderQuantity,

      @UI.hidden: true
      _OrderItem.OrderQuantityUnit               as OrderQuantityUnit,

      _OrderItem.OverdelivTolrtdLmtRatioInPct    as OverdelivTolrtdLmtRatioInPct,

      _OrderItem.UnderdelivTolrtdLmtRatioInPct   as UnderdelivTolrtdLmtRatioInPct,

      ActualDeliveryQuantity,
      DeliveryQuantityUnit,

      @Semantics.quantity.unitOfMeasure: 'DeliveredUnit'
      _SalesOrderQuan.DeliveredQuantity,
      _SalesOrderQuan.DeliveredUnit,
      @Semantics.quantity.unitOfMeasure: 'TruckUnit'
      _SalesOrderQuan.TruckQuantity,
      _SalesOrderQuan.TruckUnit,

      _Item.ZZItemBundle_DLI                     as Bundle,

      _Item.ZZCreatedTimestamp,
      _Item.ZZChangedTimestamp,

      /* Associations */
      _OtbGatePassItem : redirected to parent ZC_P2P_OTBGATEPASSITEM,
      _OtbGatePass     : redirected to ZC_P2P_OTBGATEPASS,
      _Item
}
