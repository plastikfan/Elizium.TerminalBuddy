function join-AllSchemas {
  <#
  .NAME
    join-AllSchemas

  .SYNOPSIS
    builds the json content representing all the schemes previously collated.
    (used by ConvertFrom-ItermColors)

  .DESCRIPTION
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
