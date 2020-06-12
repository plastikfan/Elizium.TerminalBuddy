
[System.Collections.Hashtable]$ComponentNamingScheme = @{
  'RED_C'   = 'Red Component';
  'GREEN_C' = 'Green Component';
  'BLUE_C'  = 'Blue Component';
}
# Local function ConvertTo-RGB, creates the colour specification in hex code form.
#
function ConvertTo-RGB {
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
