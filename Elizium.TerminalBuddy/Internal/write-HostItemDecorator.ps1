
# Eventually, this function should go into Krayola
#
function write-HostItemDecorator {
  <#
  .NAME write-HostItemDecorator

  .SYNOPSIS
    Performs iteration over a collection of files which are children of the directory
    specified by the caller.

  .DESCRIPTION
    The purpose of this function is a act as a decorator to a custom function on
  behalf of which any write-host operations are performed. This keeps any
  display functionality out of that function so that it may be used in scenarios
  where output is not required.

  .PARAMETER Underscore
    The iterated target item provided by the parent iterator function.

  .PARAMETER Index
    0 based numeric index specifing the ordinal of the iterated target.

  .PARAMETER PassThru
    The dictionary object used to pass parameters to the decorated scriptblock
    (enclosed within the PassThru Hashtable).

  .PARAMETER Trigger
    Trigger.

  .OUTPUTS
    The result of invoking the BODY script block.
  #>

  [OutputType([PSCustomObject])]
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
