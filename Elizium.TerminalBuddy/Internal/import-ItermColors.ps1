function import-ItermColors {
  <#
  .NAME
    import-ItermColors

  .SYNOPSIS
    imports XML data from iterm file and converts to JSON format.

  .DESCRIPTION
    This function behaves like a reducer, because it populates an Accumulator
  collection for each file it is presented with.

  .PARAMETER $Underscore
    fileinfo object representing the .itermcolors file.

  .PARAMETER $Index
    0 based numeric index specifing the ordinal of the file in the batch.

  .PARAMETER $PassThru
    The dictionary object containing additional parameters. Also used by
  this function to append it's result to an 'ACCUMULATOR' hash (indexed
  by scheme name), which ultimately allows all the schemes to be collated
  into the 'schemes' array field in the settings file.

  .PARAMETER $Trigger

  .RETURNS
    The result of invoking the BODY script block.
  #>

  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
  [OutputType([PSCustomObject])]
  [CmdletBinding()]
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
    [System.Collections.Hashtable]$PassThru,

    [Parameter(
      Mandatory = $false
    )]
    [boolean]$Trigger
  )

  [PSCustomObject]$result = [PSCustomObject]@{}

  [System.Collections.Hashtable]$terminalThemes = @{};
  if ($PassThru.ContainsKey('ACCUMULATOR')) {
    $terminalThemes = $PassThru['ACCUMULATOR'];
  } else {
    $PassThru['ACCUMULATOR'] = $terminalThemes;
  }

  [System.Xml.XmlDocument]$document = [xml]@(Get-Content -Path $Underscore.Fullname);

  if ($document) {
    [string]$terminalTheme = build-SchemeJsonFromDocument -XmlDocument $document;

    if (-not([string]::IsNullOrWhiteSpace($terminalTheme))) {
      $result | Add-Member -MemberType NoteProperty -Name 'Trigger' -Value $true;

      [string]$product = [System.IO.Path]::GetFileNameWithoutExtension($_.Name);
      $result | Add-Member -MemberType NoteProperty -Name 'Product' -Value $product;
    }
    $terminalThemes[$Underscore.Name] = $terminalTheme;

    $PassThru['ACCUMULATOR'] = $terminalThemes;
  }

  return $result
} # import-ItermColors
