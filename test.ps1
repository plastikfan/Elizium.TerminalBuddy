
. .\Elizium.TerminalBuddy\Internal\get-SortedFilesNatural.ps1
. .\Elizium.TerminalBuddy\Internal\get-Theme.ps1
. .\Elizium.TerminalBuddy\Internal\import-ItermColors.ps1
. .\Elizium.TerminalBuddy\Internal\invoke-ForeachFile.ps1
. .\Elizium.TerminalBuddy\Internal\write-HostItemDecorator.ps1
. .\Elizium.TerminalBuddy\Public\ConvertFrom-ItermColors.ps1

$WindowsTerminalSettingsPath =
  Resolve-Path -Path '~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'

$P = 'C:\tools\ColorTool\schemes'
$O = '~\dev\Testing\output.terminal-settings.json'

# ConvertFrom-ItermColors -Path $P -Filter 'a*.itermcolors' -Out $O
ConvertFrom-ItermColors -Path $P -Filter 'a*.itermcolors' -SaveTerminalSettings

$testTheme = get-Theme;

Write-ThemedPairsInColour -Pairs @(, @('Windows settings file', $WindowsTerminalSettingsPath)) `
    -Theme $testTheme -Message $message;

# ([xml]@(Get-Content -Path C:\tools\ColorTool\schemes\Zenburn.itermcolors)).ChildNodes -gt 0

<#
  $PT = [System.Collections.Hashtable]$passThru = @{
    'BODY'          = 'import-ItermColors';
    'MESSAGE'       = 'Terminal theme';
    'KRAYOLA-THEME' = get-Theme;
  }

 @{
      'Underscore' = $fi;
      'Index' = 1;
      'PassThru' = $PT;
      'Trigger' = $false;
    }
#>