@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate pass cockpit: supplier value help'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZR_P2P_SUPPLIERVH as 
    select from A_PurchaseContract as _Contract
    left outer join ZI_P2P_SERVENTRYSHEET as _EntrySheet on 
      _EntrySheet.PurchaseContract = _Contract.PurchaseContract
    join ttds as _TransPoint on 
    _TransPoint.bukrs = _Contract.CompanyCode
    association[1..1] to I_Supplier as _Supplier on 
        _Supplier.Supplier = $projection.Supplier
    association[0..1] to I_SupplierAddress as _SupplierAddress on 
        _SupplierAddress.Supplier = $projection.Supplier
{   
    _TransPoint.tplst as TranspPlanPoint,    
    _Contract.Supplier as Supplier,
    _Supplier.SupplierFullName as SupplierFullName,
    _Supplier._SupplierToBusinessPartner._BusinessPartner._BusinessPartnerRole.BusinessPartnerRole as BusinessPartnerRole,
    _Contract.PurchaseContract, 
    @Semantics.amount.currencyCode: 'TargetCurrency'
    _Contract.PurchaseContractTargetAmount as TargetAmount,
    @Semantics.amount.currencyCode: 'TargetCurrency' 
    case when _EntrySheet.ServiceAmount is not null 
     then _EntrySheet.ServiceAmount 
     else cast( 0 as ktwrt ) end  as ServiceAmount,
    _Contract.DocumentCurrency as TargetCurrency,
    _Contract.ValidityEndDate as ValidityEndDate
    
} where _Contract.PurchasingProcessingStatus = '05'
    and _Contract.ValidityStartDate   <= $session.system_date
    and _Contract.ValidityEndDate     >= $session.system_date
union all 
    select from I_Supplier as _Supplier
    join I_SupplierCompany as _SupplierCompany on 
      _SupplierCompany.Supplier = _Supplier.Supplier
    join ttds as _TransPoint on 
    _TransPoint.bukrs = _SupplierCompany.CompanyCode
    join ZI_ASAS_UTILITIES_TVARVC( p_type: 'P', p_name: 'ZP2P0006_CLASSIC_SUPPLIER' ) as _OneTimeSupplier on 
      _OneTimeSupplier.low = _Supplier.Supplier
    association[0..1] to I_SupplierAddress as _SupplierAddress on 
        _SupplierAddress.Supplier = $projection.Supplier
{   
    _TransPoint.tplst as TranspPlanPoint,    
    _Supplier.Supplier as Supplier, 
    _Supplier.SupplierFullName as SupplierFullName,
    'CRM010' as BusinessPartnerRole,
    '' as PurchaseContract,
    cast( 0 as ktwrt ) as TargetAmount,
    cast( 0 as lwert ) as ServiceAmount,
    _SupplierCompany.Currency as TargetCurrency, 
    cast( '99991231' as kdate ) as ValidityEndDate
} 


