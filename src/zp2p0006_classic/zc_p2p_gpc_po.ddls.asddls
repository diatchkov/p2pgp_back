@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: PO for printing'

@ObjectModel.semanticKey: [ 'PurchaseOrder' ]
@Metadata.allowExtensions: true

define view entity ZC_P2P_GPC_PO as projection on ZR_P2P_GPC_PO
{
  key GatePassID,
  key GatePassItemID,
  PurchaseOrder,
  CreateUser,
  CreateTmst,
  ChangeUser,
  ChangeTmst,
  LocalChangeTmst,
  
  _InbGatePass        : redirected to parent ZC_P2P_INBGATEPASS
  
  /* Associations */
}
