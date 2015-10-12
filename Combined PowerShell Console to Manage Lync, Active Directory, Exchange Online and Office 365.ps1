Function Connect-LyncExchangeMsol {
	CD C:
	Remove-PSSession -Name "Lync" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
	Remove-PSSession -Name "Exchange" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

	$Global:LyncSession = ""
	$Global:EOSession = ""
	$Global:ActiveDirectoryCredential = ""
	Remove-Module ActiveDirectory -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
	Remove-Module MSOnline -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

	$Global:ActiveDirectoryCredential = $host.ui.PromptForCredential("Office 365 / AD Credentials","Please enter your UPN and password:","","")

	Write-Host "Importing Active Directory Powershell Module..."
	Import-Module ActiveDirectory

	Write-Host "Setting up Active Directory Connection..."
	Remove-PSDrive -Name AD -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
	New-PSDrive -Name AD -PSProvider ActiveDirectory -Root "" -Server "domaincontroller1.company.com" -Credential $Global:ActiveDirectoryCredential
	CD AD:

	Write-Host "Importing Office 365 Powershell Module..."
	Import-Module MSOnline

	Write-Host "Creating Lync Connection..."
	$Global:LyncSession = New-PSSession -ConnectionUri "https://lync-fepool.company.com/OcsPowershell" -Credential $Global:ActiveDirectoryCredential -Name "Lync"

	Write-Host "Creating Exchange Online Connection..."
	$Global:EOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $Global:ActiveDirectoryCredential -Authentication Basic -AllowRedirection -Name "Exchange"

	Write-Host "Connecting to Office365..."
	Connect-MsolService -Credential $Global:ActiveDirectoryCredential

	Write-Host "Connecting to Lync..."
	Import-PSSession $Global:LyncSession -AllowClobber

	Write-Host "Connecting to Exchange Online..."
	Import-PSSession $Global:EOSession -AllowClobber
}
