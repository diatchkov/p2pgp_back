@EndUserText.label: 'GPC: default inbound shipment types'
@AccessControl.authorizationCheck: #CHECK
define view entity ZI_P2P_DefInbShipType
  as select from ztp2p_a_inbstdef
  association to parent ZI_P2P_DefInbShipTypes as _ZP2PDefInbShipTypes on $projection.SingletonID = _ZP2PDefInbShipTypes.SingletonID
{
  key tplst     as Tplst,
      shtyp     as Shtyp,
      tol_check as CheckTolerance,
      save_bcf  as SaveBCF,
      tdlnr_add as AddTransporter,
      fill_bulk as FillBulk,
      1         as SingletonID,
      _ZP2PDefInbShipTypes

}
