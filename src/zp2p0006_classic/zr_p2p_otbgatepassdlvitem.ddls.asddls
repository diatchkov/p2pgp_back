@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: inbound delivery item root'

@ObjectModel.semanticKey: [ 'DeliveryDocumentItem' ]
@Metadata.allowExtensions: true

define view entity ZR_P2P_OTBGATEPASSDLVITEM
  as select from ZI_P2P_OTBGATEPASSDLVITEM
  association to parent ZR_P2P_OTBGATEPASSITEM as _OtbGatePassItem on  _OtbGatePassItem.GatePassID     = $projection.GatePassID
                                                                   and _OtbGatePassItem.GatePassItemID = $projection.GatePassItemID
{

  key GatePassID,
  key GatePassItemID,
  key DeliveryDocument,
  key DeliveryDocumentItem,
      MainItem,
      ReferenceSDDocument,
      ReferenceSDDocumentItem,
      Plant,
      StorageLocation,
      Material,

      @Consumption.valueHelpDefinition: [{
         entity: {
             name: 'ZC_P2P_GPC_BatchVH',
             element: 'Batch'
         },
         distinctValues: true,
         additionalBinding: [{
           element: 'Plant',
           localElement: 'Plant',
           usage: #FILTER
         }, {
           element: 'StorageLocation',
           localElement: 'StorageLocation',
           usage: #FILTER
         }, {
           element: 'Material',
           localElement: 'Material',
           usage: #FILTER
         }]         
      }]      
      Batch,
      case when MainItem is not initial then Billets else 0 end as Billets,
      
      ActualDeliveryQuantity,
      DeliveryQuantityUnit,
      
      @Semantics.quantity.unitOfMeasure: 'BatchUOM'
      cast(_BatchClass.FromDecimalValue as menge_d ) as BatchWeight,
      _BatchClass.UOM                                as BatchUOM,

      ZZCreatedTimestamp,
      ZZChangedTimestamp,

      /* Associations */
      _Item,
      _OrderItem,
      _OtbGatePass,
      _OtbGatePassItem,
      _Product,
      ZI_P2P_OTBGATEPASSDLVITEM._SalesOrderQuan


}
