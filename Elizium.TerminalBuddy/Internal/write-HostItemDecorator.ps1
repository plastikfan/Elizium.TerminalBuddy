
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
      return $_.ContainsKey('BODY') -and $_.ContainsKey('MESSAGE') `
        -and $_.ContainsKey('KRAYOLA-THEME') -and $_.ContainsKey('ITEM-LABEL')
    })]
    [System.Collections.Hashtable]
    $PassThru,

    [boolean]$Trigger
  )

<#
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

    return & $decoratee @parameters;
  }

  [System.Collections.Hashtable]$krayolaTheme = $PassThru['KRAYOLA-THEME'];
  $invokeResult = $decorator.Invoke($Underscore, $Index, $PassThru, $Trigger);

  [string]$message = $PassThru['MESSAGE'];
  [string]$itemLabel = $PassThru['ITEM-LABEL']
  [string[][]]$pairs = @(@('No', $("{0,3}" -f ($Index + 1))), @($itemLabel, $Underscore.Name));

  if ($invokeResult.Product) {
    [string]$productLabel = 'Product';
    if ($PassThru.ContainsKey('PRODUCT-LABEL')) {
      $productLabel = $PassThru['PRODUCT-LABEL'];
    }
    $pairs = $pairs += , @($productLabel, $invokeResult.Product);
  }

  Write-ThemedPairsInColour -Pairs $pairs -Theme $krayolaTheme -Message $message;

  return $invokeResult;
}
