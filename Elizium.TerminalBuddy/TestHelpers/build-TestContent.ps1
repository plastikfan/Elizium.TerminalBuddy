
function build-TestContent {
  [OutputType([string])]
  param(
    [string[]]$JsonSchemes
  )

  [string]$outputContent = '{ "schemes": [';
  foreach ($scheme in $JsonSchemes) {
    $outputContent += $scheme;
    $outputContent += ',';
  }

  [int]$last = $outputContent.LastIndexOf(',');
  $outputContent = $outputContent.Substring(0, $last);

  [string]$close = '] }';
  $outputContent += $close;
  $outputContent = $outputContent | ConvertFrom-Json | ConvertTo-Json;

  return $outputContent;
}
