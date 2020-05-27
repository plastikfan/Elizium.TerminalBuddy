
function get-Theme {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseBOMForUnicodeEncodedFile", "")]
  [OutputType([System.Collections.Hashtable])]
  param (
    [Parameter(
      Mandatory = $false,
      Position = 0
    )]
    [AllowEmptyString()]
    [string]$KrayolaTheme
  )

  [System.Collections.Hashtable]$displayTheme = @{ # TODO: change this to something useful
    "FORMAT"             = "'<%KEY%>' --> '<%VALUE%>'";
    "KEY-PLACE-HOLDER"   = "<%KEY%>";
    "VALUE-PLACE-HOLDER" = "<%VALUE%>";
    "KEY-COLOURS"        = @("DarkCyan");
    "VALUE-COLOURS"      = @("Gray");
    "OPEN"               = "◄◄◄ <";
    "CLOSE"              = "> ►►►";
    "SEPARATOR"          = ", ";
    "META-COLOURS"       = @("Yellow");
    "MESSAGE-COLOURS"    = @("Cyan");
    "MESSAGE-SUFFIX"     = " // ";
  }

  if ([string]::IsNullOrEmpty($KrayolaTheme)) {
    [string]$themeName = [System.Environment]::GetEnvironmentVariable('KRAYOLA-THEME-NAME');

    if (-not ([string]::IsNullOrEmpty($themeName))) {
      if ($KrayolaThemes -and $KrayolaThemes.ContainsKey($themeName)) {
        $displayTheme = $KrayolaThemes[$themeName];
      }
    }
  } else {
    $displayTheme = $KrayolaTheme
  }

  return $displayTheme;
}
