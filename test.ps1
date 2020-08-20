
$script:ImportFolders = @('.\Elizium.TerminalBuddy\Public', '.\Elizium.TerminalBuddy\Internal') 

foreach ($folder in $script:ImportFolders) {
  $source = Get-ChildItem -Path $folder -Recurse -File -Filter '*.ps1';
  $source | ForEach-Object { . $_; }
}

# $P = 'C:\tools\ColorTool\schemes'
# $O = '~\dev\Testing\output.terminal-settings.json'

# ConvertFrom-ItermColors -Path $P -Filter 'a*.itermcolors' -Out $O
# ConvertFrom-ItermColors -Path $P -Filter 'a*.itermcolors' -SaveTerminalSettings

ConvertFrom-ItermColors -Path C:\shared\Themes\ITerm2\Favourites -SaveTerminalSettings

<#
Some notes on comments in JSON
- There is a .net class JsonTextReader/JsonTextWriter, which supports 'extra' functionality like comments

- This package may make this possible in PoSh:
  https://www.powershellgallery.com/packages/newtonsoft.json/1.0.1.2

- the Posh module is: newtonsoft.json

- https://docs.microsoft.com/en-us/previous-versions/dotnet/articles/bb299886(v=msdn.10)
#>

