
[System.Collections.Hashtable]$ItermTerminalColourMap = @{
  # As defined in https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
  #
  "Ansi 0 Color"      = "black";
  "Ansi 1 Color"      = "red";
  "Ansi 2 Color"      = "green";
  "Ansi 3 Color"      = "yellow";
  "Ansi 4 Color"      = "blue";
  "Ansi 5 Color"      = "purple"; # magenta
  "Ansi 6 Color"      = "cyan";
  "Ansi 7 Color"      = "white";
  "Ansi 8 Color"      = "brightBlack";
  "Ansi 9 Color"      = "brightRed";
  "Ansi 10 Color"     = "brightGreen";
  "Ansi 11 Color"     = "brightYellow";
  "Ansi 12 Color"     = "brightBlue";
  "Ansi 13 Color"     = "brightPurple"; # bright magenta
  "Ansi 14 Color"     = "brightCyan";
  "Ansi 15 Color"     = "brightWhite";

  # https://docs.microsoft.com/en-gb/windows/terminal/customize-settings/color-schemes
  #
  "Background Color"  = "background";
  "Foreground Color"  = "foreground";
  "Cursor Text Color" = "cursorColor";
  "Selection Color"   = "selectionBackground";

  # Iterm colours discovered but not not mapped (to be logged out in verbose mode)
  #
  # Bold Color
  # Link Color
  # Cursor Guide Color
  # Badge Color
}

[System.Collections.Hashtable]$ComponentNamingScheme = @{
  "RED_C"   = "Red Component";
  "GREEN_C" = "Green Component";
  "BLUE_C"  = "Blue Component";
}

function import-ItermColors {

  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
  [CmdletBinding()] # SupportsShouldProcess, ConfirmImpact = 'Medium'
  param (
    [Parameter(
      Mandatory = $true
      # Position = 0
    )]
    [System.IO.FileSystemInfo]$Underscore,

    [Parameter(
      Mandatory = $true
      # Position = 1
    )]
    [int]$Index,

    [Parameter(
      Mandatory = $true
      # Position = 2
    )]
    [System.Collections.Hashtable]$PassThru,

    [Parameter(
      Mandatory = $false
      # Position = 3
    )]
    [boolean]$Trigger
  )

  function handleColourComponents {
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()] # SupportsShouldProcess, ConfirmImpact = 'Medium'
    param (
      [Parameter()]
      [Microsoft.PowerShell.Commands.SelectXmlInfo]$AnsiColour,

      [Parameter()]
      [Microsoft.PowerShell.Commands.SelectXmlInfo]$ColourDictionary
    )

    # if ($PSCmdlet.ShouldProcess($AnsiColour, 'Import colour')) {
    #   Write-Host "LET'S DO IT";
    # } else {
    #   Write-Host "NAH, FORGET IT";
    # }

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
        $colourComponents[$key] = [int][math]::Ceiling($numeric * 255);
      }
    } while ($node);

    return $colourComponents;
  } # handleColourComponents
  function toRGB {
    [OutputType([string])]
    param(
      [Parameter()]
      [System.Collections.Hashtable]$Components,

      [Parameter()]
      [System.Collections.Hashtable]$NamingScheme = $ComponentNamingScheme
    )

    [int]$R = $Components[$NamingScheme["RED_C"]];
    [int]$G = $Components[$NamingScheme["GREEN_C"]];
    [int]$B = $Components[$NamingScheme["BLUE_C"]];

    # Terminal doesn't support Alpha values so let's ignore the Alpha component
    #
    return "#{0:X2}{1:X2}{2:X2}" -f $R, $G, $B;
  } # toRGB

  function buildSchemeJsonFromDocument {
    [OutputType([string])]
    param(
      [Parameter()]
      [string]$ThemeName,

      [Parameter()]
      [System.Xml.XmlDocument]$XmlDocument
    )

    # Get the top level dictionary (/dict)
    #
    $colourKeys = Select-Xml -Xml $document -XPath '/plist/dict/key';
    $colourDict = Select-Xml -Xml $document -XPath '/plist/dict/dict';

    [int]$colourIndex = 0;
    if ($colourKeys.Count -eq $colourDict.Count) {
      # https://powershellexplained.com/2016-10-28-powershell-everything-you-wanted-to-know-about-pscustomobject/
      #
      [PSCustomObject]$colourScheme = [PSCustomObject]@{
        name = [System.IO.Path]::GetFileNameWithoutExtension($Underscore.Name)
      }

      foreach ($k in $colourKeys) {
        $colourDetails = $colourDict[$colourIndex];
        [string]$colourName = $k.Node.InnerText;
        
        # https://vexx32.github.io/2018/11/22/Implementing-ShouldProcess/
        [System.Collections.Hashtable]$kols = handleColourComponents -AnsiColour $k -ColourDictionary $colourDetails;
        [string]$colourHash = toRGB -Components $kols;
        $colourIndex++;

        if ($ItermTerminalColourMap.ContainsKey($colourName)) {
          $colourScheme | Add-Member -MemberType 'NoteProperty' `
            -Name $ItermTerminalColourMap[$colourName] -Value "$colourHash";
        }
        else {
          Write-Warning "Skipping un-mapped colour: $colourName";
        }
      }

      [string]$jsonColourScheme = ConvertTo-Json -InputObject $colourScheme;

      Write-Host "$jsonColourScheme";

      return $jsonColourScheme;
    }
  } # buildSchemeJsonFromDocument

  [PSCustomObject]$result = [PSCustomObject]@{}

  [System.Collections.Hashtable]$terminalThemes = @{};
  if ($PassThru.ContainsKey('ACCUMULATOR')) {
    $terminalThemes = $PassThru["ACCUMULATOR"];
    Write-Host "Found the ACCUMULATOR with $($terminalThemes.Count) items";
  } else {
    Write-Host "Creating new ACCUMULATOR ";
    $PassThru['ACCUMULATOR'] = $terminalThemes;
  }
  
  [System.Xml.XmlDocument]$document = [xml]@(Get-Content -Path $Underscore.Fullname);

  if ($document) {
    [string]$terminalTheme = buildSchemeJsonFromDocument -ThemeName $Underscore.Name -XmlDocument $document;

    if (-not([string]::IsNullOrEmpty($terminalTheme))) {
      $result | Add-Member -MemberType NoteProperty -Name 'Trigger' -Value $true;
    }
    $terminalThemes[$Underscore.Name] = $terminalTheme;

    $PassThru['ACCUMULATOR'] = $terminalThemes;
  }

  return $result
} # import-ItermColors
