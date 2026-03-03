@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: outbound gate pass item projection'

@ObjectModel.semanticKey: [ 'DeliveryDocument' ]
@Metadata.allowExtensions: true

define view entity ZC_P2P_OTBGATEPASSITEM
  as projection on ZR_P2P_OTBGATEPASSITEM
{
  key GatePassID,
  key GatePassItemID,

      @Consumption.valueHelpDefinition: [{
         entity: {
             name: 'ZC_P2P_DeliveryDocumentVH',
             element: 'DeliveryDocument'
         },
         distinctValues: true,
          additionalBinding: [{
              localElement: '_OtbGatePass.OrderNumber',
              element: 'ReferenceSDDocument',
              usage: #FILTER
          }]
      }]
      DeliveryDocument,

      @ObjectModel.text.element: [ 'CustomerName' ]
      @UI.textArrangement: #TEXT_FIRST
      _DeliveryDocument.ShipToParty      as Customer,
      _DeliveryDocument._ShipToParty.CustomerName as CustomerName,

      _DeliveryDocument.ZZWBManual_DLH as WBManual,
      
      @Semantics.quantity.unitOfMeasure: 'WBUnit'
      _DeliveryDocument.ZZGROSS_WEIGHT as WBGrossWeight,
      
      @Semantics.quantity.unitOfMeasure: 'WBUnit'
      _DeliveryDocument.ZZTARE_WEIGHT  as WBTareWeight,
      
      @Semantics.quantity.unitOfMeasure: 'WBUnit'
      _DeliveryDocument.ZZNET_WEIGHT   as WBNetWeight,
      
      _DeliveryDocument.ZZUNIT         as WBUnit,

      CreatedByUser,
      CreationDate,
      CreationTime,
      ZZCreatedTimestamp,
      ZZChangedTimestamp,

      /* Associations */
      _DeliveryDocument,
      _OtbGatePass        : redirected to parent ZC_P2P_OTBGATEPASS,
      _OtbGatePassDlvItem : redirected to composition child ZC_P2P_OTBGATEPASSDLVITEM
}
