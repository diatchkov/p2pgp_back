@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: PO for printing'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZI_P2P_GPC_PO
  as select from ztp2p_a_po
{
  key tknum             as GatePassID,
  key tpnum             as GatePassItemID,
      ebeln             as PurchaseOrder,
      
      @Semantics.systemDateTime.createdAt: true
      create_tmst       as CreateTmst,
      
      @Semantics.user.createdBy: true
      create_user       as CreateUser,
      
      @Semantics.systemDateTime.lastChangedAt: true
      change_tmst       as ChangeTmst,
      
      @Semantics.user.lastChangedBy: true
      change_user       as ChangeUser,
      
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_change_tmst as LocalChangeTmst
}
