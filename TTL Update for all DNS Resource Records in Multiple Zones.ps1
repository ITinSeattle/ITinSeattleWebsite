#DO NOT CHANGE THESE
$OldRecord = $null
$NewRecord = $null
$DomainsToFix = @()
$PrefixesToFix = @()

#CHANGE THESE AS NEEDED
$DomainController = "DomainController.domain1.com"
$TimeoutSeconds = 60

#DUPLICATE AS MANY LINES AS NECESSARY FOR EACH NAMED ZONE
$DomainsToFix += "pinpointzone1.domain2.com"
$DomainsToFix += "pinpointzone2.domain2.com"

#DUPLICATE AS MANY LINES AS NECESSARY FOR WILDCARD HANDLING BASED ON PREFIX
$PrefixesToFix += "_sip._tls."
$PrefixesToFix += "dialin."
$PrefixesToFix += "meet."
$PrefixesToFix += "sip."

Function Update-DnsResourceRecordTTL
{
    param ($Record)
    
    $OldRecord = $Record.PsObject.Copy()
    $NewRecord = $Record.PsObject.Copy()
    $NewRecord.TimeToLive = [System.TimeSpan]::FromSeconds($TimeoutSeconds)
    If ($NewRecord.TimeToLive -ne $OldRecord.TimeToLive)
    {
        Set-DnsServerResourceRecord -Computer $DomainController -CimSession $CIMSession -ZoneName $Zone.ZoneName -OldInputObject $OldRecord -NewInputObject $NewRecord
    }
}

$CIMSession = New-CimSession -Credential $ActiveDirectoryCredential -ComputerName $DomainController
$Zones = Get-DnsServerZone -Computer $DomainController -CimSession $CIMSession

ForEach ($Zone in $Zones)
{
    If ($DomainsToFix -contains $Zone.ZoneName)
    {
        $Records = Get-DnsServerResourceRecord -Computer $DomainController -CimSession $CIMSession -ZoneName $Zone.ZoneName
        $Records = $Records | Sort-Object -Property RecordType
        ForEach ($Record in $Records)
        {
            # Do SOA records first, otherwise you'll error due to timing.
            If ($Record.RecordType -eq "SOA") {Update-DnsResourceRecordTTL $Record}
        }
        ForEach ($Record in $Records)
        {
            # Do all non-SOA records last, otherwise you'll error due to timing.
            If ($Record.RecordType -ne "SOA") {Update-DnsResourceRecordTTL $Record}
        }
    }
    ForEach ($PrefixToFix in $PrefixesToFix)
    {
        If ($Zone.ZoneName -like "$($PrefixToFix)*")
        {
            $Records = Get-DnsServerResourceRecord -Computer $DomainController -CimSession $CIMSession -ZoneName $Zone.ZoneName
            $Records = $Records | Sort-Object -Property RecordType
            ForEach ($Record in $Records)
            {
                # Do SOA records first, otherwise you'll error due to timing.
                If ($Record.RecordType -eq "SOA") {Update-DnsResourceRecordTTL $Record}
            }
            ForEach ($Record in $Records)
            {
                # Do all non-SOA records last, otherwise you'll error due to timing.
                If ($Record.RecordType -ne "SOA") {Update-DnsResourceRecordTTL $Record}
            }
        }
    }
}
