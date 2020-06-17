
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
      1) generate an Output file (denoted by $Out parameter), which will contain a JSON
      object containing the colour schemes converted from iterm to Windows Terminal
      format.
      2) generate a new Dry Run file which is a copy of the current Windows Terminal
      Settings file with the converted schemes integrated into it.
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
    (probably in lieu of there not being a proper settings UI, making configuring the settings
    easier). However, comments are not part of the current JSON schema (although they are
    permitted in the rarely and sparsely supported json5 spec), which means that this conversion
    process will not preserve the comments. There is an alternative api that supposedly supports
    non standard JSON features, newtonsoft.json.ConvertTo-JsonNewtonsoft/ConvertFrom-JsonNewtonsoft
    but using these functions yield unsatisfactory results.
      2) ConvertFrom-Json/Converto-Json do not properly handle the profiles

  .PARAMETER Path
    The path containing the iterm scheme files. If this refers to a directory, then a Filter
  should be specified to identify the files. This Path can also just refer directly to an
  individual file, in which case, no Filter is required.

  .PARAMETER Filter
    When Path refers to a directory, use Filter to specify files. A * can be used
    as a wildcard.

  .PARAMETER Out    When Path refers to a directory, use Filter to specify files. A * can be used
    as a wildcard.
    The output file written to with the JSON represented the converted iterm themes. This
    content is is just a fragment of the settings file, in fact it's a JSON object which
    contains a single member named 'schemes' (after the corresponding entry in the
    Windows Terminal Settings file.) which is set to an array of scheme objects.

  .PARAMETER SaveTerminalSettings
    Switch, to indicate that the converted schemes should be saved into a complete settings
    file. Which settings file depends on the presence of the Force parameter. If Force is
    present, the the LiveSettingsFile path is used, otherwise the DryRunFile path is used.

  .PARAMETER Force
    Switch to indicate whether live settings should be modified to include generated schemes.
    To avoid accidental invocation, needs to be used in addition to SaveTerminalSettings.

  .PARAMETER LiveSettingsFile
    Well known path to the current windows terminal settings file. This is assumed to of
    the well known path. This can be overridden by the user if so required (just in case it's
    located elsewhere).

  .PARAMETER DryRunFile
    When run in Dry Run mode (by default), this is the path of the file written to.
    It will contain a merge of the current Windows Terminal Settings file and newly generated
    schemes as converted from iterm files specified by the $Path.

  .PARAMETER BackupFile
    When not in Dry Run mode ($Force and $SaveTerminalSettings specified), this parameter
    specifies the path to backup the live Windows Terminal Settings file to.

  .PARAMETER ThemeName
    The name of a Krayola Theme, that has been configured inside the global $KrayolaThemes
    hashtable variable. If not present, then an internal theme is used. The Krayola Theme
    shapes how output of this command is generated to the console.

  .PARAMETER PseudoSettingsFile
    This file is only required because of certain caveats of the current implementation, owing
    to Microsoft's choice in not using standard JSON file. In the interests of safety, instead
    of integrating new schemes into the LiveSettingsFile, PseudoSettingsFile specifies the file
    used instead of overwriting LiveSettingsFile. This function will indicating that the schemes
    should be manually copied over at the end of the run.

  .EXAMPLE
    ConvertFrom-ItermColors -Path 'C:\shared\Themes\ITerm2\Schemes\Banana Blueberry.itermcolors'
      -Out ~/terminal-settings.single.output.json

  .EXAMPLE
    ConvertFrom-ItermColors -Path C:\shared\Themes\ITerm2\Schemes -Filter "B*.itermcolors"
      -Out ~/terminal-settings.output.json

  .EXAMPLE
    ConvertFrom-ItermColors -Path 'C:\shared\Themes\ITerm2\Schemes\Banana Blueberry.itermcolors'
      -SaveTerminalSettings

  .EXAMPLE
    ConvertFrom-ItermColors -Path C:\shared\Themes\ITerm2\Schemes\ -Filter 'B*.itermcolors'
      -SaveTerminalSettings
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseBOMForUnicodeEncodedFile', '')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
  [Alias('cfic', 'Make-WtSchemesIC')]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateScript( { return Test-Path $_ })]
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
    [string]$DryRunFile = '~/Windows.Terminal.dry-run.settings.json',

    [Parameter(Mandatory = $false)]
    [ValidateScript( { return -not(Test-Path $_ -PathType 'Leaf') })]
    [string]$BackupFile = "~/Windows.Terminal.back-up.settings.json",

    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string]$ThemeName,

    [Parameter(Mandatory = $false)]
    [string]$LiveSettingsFile = $(get-WindowsTerminalSettingsPath),

    [Parameter(Mandatory = $false)]
    [string]$PseudoSettingsFile = '~/Windows.Terminal.pseudo.settings.json'
  )

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
      [string]$outputContent = join-AllSchemas -Schemes $accumulator;

      [string]$copyFromOutputUserHint = [string]::Empty;

      if ($SaveTerminalSettings.ToBool()) {
        if ($Force.ToBool()) {
          # Backup file (NB, WhatIf is set because the force write is not going into effect)
          #
          Copy-Item -Path $(Resolve-Path -Path $LiveSettingsFile) -Destination $BackupFile -WhatIf;

          # This line should be using get-WindowsTerminalSettingsPath as the OutputPath,
          # but this is being avoided until (if ever) a reliable way of reading and writing
          # JSON comments is found. Until that happens, the recommended user scenario is to use
          # SaveTerminalSettings without the Force switch and then subsquently manually copy the
          # scehemes from the generated Dry Run file to the real Settings file.
          #
          $copyFromOutputUserHint = $PseudoSettingsFile;
          merge-SettingsContent -Content $outputContent -SettingsPath $LiveSettingsFile `
            -OutputPath $PseudoSettingsFile;
        } else {
          $copyFromOutputUserHint = $DryRunFile;
          merge-SettingsContent -Content $outputContent -SettingsPath $LiveSettingsFile `
            -OutputPath $DryRunFile;
        }
      } else {
        $copyFromOutputUserHint = $out;
        Set-Content -Path $Out -Value $outputContent;
      }

      if (-not([string]::IsNullOrWhiteSpace($copyFromOutputUserHint))) {
        [System.Collections.Hashtable]$userHintTheme = Get-KrayolaTheme;
        $userHintTheme['VALUE-COLOURS'] = @(, @('Green'));
        [string[][]]$notice = @(, @('generated file', $copyFromOutputUserHint));

        Write-ThemedPairsInColour -Pairs $notice -Theme $userHintTheme `
          -Message 'Manual intervention notice !!!, Please open';

        [string[][]]$pasteSchemes = @(, @('Windows Terminal Settings file', $LiveSettingsFile));

        Write-ThemedPairsInColour -Pairs $pasteSchemes -Theme $userHintTheme `
          -Message 'Copy & paste "schemes" into';
      }
    }
  }
} # ConvertFrom-ItermColors
