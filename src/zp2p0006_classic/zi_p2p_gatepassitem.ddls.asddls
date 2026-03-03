@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate pass cockpit:item - delivery'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_P2P_GATEPASSITEM
  as select from vttp
  association [0..1] to I_DeliveryDocument as _DeliveryDocument on _DeliveryDocument.DeliveryDocument = $projection.DeliveryDocument
{
  key tknum as GatePassID,
  key tpnum as GatePassItemID,
      vbeln as DeliveryDocument,
      ernam as CreatedByUser,
      erdat as CreationDate,
      erzet as CreationTime,
      zzcreatedtimestamp as ZZCreatedTimestamp,
      zzchangedtimestamp as ZZChangedTimestamp,
      
      _DeliveryDocument
}
