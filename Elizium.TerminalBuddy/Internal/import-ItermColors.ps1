
[System.Collections.Hashtable]$ItermTerminalColourMap = @{
  # As defined in https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
  #
  'Ansi 0 Color'      = 'black';
  'Ansi 1 Color'      = 'red';
  'Ansi 2 Color'      = 'green';
  'Ansi 3 Color'      = 'yellow';
  'Ansi 4 Color'      = 'blue';
  'Ansi 5 Color'      = 'purple'; # magenta
  'Ansi 6 Color'      = 'cyan';
  'Ansi 7 Color'      = 'white';
  'Ansi 8 Color'      = 'brightBlack';
  'Ansi 9 Color'      = 'brightRed';
  'Ansi 10 Color'     = 'brightGreen';
  'Ansi 11 Color'     = 'brightYellow';
  'Ansi 12 Color'     = 'brightBlue';
  'Ansi 13 Color'     = 'brightPurple'; # bright magenta
  'Ansi 14 Color'     = 'brightCyan';
  'Ansi 15 Color'     = 'brightWhite';

  # https://docs.microsoft.com/en-gb/windows/terminal/customize-settings/color-schemes
  #
  'Background Color'  = 'background';
  'Foreground Color'  = 'foreground';
  'Cursor Text Color' = 'cursorColor';
  'Selection Color'   = 'selectionBackground';

  # Iterm colours discovered but not not mapped (to be logged out in verbose mode)
  #
  # Bold Color
  # Link Color
  # Cursor Guide Color
  # Badge Color
}

[System.Collections.Hashtable]$ComponentNamingScheme = @{
  'RED_C'   = 'Red Component';
  'GREEN_C' = 'Green Component';
  'BLUE_C'  = 'Blue Component';
}

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

  # Local function handleColourComponents, given an ANSI colour (eg 'Ansi 1 Color') and
  # a dictionary of colour definitions as real numbers, creates a hash table of the
  # colour component name, to colour value.
  #
  function handleColourComponents {
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    param (
      [Parameter()]
      [Microsoft.PowerShell.Commands.SelectXmlInfo]$AnsiColour,

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
  } # handleColourComponents

  # Local function toRGB, creates the colour specification in hex code form.
  #
  function toRGB {
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
  } # toRGB

  # Local function buildSchemeJsonFromDocument, processes an xml document for an
  # iterm scheme. This format is not in a form particularly helpful for xpath
  # expressions. The key and values are all present at the same level in the
  # xml hierachy, so there is no direct relationship between the key and the value.
  # All we can do is make an assumption that consecutive items are bound together
  # by the key/value relationship. So these are processed as a result of 2 xpath
  # expressions, the first selecting the keys (/plist/dict/key) and the other
  # selecting the values (/plist/dict/dict) and we just make the assumption that
  # the length of both result sets are the same and that items in the same position
  # in their result sets are bound as a key/value pair.
  #
  function buildSchemeJsonFromDocument {
    [OutputType([string])]
    param(
      # [Parameter()]
      # [string]$ThemeName,

      [Parameter()]
      [System.Xml.XmlDocument]$XmlDocument
    )

    # Get the top level dictionary (/dict)
    #
    $colourKeys = Select-Xml -Xml $document -XPath '/plist/dict/key';
    $colourDict = Select-Xml -Xml $document -XPath '/plist/dict/dict';

    [int]$colourIndex = 0;
    if ($colourKeys.Count -eq $colourDict.Count) {
      [PSCustomObject]$colourScheme = [PSCustomObject]@{
        name = [System.IO.Path]::GetFileNameWithoutExtension($Underscore.Name)
      }

      foreach ($k in $colourKeys) {
        $colourDetails = $colourDict[$colourIndex];
        [string]$colourName = $k.Node.InnerText;

        [System.Collections.Hashtable]$kols = handleColourComponents -AnsiColour $k `
          -ColourDictionary $colourDetails;
        [string]$colourHash = toRGB -Components $kols;
        $colourIndex++;

        if ($ItermTerminalColourMap.ContainsKey($colourName)) {
          $colourScheme | Add-Member -MemberType 'NoteProperty' `
            -Name $ItermTerminalColourMap[$colourName] -Value "$colourHash";
        }
        else {
          Write-Verbose "Skipping un-mapped colour: $colourName";
        }
      }

      [string]$jsonColourScheme = ConvertTo-Json -InputObject $colourScheme;

      Write-Verbose "$jsonColourScheme";

      return $jsonColourScheme;
    }
  } # buildSchemeJsonFromDocument

  [PSCustomObject]$result = [PSCustomObject]@{}

  [System.Collections.Hashtable]$terminalThemes = @{};
  if ($PassThru.ContainsKey('ACCUMULATOR')) {
    $terminalThemes = $PassThru['ACCUMULATOR'];
  } else {
    $PassThru['ACCUMULATOR'] = $terminalThemes;
  }

  [System.Xml.XmlDocument]$document = [xml]@(Get-Content -Path $Underscore.Fullname);

  if ($document) {
    # -ThemeName $Underscore.Name
    [string]$terminalTheme = buildSchemeJsonFromDocument -XmlDocument $document;

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
