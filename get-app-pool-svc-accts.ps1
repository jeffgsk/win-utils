$outputFile = "C:\path\to\output.json"  # Replace with the desired path to the output JSON file

Import-Module WebAdministration

$appPools = Get-ChildItem IIS:\AppPools
$appPoolList = @()

foreach ($appPool in $appPools) {
    $appPoolName = $appPool.Name
    $processModel = Get-ItemProperty "IIS:\AppPools\$appPoolName" -Name processModel
    $identityType = $processModel.processModel.identityType

    switch ($identityType) {
        0 { $identity = "LocalSystem" }
        1 { $identity = "LocalService" }
        2 { $identity = "NetworkService" }
        3 { $identity = "SpecificUser: $($processModel.processModel.userName)" }
        4 { $identity = "ApplicationPoolIdentity" }
        default { $identity = "Unknown" }
    }

    $appPoolInfo = [PSCustomObject]@{
        ApplicationPoolName = $appPoolName
        Identity = $identity
    }

    $appPoolList += $appPoolInfo
}

# Convert to JSON and export to file
$appPoolList | ConvertTo-Json | Out-File -FilePath $outputFile -Force

Write-Output "The application pool information has been exported to $outputFile"
