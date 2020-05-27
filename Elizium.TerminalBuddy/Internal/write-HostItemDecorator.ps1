
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
      return $_.ContainsKey('BODY') `
        -and $_.ContainsKey('KRAYOLA-THEME') -and $_.ContainsKey('ITEM-LABEL')
    })]
    [System.Collections.Hashtable]
    $PassThru,

    [boolean]$Trigger
  )

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

  $invokeResult = $decorator.Invoke($Underscore, $Index, $PassThru, $Trigger);

  [string]$message = $PassThru['MESSAGE'];
  [string]$itemLabel = $PassThru['ITEM-LABEL']

  [System.Collections.Hashtable]$parameters = @{}
  [string]$writerFn = '';

  [string]$productLabel = '';
  if ($invokeResult.Product) {
    $productLabel = 'Product';
    if ($PassThru.ContainsKey('PRODUCT-LABEL')) {
      $productLabel = $PassThru['PRODUCT-LABEL'];
    }
  }

  # Write with a Krayola Theme
  #
  if ($PassThru.ContainsKey('KRAYOLA-THEME')) {
    [System.Collections.Hashtable]$krayolaTheme = $PassThru['KRAYOLA-THEME'];
    [string[][]]$themedPairs = @(@('No', $("{0,3}" -f ($Index + 1))), @($itemLabel, $Underscore.Name));

    if (-not([string]::IsNullOrWhiteSpace($productLabel))) {
      $themedPairs = $themedPairs += , @($productLabel, $invokeResult.Product);
    }

    $parameters['Pairs'] = $themedPairs;
    $parameters['Theme'] = $krayolaTheme;

    $writerFn = 'Write-ThemedPairsInColour';
  }

  if (-not([string]::IsNullOrWhiteSpace($message))) {
    $parameters['Message'] = $message;
  }

  if (-not([string]::IsNullOrWhiteSpace($writerFn))) {
    & $writerFn @parameters;
  }

  return $invokeResult;
}
