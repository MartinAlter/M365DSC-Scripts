# Copy the script to your working directory

param (
    [string]$resourceName
)
Write-Host RessourceName: $resourceName

# some global variables
#example: contoso
$tenantName = "<you tenant name (before .onmicrosoft.com))>"
# Example: D:\M365DSC
$workDirectory = "<Skript and mof directory>"
#Example: D:\M365DSC-Git\Microsoft365DSC\Modules\Microsoft365DSC\Examples\Resources
$gitExamples = "<folder Examples resources files from git>"


# copy file, if not exist
if (Get-ChildItem $gitExamples -recurse | Where-Object {$_.Name -match "$resourceName"})
{
    Write-Host "resource was found"
    $example = Get-ChildItem -Path "$gitExamples\$resourceName\*.ps1"

    if (Get-ChildItem $workDirectory -recurse | Where-Object {$_.Name -match $example[0].Name})
    {
        Write-host "File available - remove first and create new from example"
        Remove-Item (Get-ChildItem $workDirectory -recurse | Where-Object {$_.Name -match $example[0].Name})
        copy-item $example[0].VersionInfo.FileName -Destination $workDirectory
    
    } else {
        Write-host "file not exists - create a new file from example"
        copy-item $example[0].VersionInfo.FileName -Destination $workDirectory
    }

    $configurationName = [System.IO.Path]::GetFileNameWithoutExtension($example[0].Name) -replace '^\d+-', ''
    (get-content $example[0].Name) -replace "Example","$configurationName" | set-content -path (join-path -path $workDirectory -childpath $example.name)
    (get-content $example[0].Name) -replace "O365DSC1","$tenantname" | set-content -path (join-path -path $workDirectory -childpath $example.name)
    $scriptName = $example[0].Name
    . .\$scriptName
 
    # create MOF file
    Invoke-Expression "$configurationName -ConfigurationData .\ConfigurationData.psd1"

    # deploy configuration
    Start-DSCConfiguration $configurationName -verbose -wait -force

} else {
    write-Host "Ressource nicht gefunden - Uebersicht:"
    Get-ChildItem $gitExamples |ft Name

}

