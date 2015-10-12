#------------------------ Exchange Online Connection

$EOcred = Get-Credential
$EOsess = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $EOcred -Authentication Basic -AllowRedirection 
Import-PSSession $EOsess

#------------------------ Lync Front-End Connection

$Lcred = Get-Credential
$Lsess = New-PSSession -ConnectionUri https://lync-fepool.company.com/OcsPowershell -Credential $Lcred 
Import-PSSession $Lsess

#------------------------ Create Address Lists and Lync Auto Attendants

New-AddressList "CD-SL" -DisplayName "Company Directory - Salamander (SL)" -RecipientFilter {((RecipientType -eq 'UserMailbox') -and (CustomAttribute1 -like "*SL*"))} -Container "Company &amp; Office Directories"
New-AddressList "OD-RM" -DisplayName "Office Directory - Rome (RM)" -RecipientFilter {((RecipientType -eq 'UserMailbox') -and (CustomAttribute2 -like "*RM*"))} -Container "Company &amp; Office Directories"
New-UMAutoAttendant -Name "CD-SL" -UMDialPlan "Default UM Dial Plan" -PilotIdentifierList "+500001" -Status Enabled
New-UMAutoAttendant -Name "OD-RM" -UMDialPlan "Default UM Dial Plan" -PilotIdentifierList "+500002" -Status Enabled
Set-UMAutoAttendant -Identity "CD-SL" -ContactScope "AddressList" -ContactAddressList "\Company &amp; Office Directories\CD-SL" -SendVoiceMsgEnabled $true
Set-UMAutoAttendant -Identity "OD-RM" -ContactScope "AddressList" -ContactAddressList "\Company &amp; Office Directories\OD-RM" -SendVoiceMsgEnabled $true

#------------------------ Lync Contacts and Voicemail Policy

New-CsExUmContact -SipAddress "sip:LyncCP-UMAA-CD-SL@company.com" -RegistrarPool "lync-fepool.company.com" -OU "OU=Service Accounts,DC=company,DC=com" -AutoAttendant $True -DisplayNumber "+500001"
New-CsExUmContact -SipAddress "sip:LyncCP-UMAA-OD-RM@company.com" -RegistrarPool "lync-fepool.company.com" -OU "OU=Service Accounts,DC=company,DC=com" -AutoAttendant $True -DisplayNumber "+500002"
Grant-CsHostedVoicemailPolicy -Identity "sip:LyncCP-UMAA-CD-SL@company.com" -PolicyName "Default Policy"
Grant-CsHostedVoicemailPolicy -Identity "sip:LyncCP-UMAA-OD-RM@company.com" -PolicyName "Default Policy"

#------------------------ Workaround Microsoft Problems

Get-MailBox | Where-Object {$_.CustomAttribute1 -like "*SL*"} | Set-Mailbox –ApplyMandatoryProperties
Get-MailBox | Where-Object {$_.CustomAttribute2 -like "*RM*"} | Set-Mailbox –ApplyMandatoryProperties
