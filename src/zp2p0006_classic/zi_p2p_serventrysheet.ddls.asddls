@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: service entry sheet'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZI_P2P_SERVENTRYSHEET
  as select from essr                     as _Sheet
    join         I_MaterialDocumentRecord as _MatDoc on _MatDoc.InvtryMgmtReferenceDocument = _Sheet.lblni
{
  key cast( substring(_Sheet.lblne,1,10) as vdm_purchasecontract preserving type) as PurchaseContract,
      @Semantics.amount.currencyCode: 'Currency'
      sum( _MatDoc.TotalGoodsMvtAmtInCCCrcy )                                     as ServiceAmount,
      _MatDoc.CompanyCodeCurrency                                                 as Currency
}
where
      _Sheet.loekz = ' '
  and _Sheet.lblne is not initial
group by
  _Sheet.lblne,
  _MatDoc.CompanyCodeCurrency
