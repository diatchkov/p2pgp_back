@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: PO for printing'

define view entity ZR_P2P_GPC_PO as select from ZI_P2P_GPC_PO
   association to parent ZR_P2P_INBGATEPASS as _InbGatePass on _InbGatePass.GatePassID = $projection.GatePassID
{
  key GatePassID,
  key GatePassItemID,
  PurchaseOrder,
  CreateUser,
  CreateTmst,
  ChangeUser,
  ChangeTmst,
  LocalChangeTmst,
   // Make association public
   
  _InbGatePass
}
