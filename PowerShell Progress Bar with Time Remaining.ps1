$i = 0
$StartTime = Get-Date
ForEach ($Item in $Items)
{
    $i++
    $SecondsElapsed = ((Get-Date) - $StartTime).TotalSeconds
    $SecondsRemaining = ($SecondsElapsed / ($i / $Items.Count)) - $SecondsElapsed
    Write-Progress -Activity "Processing Record $i of $($Items.Count)" -PercentComplete (($i/$($Items.Count)) * 100) -CurrentOperation "$("{0:N2}" -f ((($i/$($Items.Count)) * 100),2))% Complete" -SecondsRemaining $SecondsRemaining
}
