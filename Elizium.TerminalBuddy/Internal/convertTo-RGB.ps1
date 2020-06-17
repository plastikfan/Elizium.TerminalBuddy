
[System.Collections.Hashtable]$script:ComponentNamingScheme = @{
  'RED_C'   = 'Red Component';
  'GREEN_C' = 'Green Component';
  'BLUE_C'  = 'Blue Component';
}

function ConvertTo-RGB {
  <#
  .NAME
    ConvertTo-RGB

  .SYNOPSIS
    creates the colour specification in hex code form.

  .OUTPUTS
  [string]
  Windows terminal compatible Hex string representation of the converted
  RGB values
  #>
  [OutputType([string])]
  param(
    [Parameter()]
    [System.Collections.Hashtable]$Components,

    [Parameter()]
    [System.Collections.Hashtable]$NamingScheme = $ComponentNamingScheme
  )

  [int]$R = $Components[$NamingScheme['RED_C']];
  [int]$G = $Components[$NamingScheme['GREEN_C']];
  [int]$B = $Components[$NamingScheme['BLUE_C']];

  # Terminal doesn't support Alpha values so let's ignore the Alpha component
  #
  return '#{0:X2}{1:X2}{2:X2}' -f $R, $G, $B;
} # ConvertTo-RGB
