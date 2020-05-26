
function ConvertFrom-ItermColors {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseBOMForUnicodeEncodedFile", "")]
  [Alias('cfic', 'Make-WtSchemesIC')]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateScript( { return Test-Path $_ -PathType ‘Container’ })]
    [string]
    $Path,

    [string]
    $Filter = '*',

    [AllowEmptyString()]
    [ValidateScript( { return ([string]::IsNullOrWhiteSpace($_) ) -or (-not(Test-Path $_ -PathType ‘Leaf’)) })]
    [string]$Out,

    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string]
    $KrayolaTheme
  )

  function composeAll {
    [OutputType([string])]
    param(
      [Parameter()]
      [System.Collections.Hashtable]$Themes,

      [Parameter()]
      [switch]$Raw
    )

    [string]$outputContent = '{ "schemes": [';
    [string]$close = '] }';

    if ($Raw.ToBool()) {
      $close = $outputContent = '';
    }

    [System.Collections.IDictionaryEnumerator]$enumerator = $Themes.GetEnumerator();

    if ($Themes.Count -gt 0) {
      while ($enumerator.MoveNext()) {
        [System.Collections.DictionaryEntry]$entry = $enumerator.Current;
        [string]$themeFragment = $entry.Value;
        $outputContent += ($themeFragment + ',');
      }

      [int]$last = $outputContent.LastIndexOf(',');
      $outputContent = $outputContent.Substring(0, $last);
    }

    $outputContent += $close;

    if (-not($Raw.ToBool())) {
      $outputContent = $outputContent | ConvertTo-Json | ConvertFrom-Json;
    }

    return $outputContent;
  }

  [scriptblock]$containsXML = {
    # Not making assumption about suffix of the specfied source file(s), since
    # the only requirement is that the content of the file is xml.
    #
    param (
      [System.IO.FileSystemInfo]
      $underscore
    )
    try {
      return ([xml]@(Get-Content -Path $underscore.Fullname)).ChildNodes.Count -gt 0;
    } catch {
      return $false;
    }
  } # $containsXML

  [System.Collections.Hashtable]$displayTheme = get-Theme -KrayolaTheme $KrayolaTheme;

  [System.Collections.Hashtable]$passThru = @{
    'BODY'          = 'import-ItermColors';
    'MESSAGE'       = 'Terminal theme';
    'KRAYOLA-THEME' = $displayTheme;
  }

  [scriptblock]$wrapper = {
    # This wrapper is required because you can't pass a function name as a variable
    # without PowerShell mistaking it for an invoke request.
    #
    param(
      $_underscore, $_index, $_passthru, $_trigger
    )

    return write-HostItemDecorator -Underscore $_underscore `
      -Index $_index `
      -PassThru $_passthru `
      -Trigger $_trigger;
  }

  $null = invoke-ForeachFile -Path $Path -Body $wrapper -PassThru $passThru `
    -Condition $containsXML -Filter $Filter;

  # Now collate the results stored inside the passthru
  #
  if ($passThru.ContainsKey('ACCUMULATOR')) {
    [System.Collections.Hashtable]$accumulator = $passThru['ACCUMULATOR'];

    if ($accumulator) {
      [string]$outputContent = composeAll -Themes $accumulator;
      Set-Content -Path $Out -Value $outputContent;
    }
  }
} # ConvertFrom-ItermColors
