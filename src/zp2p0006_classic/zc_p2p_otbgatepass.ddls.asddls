@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: outbound gate pass projection'

@ObjectModel.semanticKey: [ 'GatePassID' ]
@Metadata.allowExtensions: true

define root view entity ZC_P2P_OTBGATEPASS
  provider contract transactional_query
  as projection on ZR_P2P_OTBGATEPASS
  association [0..1] to ZI_UserContactCard as _EntryUserContactCard on $projection.EntryUser = _EntryUserContactCard.ContactCardID
  association [0..1] to ZI_UserContactCard as _ExitUserContactCard  on $projection.ExitUser = _ExitUserContactCard.ContactCardID
  association [0..1] to ZI_UserContactCard as _WBGrossWeightUserContactCard on $projection.WBGrossWeightUser = _WBGrossWeightUserContactCard.ContactCardID
  association [0..1] to ZI_UserContactCard as _WBTareWeightUserContactCard on $projection.WBTareWeightUser = _WBTareWeightUserContactCard.ContactCardID  
{
  key GatePassID,

      @Consumption.valueHelpDefinition: [{
         entity: {
             name: 'ZC_P2P_OTB_Shipment_TypeVH',
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

      BillOfLanding,

      @Consumption.valueHelpDefinition: [{
         entity: {
             name: 'ZC_P2P_GPC_SalesOrderVH',
             element: 'SalesOrder'
         },
         qualifier: 'SalesOrderVH',
         distinctValues: true }, {
         entity: {
             name: 'ZC_P2P_GPC_STOOrderVH',
             element: 'PurchaseOrder'
         },
         qualifier: 'STOOrderVH',
         distinctValues: true 
      }]
      OrderNumber,
      OrderNumberItem,
      
      RFID,
      RadiationCertificate,
      SealNumber,

      @ObjectModel.text.element: [ 'TransporterText' ]
      @UI.textArrangement: #TEXT_FIRST
      Transporter,
      _Transporter.SupplierFullName        as TransporterText,

      ContainerID,
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
      _WBManualReason.WBManualReasonText as WBManualReasonText,      
      
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
      
      @Semantics.quantity.unitOfMeasure: 'ContainerUnit'
      ContainerWeight, 
      @Semantics.unitOfMeasure: true
      ContainerUnit,              
      Pieces,   
      ZZCreatedTimestamp,
      ZZChangedTimestamp,

      /* Associations */
      _Item : redirected to composition child ZC_P2P_OTBGATEPASSITEM,

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
      _ProcessingIndicator
}
