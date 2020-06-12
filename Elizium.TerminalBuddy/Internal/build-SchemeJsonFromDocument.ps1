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

function build-SchemeJsonFromDocument {
  <#
  .NAME
    build-SchemeJsonFromDocument

  .SYNOPSIS
    builds the json content representing all the schemes previously collated.
    (used by ConvertFrom-ItermColors)

  .DESCRIPTION
    Local function build-SchemeJsonFromDocument, processes an xml document for an
    iterm scheme. This format is not in a form particularly helpful for xpath
    expressions. The key and values are all present at the same level in the
    xml hierachy, so there is no direct relationship between the key and the value.
    All we can do is make an assumption that consecutive items are bound together
    by the key/value relationship. So these are processed as a result of 2 xpath
    expressions, the first selecting the keys (/plist/dict/key) and the other
    selecting the values (/plist/dict/dict) and we just make the assumption that
    the length of both result sets are the same and that items in the same position
    in their result sets are bound as a key/value pair.
  #>

  [OutputType([string])]
  param(
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

      [System.Collections.Hashtable]$kols = convertFrom-ColourComponents -AnsiColour $k `
        -ColourDictionary $colourDetails;
      [string]$colourHash = ConvertTo-RGB -Components $kols;
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
} # build-SchemeJsonFromDocument
