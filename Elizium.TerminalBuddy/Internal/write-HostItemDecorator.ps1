
# Eventually, this function should go into Krayola
#
function write-HostItemDecorator {
  [CmdletBinding()]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
  param (
    [Parameter(
      Mandatory = $true
    )]
    [System.IO.FileSystemInfo]$Underscore,

    [Parameter(
      Mandatory = $true
    )]
    [int]$Index,

    [Parameter(
      Mandatory = $true
    )]
    [ValidateScript( {
      return $_.ContainsKey('BODY') -and $_.ContainsKey('MESSAGE') -and $_.ContainsKey('KRAYOLA-THEME')
    })]
    [System.Collections.Hashtable]
    $PassThru,

    [boolean]$Trigger
  )

<#
    [Parameter(Mandatory = $true)]
    [scriptblock]$Body,

    [Parameter(Mandatory = $true)]
    [string]
    $Label,

    [Parameter(Mandatory = $true)]
    [string]
    $ItemName,

    [Parameter(Mandatory = $false)]

    [System.Collections.Hashtable]
    $Theme,

    [Parameter(Mandatory = $false)]
    [string[][]]
    $TextSnippets,

    [string]$EachItemLine = $LightDotsLine
#>

  [scriptblock]$decorator = {
    param ($_underscore, $_index, $_passthru, $_trigger)
    [string]$decoratee = $passthru['BODY'];

    [System.Collections.Hashtable]$parameters = @{
      'Underscore' = $_underscore;
      'Index' = $_index;
      'PassThru' = $_passthru;
      'Trigger' = $_trigger;
    }

    Write-Host "DEBUG^^^: write-HostItemDecorator is about to invoke ... file: '$($_underscore.Name)', index: '$index'";

    return & $decoratee @parameters;
  }

  [System.Collections.Hashtable]$krayolaTheme = $passthru['KRAYOLA-THEME'];
  $invokeResult = $decorator.Invoke($Underscore, $Index, $PassThru, $Trigger);

  [string]$message = $passthru['MESSAGE'];
  # Now write to he host
  #
  Write-Host "=== DECORATOR === '${message}'";

  Write-ThemedPairsInColour -Pairs @(, @('filename', $Underscore.Name)) `
    -Theme $krayolaTheme -Message $message;

  return $invokeResult;
}
