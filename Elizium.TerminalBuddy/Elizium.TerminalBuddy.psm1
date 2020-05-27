
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

# This has to be done manually, because there is no direct relationship between
# the file name and the function name, eg "Write-ThemedPairsInColour" => write-coloured-pairs.ps1
# Perhaps we should correct this in the future or we remove the dashes from "coloured-pairs"
# in order to yield "ColouredPairs". If this functionality is implmented, don't forget to
# port this back into the module plaster.
#
# $publicFunctions = (Get-ChildItem -Path "$PSScriptRoot/Public" -Filter '*.ps1').BaseName
#
# Export-ModuleMember -Function <TODO>
# Export-ModuleMember -Variable [TODO]
# Export-ModuleMember -Alias [TODO]
