
function ConvertFrom-ItermColors {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseBOMForUnicodeEncodedFile", "")]
  [Alias('cfic', 'Make-WtSchemesIC')]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateScript( { return Test-Path $_ -PathType 'Container' })]
    [string]
    $Path,

    [Parameter(Mandatory = $false)]
    [string]$Filter = '*',

    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [ValidateScript( { return ([string]::IsNullOrWhiteSpace($_) ) -or (-not(Test-Path $_ -PathType ‘Leaf’)) })]
    [string]$Out,

    [switch]$SaveTerminalSettings,

    [switch]$Force,

    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string]$DryRunFile = '~/Windows.Terminal.dry-run.settings.json',

    [Parameter(Mandatory = $false)]
    [ValidateScript( { return -not(Test-Path $_ -PathType 'Leaf') })]
    [string]$BackupFile = "~/Windows.Terminal.settings.json",
  
    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string]
    $KrayolaTheme
  )

  function composeAll {
    [OutputType([string])]
    param(
      [Parameter()]
      [System.Collections.Hashtable]$Themes
    )

    [string]$outputContent = '{ "schemes": [';
    [string]$close = '] }';

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
    $outputContent = $outputContent | ConvertTo-Json | ConvertFrom-Json;

    return $outputContent;
  } # composeAll

  function containsScheme {
    [OutputType([boolean])]
    param(
      [string]$SchemeName,
      [object[]]$Schemes
    )

    $found = $Schemes | Where-Object { $_.name -eq $SchemeName };
    
    return ($null -ne $found);
  }

  function integrateIntoSettings {
    param(
      [string]$Content,

      [string]$SettingsPath,

      [string]$OutputPath,

      [switch]$Overwrite
    )

    [string]$settingsContentRaw = Get-Content -Path $SettingsPath -Raw;
    [PSCustomObject]$settingsObject = [PSCustomObject] ($settingsContentRaw | ConvertFrom-Json);
    $settingsSchemes = $settingsObject.schemes;
    [PSCustomObject]$contentObject = [PSCustomObject] ($Content | ConvertFrom-Json)
  
    [System.Collections.ArrayList]$integratedSchemes = New-Object `
      -TypeName System.Collections.ArrayList -ArgumentList @(, $settingsSchemes);

    foreach ($sch in $contentObject.schemes) {
      if (-not(containsScheme -SchemeName $sch.name -Schemes $settingsSchemes)) {
        $null = $integratedSchemes.Add($sch);
      }
    }

    $settingsObject.schemes = $integratedSchemes;

    Set-Content -Path $OutputPath -Value $($settingsObject | ConvertTo-Json);

    # ConvertTo-Json | ConvertFrom-Json
  } # integrateIntoSettings

  [scriptblock]$containsXML = {
    # Not making assumption about suffix of the specfied source file(s), since
    # the only requirement is that the content of the file is xml.
    #
    param (
      [System.IO.FileSystemInfo]$underscore
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
    'MESSAGE'       = 'Importing Terminal Theme';
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

  # Now collate the accumulated results stored inside the passthru
  #
  if ($passThru.ContainsKey('ACCUMULATOR')) {
    [System.Collections.Hashtable]$accumulator = $passThru['ACCUMULATOR'];

    if ($accumulator) {
      [string]$outputContent = composeAll -Themes $accumulator;

      if ($SaveTerminalSettings.ToBool()) {
        if ($Force.ToBool()) {
          # Backup file
          #
          Copy-Item -Path $(Resolve-Path -Path $WindowsTerminalSettingsPath) -Destination $BackupFile;

          integrateIntoSettings -Content $outputContent -SettingsPath $WindowsTerminalSettingsPath `
            -OutputPath $WindowsTerminalSettingsPath;
        } else {
          integrateIntoSettings -Content $outputContent -SettingsPath $WindowsTerminalSettingsPath `
            -OutputPath $DryRunFile;
        }
      } else {
        Set-Content -Path $Out -Value $outputContent;
      }
    }
  }
} # ConvertFrom-ItermColors
