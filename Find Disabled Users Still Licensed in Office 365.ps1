$OutputFile = "$($env:TEMP)\O365LicensedADDisabledUsers.csv"
$T1 = @()
$O365Users = Get-MsolUser -All
ForEach ($O365User in $O365Users)
{
  $ADuser = Get-ADUser -Filter {UserPrincipalName -eq $O365User.UserPrincipalName} -Properties whenCreated,Enabled
  If (($ADUser.Enabled -eq $false) -and ($O365User.isLicensed = $true)) 
  {
    $T1 += New-Object psobject -Property @{
      CollectDate=$(Get-Date);
      ADUserUPN=$($ADUser.UserPrincipalName);
      O365UserUPN=$($O365User.UserPrincipalName);
      ADUserCreated=$($ADUser.whenCreated);
      ADUserEnabled=$($ADUser.Enabled);
      O365Licensed=$($O365User.isLicensed)
    }
  }
}
$T1 = $T1 | Sort-Object -Property ADUserCreated
$T1 | Format-Table
$T1 | Export-Csv -Path $OutputFile -NoTypeInformation
Write-Host "Output to $OutputFile"
