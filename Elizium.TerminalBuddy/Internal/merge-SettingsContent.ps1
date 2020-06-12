function merge-SettingsContent {
  <#
  .NAME
    merge-SettingsContent

  .SYNOPSIS
    combines the new Content just generated with the existing Settings file.
    (used by ConvertFrom-ItermColors)

  .DESCRIPTION
  #>

  param(
    [Parameter()]
    [string]$Content,

    [Parameter()]
    [string]$SettingsPath,

    [Parameter()]
    [string]$OutputPath
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
    if (-not(test-DoesContainScheme -SchemeName $sch.name -Schemes $settingsSchemes)) {
      Write-ThemedPairsInColour -Pairs $pairs -Theme $integrationTheme `
        -Message 'Integrating new theme';
      $null = $integratedSchemes.Add($sch);
    }
    else {
      Write-ThemedPairsInColour -Pairs $pairs -Theme $skippingTheme `
        -Message 'Skipping existing theme';
    }
  }

  $settingsObject.schemes = ($integratedSchemes | Sort-Object -Property name);

  Set-Content -Path $OutputPath -Value $($settingsObject | ConvertTo-Json);
} # combineContent
