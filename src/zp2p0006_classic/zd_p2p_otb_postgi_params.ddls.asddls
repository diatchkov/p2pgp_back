@EndUserText.label: 'GPC: post with tolerance params'

define root abstract entity ZD_P2P_OTB_POSTGI_PARAMS
{
  @Consumption.valueHelpDefinition: [{
     entity     : {
         name   : 'ZC_P2P_TOLERANCE_REASONVH',
         element: 'ToleranceReason'
     },
     distinctValues: true
  }]
  reason        : zp2p_tolerance_reason;

  @Consumption.valueHelpDefinition: [{
     entity     : {
         name   : 'ZC_P2P_GPC_EMPLOYEE',
         element: 'EmployeeFullName'
     }
  }]  
  employee_name : p12_emple;
}
