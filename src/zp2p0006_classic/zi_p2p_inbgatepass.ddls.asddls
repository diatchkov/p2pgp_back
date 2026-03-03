@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: inbound gate pass root'

@ObjectModel.semanticKey: [ 'GatePassID' ]
@Metadata.allowExtensions: true

define view entity ZI_P2P_INBGATEPASS
  as select from ZI_P2P_GATEPASS
  association [0..1] to ZC_P2P_FIRST_POI               as _FirstPOI          on  $projection.OrderNumber = _FirstPOI.PurchaseOrder
  association [0..1] to ZC_P2P_GPC_PURCHASEORDERITEMVH as _PurchaseOrderItem on  $projection.OrderNumber     = _PurchaseOrderItem.PurchaseOrder
                                                                             and $projection.OrderNumberItem = _PurchaseOrderItem.PurchaseOrderItem
                                                                             and $projection.TranspPlanPoint = _PurchaseOrderItem.TranspPlanPoint
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
      _FirstPOI.Plant as Plant,
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
      _ShipmentType,
      _TranspPlanPoint,
      _Transporter,
      _TruckType,
      _WBCapture,
      _WBManualReason,
      _ProcessingIndicator,
      _FirstPOI,
      _PurchaseOrderItem
}
where
     GatePassType = 'Z010'
  or GatePassType = 'Z020'
