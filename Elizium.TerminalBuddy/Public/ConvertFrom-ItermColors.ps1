
function ConvertFrom-ItermColors {
  <#
  .NAME
    ConvertFrom-ItermColors

  .SYNOPSIS
    Converts .itermcolor files into a format that can be used in Window Terminal Settings.
    Depending on the parameters provided, will either integrate generated schemes into
    the setting files, or generate a separate file from the existing settings file. Any
    schemes already present in the setting files will be preserved.

  .DESCRIPTION
    Since there is currently no settings UI in Windows Terminal Settings app and the format
    that is used to express colour schemes is vastly different to that used by iterm, it
    is not easy to leverage the work done by others in creating desirable terminal schemes.
    This function makes it easier to apply iterm colour schemes into Windows Terminal.
      There are multiple ways to use this function:
      1) generate an Output file (denoted by $Out paramater), which will contain a JSON
      object containing the colour schemes converted from iterm to Windows Terminal
      format.
      2) generate a new Dry Run file which is a copy of the current Windows Terminal
      Settings file with the convertd schemes integrated into it.
      3) make a backup, of the Settings file, then integrate the generated schemes into
      the current Settings file. (See caveats further down below).

      The function errs on the side of caution, and by default works in 'Dry Run' mode. Due
    to the caveats, this method is effectively the same as not using the $SaveTerminalSettings
    switch, using $Out instead, because in this scenario, the user would be expected to open
    up the generated file and copy the generated scheme objects into the current Settings
    file. This is the recommended way to use this command.

      If the user wants to integrate the generated schemes into the Settings file
    automatically, then the $Force switch should be specified. In this case, the current live
    Settings file is backed up and then over-written by the new content. Existing schemes
    are preserved.

      And the caveats ...
      1) For some reason, Microsoft decided to include comments inside the JSON setting file
    (probably in leu of there not being a proper settings UI, making configuring the settings
    easier). However, comments are not part of the current JSON schema (although they are
    permitted in the rarely and sparsely supported json5 spec), which means that this conversion
    process will not preserve the comments. There is an alternative api that supposedly supports
    non standard JSON features, newtonsoft.json.ConvertTo-JsonNewtonsoft/ConvertFrom-JsonNewtonsoft
    but using these functions yield unsatifactory results.
      2) ConvertFrom-Json/Converto-Json do not properly handle the profiles 

  .PARAMETER $Path
    The parent directory to iterate

  .PARAMETER $Filter
    The filter to apply to Get-ChildItem

  .PARAMETER $Out
    The output file written to with the JSON represented the converted iterm themes. This
    content is is just a fragment of the settings file, in fact it's a JSON object which
    contains a single member named 'schemes' (after the corresponding entry in the
    Windows Terminal Settings file.) which is set to an array of scheme objects.

  .PARAMETER $SaveTerminalSettings
    switch, to indcate that the converted schemes should be saved into a complete settings
    file. Which settings file depends on the presence of the Force paramter, which
    
  .PARAMETER $Force
    switch to indicate whether live settings should be modified to include generated schemes.
    To avoid accidental invocation, needs to be used in addition to SaveTerminalSettings.

  .PARAMETER $DryRunFile
    When run in Dry Run mode (by default), this is the path of the file written to conatain
    the current Windows Terminal Settings file with newly generated schemes as converted
    from iterm files specified by the $Path.

  .PARAMETER $BackupFile
    When not in Dry Run mode ($Force and $SaveTerminalSettings specified), this paramter
    specifies the path to backup the live Windows Terminal Settings file to.

  .PARAMETER $ThemeName
    The name of a Krayola Theme, that has been configured inside the global $KrayolaThemes
    hashtable variable. If not present, then an internal theme is used. The Krayola Theme
    shapes how output of this command is generated to the consle.
  #>

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
    [ValidateScript( { return ([string]::IsNullOrWhiteSpace($_) ) `
      -or (-not(Test-Path $_ -PathType 'Leaf')) })]
    [string]$Out,

    [switch]$SaveTerminalSettings,

    [switch]$Force,

    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string]$DryRunFile = '~/Windows.Terminal.dry-run.settings.json',

    [Parameter(Mandatory = $false)]
    [ValidateScript( { return -not(Test-Path $_ -PathType 'Leaf') })]
    [string]$BackupFile = "~/Windows.Terminal.back-up.settings.json",

    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string]
    $ThemeName
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
      [Parameter()]
      [string]$SchemeName,

      [Parameter()]
      [object[]]$Schemes
    )

    $found = $Schemes | Where-Object { $_.name -eq $SchemeName };

    return ($null -ne $found);
  }

  function integrateIntoSettings {
    param(
      [Parameter()]
      [string]$Content,

      [Parameter()]
      [string]$SettingsPath,

      [Parameter()]
      [string]$OutputPath,

      [Parameter()]
      [switch]$Overwrite
    )

    [string]$settingsContentRaw = Get-Content -Path $SettingsPath -Raw;
    [PSCustomObject]$settingsObject = [PSCustomObject] ($settingsContentRaw | ConvertFrom-Json);
    $settingsSchemes = $settingsObject.schemes;
    [PSCustomObject]$contentObject = [PSCustomObject] ($Content | ConvertFrom-Json)

    [System.Collections.ArrayList]$integratedSchemes = New-Object `
      -TypeName System.Collections.ArrayList -ArgumentList @(, $settingsSchemes);

    [System.Collections.Hashtable]$integrationTheme = Get-KrayolaTheme;
    $integrationTheme['VALUE-COLOURS'] = @(, @('Blue'));

    [System.Collections.Hashtable]$skippingTheme = Get-KrayolaTheme;
    $skippingTheme['VALUE-COLOURS'] = @(, @('Red'));

    foreach ($sch in $contentObject.schemes) {
      [string[][]]$pairs = @(, @('Scheme name', $sch.name));
      if (-not(containsScheme -SchemeName $sch.name -Schemes $settingsSchemes)) {
        Write-ThemedPairsInColour -Pairs $pairs -Theme $integrationTheme `
          -Message 'Integrating new theme';
        $null = $integratedSchemes.Add($sch);
      } else {
        Write-ThemedPairsInColour -Pairs $pairs -Theme $skippingTheme `
          -Message 'Skipping existing theme';
      }
    }

    $settingsObject.schemes = ($integratedSchemes | Sort-Object -Property name);

    Set-Content -Path $OutputPath -Value $($settingsObject | ConvertTo-Json);
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

  [System.Collections.Hashtable]$displayTheme = Get-KrayolaTheme -KrayolaThemeName $ThemeName;

  [System.Collections.Hashtable]$passThru = @{
    'BODY'          = 'import-ItermColors';
    'MESSAGE'       = 'Importing Terminal Scheme';
    'KRAYOLA-THEME' = $displayTheme;
    'ITEM-LABEL'    = 'Scheme filename';
    'PRODUCT-LABEL' = 'Scheme name';
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
