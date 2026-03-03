@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Accommodation: employee'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_P2P_GPC_EMPLOYEE
  as select from I_Employee
  association [1..1] to I_HCMEmployee as _HCM on _HCM.HCMPersonnelNumber = $projection.Employee
{
  key Employee,
      EmployeeFullName,
      _HCM._Position._Text[ Language = $session.system_language ].HCMPositionName as EmployeePositionName,

      /* Associations */
      _HCM
}
