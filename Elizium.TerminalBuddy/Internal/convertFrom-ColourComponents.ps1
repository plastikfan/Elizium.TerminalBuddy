
function convertFrom-ColourComponents {
  <#
  .NAME
    convertFrom-ColourComponents

  .DESCRIPTION
    Local function convertFrom-ColourComponents, given an ANSI colour
    (eg 'Ansi 1 Color') and a dictionary of colour definitions as real
    numbers, creates a hash table of the colour component name, to colour
    value.

  .OUTPUTS
    [Hastable]
    Maps from component colour name and converted colour value.
  #>
  [OutputType([System.Collections.Hashtable])]
  [CmdletBinding()]
  param (
    [Parameter()]
    [Microsoft.PowerShell.Commands.SelectXmlInfo]$ColourDictionary
  )

  [System.Collections.Hashtable]$colourComponents = @{};
  $node = $ColourDictionary.Node.FirstChild;
  do {
    # Handle 2 items at a time, first is key, second is real colour value
    #
    [string]$key = $node.InnerText;
    $node = $node.NextSibling;
    [string]$val = $node.InnerText;
    $node = $node.NextSibling;

    [float]$numeric = 0;
    if ([float]::TryParse($val, [ref]$numeric)) {
      $colourComponents[$key] = [int][math]::Round($numeric * 255);
    }
  } while ($node);

  return $colourComponents;
} # convertFrom-ColourComponents
