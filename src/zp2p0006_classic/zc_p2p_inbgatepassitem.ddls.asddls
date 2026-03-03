@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: inbound gate pass item projection'

@ObjectModel.semanticKey: [ 'DeliveryDocument' ]
@Metadata.allowExtensions: true

define view entity ZC_P2P_INBGATEPASSITEM
  as projection on ZR_P2P_INBGATEPASSITEM
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
              localElement: '_InbGatePass.OrderNumber',
              element: 'ReferenceSDDocument',
              usage: #FILTER
          }]
      }]
      DeliveryDocument,
  
      @ObjectModel.text.element: [ 'SupplierName' ]
      @UI.textArrangement: #TEXT_FIRST
      _DeliveryDocument.Supplier       as Supplier,
      _DeliveryDocument._Supplier.SupplierName as SupplierName, 
      
      _DeliveryDocument.DeliveryDocumentBySupplier as SupplierInvoice, 

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
      _InbGatePass          : redirected to parent ZC_P2P_INBGATEPASS,
      _InbGatePassDlvItem   : redirected to composition child ZC_P2P_INBGATEPASSDLVITEM
}
