
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
    [string]$Out = '',

    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string]
    $KrayolaTheme
  )

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
    param(
      $_underscore, $_index, $_passthru, $_trigger
    )

    Write-Host "DEBUG: WRAPPER INVOKING ... file: '$($_underscore.Name)', index: '$index'"
    return write-HostItemDecorator -Underscore $_underscore `
      -Index $_index `
      -PassThru $_passthru `
      -Trigger $_trigger;
  }
  Write-Host "~~~ DEBUG invoking for path: $Path";

  $null = invoke-ForeachFile -Path $Path -Body $wrapper -PassThru $passThru `
    -Condition $containsXML -Filter $Filter;

  Write-Host "~~~ DEBUG invoke complete, Out: $Out";

  # Now collate the results stored inside the passthru
  #
  if ($passThru.ContainsKey('ACCUMULATOR')) {
    [System.Collections.Hashtable]$terminalThemes = $passThru['ACCUMULATOR'];
    [string]$outputContent = '{ "schemes": [';
    [string]$close = '] }';

    [int]$themeCount = 0;
    foreach ($theme in $terminalThemes) {
      $themeCount++;
      $outputContent += $theme;

      if ($themeCount -lt $terminalThemes.Count) {
        $outputContent += ','
      }
    }

    # $outputContent += $close;
    # $outputContent = $outputContent | ConvertFrom-Json | ConvertTo-Json;

    # Set-Content -Path $Out -Value $outputContent;
  } # ACCUMULATOR
} # ConvertFrom-ItermColors
