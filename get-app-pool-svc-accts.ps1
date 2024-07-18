$outputFile = "C:\path\to\output.json"  # Replace with the desired path to the output JSON file

Import-Module WebAdministration

$appPools = Get-ChildItem IIS:\AppPools
$appPoolList = @()

foreach ($appPool in $appPools) {
    $appPoolName = $appPool.Name
    $processModel = Get-ItemProperty "IIS:\AppPools\$appPoolName" -Name processModel

    switch ($processModel.identityType) {
        "LocalSystem"         { $identity = "LocalSystem" }
        "LocalService"        { $identity = "LocalService" }
        "NetworkService"      { $identity = "NetworkService" }
        "ApplicationPoolIdentity" { $identity = "ApplicationPoolIdentity" }
        "SpecificUser"        { $identity = "SpecificUser: $($processModel.userName)" }
        default               { $identity = "Unknown" }
    }

    $appPoolInfo = [PSCustomObject]@{
        ApplicationPoolName = $appPoolName
        Identity = $identity
    }

    $appPoolList += $appPoolInfo
}

# Convert to JSON and export to file
$appPoolList | ConvertTo-Json -Depth 3 | Out-File -FilePath $outputFile -Force

Write-Output "The application pool information has been exported to $outputFile"
