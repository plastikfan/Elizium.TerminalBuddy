
. .\Elizium.TerminalBuddy\Internal\get-SortedFilesNatural.ps1
. .\Elizium.TerminalBuddy\Internal\get-Theme.ps1
. .\Elizium.TerminalBuddy\Internal\import-ItermColors.ps1
. .\Elizium.TerminalBuddy\Internal\invoke-ForeachFile.ps1
. .\Elizium.TerminalBuddy\Internal\write-HostItemDecorator.ps1
. .\Elizium.TerminalBuddy\Public\ConvertFrom-ItermColors.ps1

$WindowsTerminalSettingsPath =
  Resolve-Path -Path '~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'

$P = 'C:\tools\ColorTool\schemes'
# $O = '~\dev\Testing\output.terminal-settings.json'

# ConvertFrom-ItermColors -Path $P -Filter 'a*.itermcolors' -Out $O
# ConvertFrom-ItermColors -Path $P -Filter 'a*.itermcolors' -SaveTerminalSettings

ConvertFrom-ItermColors -Path C:\shared\Themes\ITerm2\Favourites -SaveTerminalSettings

$testTheme = get-Theme;

Write-ThemedPairsInColour -Pairs @(, @('Windows settings file', $WindowsTerminalSettingsPath)) `
    -Theme $testTheme -Message $message;

<#
Some notes on comments in JSON
- There is a .net class JsonTextReader/JsonTextWriter, which supports 'extra' functionality like comments

- This package may make this possible in PoSh:
  https://www.powershellgallery.com/packages/newtonsoft.json/1.0.1.2

- the Posh module is: newtonsoft.json

- https://docs.microsoft.com/en-us/previous-versions/dotnet/articles/bb299886(v=msdn.10)
#>