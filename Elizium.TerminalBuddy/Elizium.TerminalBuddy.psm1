
Set-StrictMode -Version Latest

[string]$WindowsTerminalSettingsPath =
  Resolve-Path -Path '~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
$null = $WindowsTerminalSettingsPath;

$functionFolders = @('Public', 'Internal')
foreach ($folder in $functionFolders)
{
    $folderPath = Join-Path -Path $PSScriptRoot -ChildPath $folder
    if (Test-Path -Path $folderPath)
    {
        Write-Verbose -Message "Importing from $folder"
        $functions = Get-ChildItem -Path $folderPath -Filter '*.ps1'
        foreach ($function in $functions)
        {
            Write-Verbose -Message "  Importing $($function.BaseName)"
            . $($function.FullName)
        }
    }
}

$publicFunctions = (Get-ChildItem -Path "$PSScriptRoot/Public" -Filter '*.ps1').BaseName

Export-ModuleMember -Function $publicFunctions
Export-ModuleMember -Variable 'WindowsTerminalSettingsPath'
Export-ModuleMember -Alias 'cfic', 'Make-WtSchemesIC'
