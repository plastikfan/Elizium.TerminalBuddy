
function import-ItermColors {

  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
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

  function handleColourSpecification {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param (
      $AnsiColour,
      $ColourDictionary
    )

    if ($PSCmdlet.ShouldProcess($AnsiColour, 'Import colour')) {
      if ($ColourDictionary) {

      }
    }
  }

  # This is the body of the implementation that needs to be invoked to
  # read the xml file and do the conversion to json
  #
  [string]$randomValue = "{THIS IS GOING TO BE SOME JSON, $Index, $Trigger}";

  [System.Collections.Hashtable]$terminalThemes = @{};
  if ($passthru.ContainsKey("ACCUMULATOR")) {
    $terminalThemes = $passthru["ACCUMULATOR"];
  } else {
    $passthru["ACCUMULATOR"] = $terminalThemes;
  }
  $terminalThemes[$Underscore.Name] = $randomValue;

  [System.Xml.XmlDocument]$document = [xml]@(Get-Content -Path $Underscore.Fullname);

  if ($document) {
    # Get the top level dictionary (/dict)
    #
    $colourKeys = Select-Xml -Xml $document -XPath '/plist/dict/key';
    $colourDict = Select-Xml -Xml $document -XPath '/plist/dict/dict';

    [int]$colourIndex = 0;
    if ($colourKeys.Count -eq $colourDict.Count) {
      foreach ($k in $colourKeys) {
        $colourDetails = $colourDict[$colourIndex];
        [string]$themeName = $k.Node;
        Write-Host "===> Importing theme: $themeName";

        # https://vexx32.github.io/2018/11/22/Implementing-ShouldProcess/
        if ($PSCmdlet.ShouldProcess($Underscore.Name, 'Import themes into Terminal Settings')) {
          handleColourSpecification -AnsiColour $k -ColourDictionary $colourDetails -WhatIf:$Whatif;
        } else {

        }
      }

      $colourIndex++;
    }
  }
}
