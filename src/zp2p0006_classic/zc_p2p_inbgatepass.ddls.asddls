@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: inbound gate pass projection'

@ObjectModel.semanticKey: [ 'GatePassID' ]
@Metadata.allowExtensions: true

define root view entity ZC_P2P_INBGATEPASS
  provider contract transactional_query
  as projection on ZR_P2P_INBGATEPASS
  association [0..1] to ZI_UserContactCard as _EntryUserContactCard         on $projection.EntryUser = _EntryUserContactCard.ContactCardID
  association [0..1] to ZI_UserContactCard as _ExitUserContactCard          on $projection.ExitUser = _ExitUserContactCard.ContactCardID
  association [0..1] to ZI_UserContactCard as _WBGrossWeightUserContactCard on $projection.WBGrossWeightUser = _WBGrossWeightUserContactCard.ContactCardID
  association [0..1] to ZI_UserContactCard as _WBTareWeightUserContactCard  on $projection.WBTareWeightUser = _WBTareWeightUserContactCard.ContactCardID
{
  key GatePassID,
            
      @Consumption.valueHelpDefinition: [{
         entity: {
             name: 'ZC_P2P_INB_Shipment_TypeVH',
             element: 'ShipmentType'
         },
         distinctValues: true
      }]

      @ObjectModel.text.element: [ 'ShipmentTypeText' ]
      @UI.textArrangement: #TEXT_FIRST
      GatePassType,
      _ShipmentType.ShipmentTypeText       as ShipmentTypeText,

      GatePassDirection,

      @UI.textArrangement: #TEXT_FIRST 
      @ObjectModel.text.element: [ 'ProcessingIndicatorText' ]  
      ProcessingIndicator,
      _ProcessingIndicator._Text.SpecialProcessingCodeName as ProcessingIndicatorText : localized,
        
      @ObjectModel.text.element: [ 'TranspPlanPointText' ]
      @UI.textArrangement: #TEXT_FIRST
      TranspPlanPoint,
      _TranspPlanPoint.TranspPlanPointText as TranspPlanPointText,

      @Consumption.valueHelpDefinition: [{
         entity: {
             name: 'ZC_P2P_INB_BOLVH',
             element: 'BillOfLanding'
         },
         distinctValues: true
      }]
      BillOfLanding,

      @Consumption.valueHelpDefinition: [{
         entity: {
             name: 'ZC_P2P_GPC_PURCHASEORDERITEMVH',
             element: 'PurchaseOrder'
         },
         distinctValues: true,
         useForValidation: true,
         additionalBinding: [{
           element: 'PurchaseOrderItem',
           localElement: 'OrderNumberItem',
           usage: #RESULT
         }, {
           element: 'TranspPlanPoint',
           localElement: 'TranspPlanPoint',
           usage: #FILTER
         }, {
           element: 'isScrap',
           localElement: 'isScrap',
           usage: #FILTER
         }]         
      }]
      OrderNumber,

      @Consumption.valueHelpDefinition: [{
         entity: {
             name: 'ZC_P2P_GPC_PURCHASEORDERITEMVH',
             element: 'PurchaseOrderItem'
         },
         distinctValues: true,
         useForValidation: true,
         additionalBinding: [ {
           element: 'PurchaseOrder',
           localElement: 'OrderNumber',
           usage: #FILTER
         }, { 
           element: 'TranspPlanPoint',
           localElement: 'TranspPlanPoint',
           usage: #FILTER
         }, {
           element: 'isScrap',
           localElement: 'isScrap',
           usage: #FILTER
         }]         
      }]

      @ObjectModel.text.element: [ 'MaterialName' ]
      @UI.textArrangement: #TEXT_FIRST
      OrderNumberItem,
      _PurchaseOrderItem.MaterialName as MaterialName,

      RFID,
      RadiationCertificate,
      SealNumber,

      @ObjectModel.text.element: [ 'TransporterText' ]
      @UI.textArrangement: #TEXT_FIRST
      Transporter,
      _Transporter.SupplierFullName        as TransporterText,

      ContainerID,

      @ObjectModel.text.element: [ 'PlantName' ]
      @UI.textArrangement: #TEXT_FIRST
      Plant,
      _Plant.PlantName as PlantName,
      
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_StorageLocationStdVH',
              element: 'StorageLocation'
          },
          distinctValues: true,
          useForValidation: true,
          additionalBinding: [{
            element: 'Plant',
            localElement: 'Plant',
            usage: #FILTER
          }]
      }]
      @ObjectModel.text.element: [ 'StorageLocationName' ]
      @UI.textArrangement: #TEXT_FIRST      
      StorageLocation,
      _StorageLocation.StorageLocationName as StorageLocationName,
      
      TruckGUID,
      TruckID,

      @ObjectModel.text.element: [ 'TruckTypeText' ]
      @UI.textArrangement: #TEXT_FIRST
      TruckType,
      _TruckType.TypeText                  as TruckTypeText,

      TruckInsuranceNumber,
      TruckInsuranceDate,
      TruckCapacity,
      TruckCapacityUnit,

      DriverGUID,
      DriverName,
      DriverPhone,
      DriverLicense,
      WBNotRelevant,
      WBSafetyCheck,
      WBManual,

      @UI.textArrangement: #TEXT_FIRST
      @ObjectModel.text.element: [ 'WBManualReasonText' ]
      WBManualReason,
      _WBManualReason.WBManualReasonText   as WBManualReasonText,

      WBNotes,
      WBDeviceID,

      WBGrossWeight,
      _WBCapture.WBGrossWeightDate         as WBGrossWeightDate,
      _WBCapture.WBGrossWeightTime         as WBGrossWeightTime,
      _WBCapture.WBGrossWeightUser         as WBGrossWeightUser,
      WBTareWeight,
      _WBCapture.WBTareWeightDate          as WBTareWeightDate,
      _WBCapture.WBTareWeightTime          as WBTareWeightTime,
      _WBCapture.WBTareWeightUser          as WBTareWeightUser,
      WBNetWeight,
      WBUnit,
      EntryDate,
      EntryTime,
      EntryUser,
      EntryReason,
      ExitDate,
      ExitTime,
      ExitUser,
      isBulk,
      isScrap,
      isReturn,
      isLogicallyDeleted,
      ShipmentStatus, 
      
      @ObjectModel.text.element: [ 'StatusText' ]  
      Status, 
      _Status.StatusText as StatusText, 
      _Status.StatusCriticality as StatusCriticality,

      CostRelevant,
      CostCalcStatus,
            
      @Semantics.largeObject: { 
        mimeType: 'RadiationCertificateType',
        fileName: 'RadiationCertificateFile',
        contentDispositionPreference: #INLINE }      
      RadiationCertificateBody,
      RadiationCertificateFile,
      @Semantics.mimeType: true
      RadiationCertificateType,      
      ContainerWeight, 
      ContainerUnit,   
      Pieces,   
      ZZCreatedTimestamp,
      ZZChangedTimestamp,

      /* Associations */
      _Item   : redirected to composition child ZC_P2P_INBGATEPASSITEM,
      _PO     : redirected to composition child ZC_P2P_GPC_PO,
      
      _Status, 
      _ShipmentType,
      _TranspPlanPoint,
      _Transporter,
      _TruckType,
      _EntryUserContactCard,
      _ExitUserContactCard,
      _WBGrossWeightUserContactCard,
      _WBTareWeightUserContactCard,
      _WBCapture,
      _WBManualReason,
      _Plant,
      _PurchaseOrderItem, 
      _StorageLocation,
      _ProcessingIndicator
}
