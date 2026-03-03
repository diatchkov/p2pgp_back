@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: inbound gate pass root'

@ObjectModel.semanticKey: [ 'GatePassID' ]
@Metadata.allowExtensions: true

define root view entity ZR_P2P_INBGATEPASS
  as select from ZI_P2P_INBGATEPASS
  association [0..1] to I_Plant                as _Plant           on  $projection.Plant = _Plant.Plant
  association [0..1] to I_StorageLocation      as _StorageLocation on  $projection.StorageLocation = _StorageLocation.StorageLocation
                                                                   and $projection.Plant           = _StorageLocation.Plant
  composition [0..*] of ZR_P2P_INBGATEPASSITEM as _Item
  composition [0..*] of ZR_P2P_GPC_PO as _PO
{
  key GatePassID,
      GatePassType,
      GatePassDirection,
      ProcessingIndicator,
      TranspPlanPoint,
      BillOfLanding,
      OrderNumber,
      OrderNumberItem,
      RFID,
      RadiationCertificate,
      SealNumber,
      Transporter,
      ContainerID,
      Plant,
      StorageLocation,
      TruckGUID,
      TruckID,
      TruckType,
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
      WBManualReason,
      WBNotes,
      WBDeviceID,
      WBGrossWeight,
      WBTareWeight,
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
      Status, 
      CostRelevant,
      CostCalcStatus,      
      RadiationCertificateBody,
      RadiationCertificateFile,
      RadiationCertificateType,   
      ContainerWeight, 
      ContainerUnit,    
      Pieces,
      ZZCreatedTimestamp,
      ZZChangedTimestamp,
        
      /* Associations */
      _Status,
      _Item,
      _PO,
      _ShipmentType,
      _TranspPlanPoint,
      _Transporter,
      _TruckType,
      _WBCapture,
      _WBManualReason,
      _Plant,
      _StorageLocation,
      _ProcessingIndicator,
      _PurchaseOrderItem
} where GatePassType = 'Z010' or GatePassType = 'Z020'
