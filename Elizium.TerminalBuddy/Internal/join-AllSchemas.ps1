function join-AllSchemas {
  <#
  .NAME join-AllSchemas

  .SYNOPSIS
    Builds the json content representing all the schemes previously collated.

  .DESCRIPTION
    Used by ConvertFrom-ItermColors.

  .PARAMETER Schemes
    Hastable of scheme names to their JSON string representations.

  .OUTPUTS
  [string]
  JSON string reprentation of all built schemas as members of the schemes
  array property.
  #>

  [OutputType([string])]
  param(
    [Parameter()]
    [System.Collections.Hashtable]$Schemes
  )

  [string]$outputContent = '{ "schemes": [';
  [string]$close = '] }';

  [System.Collections.IDictionaryEnumerator]$enumerator = $Schemes.GetEnumerator();

  if ($Schemes.Count -gt 0) {
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
}
