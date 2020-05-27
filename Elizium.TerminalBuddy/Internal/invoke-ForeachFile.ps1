
function invoke-ForeachFile {
  <#
  .NAME
    invoke-ForeachFile

  .SYNOPSIS
    Performs iteration over a collection of files which are children of the directory
    specified by the caller.

  .PARAMETER $Path
    The parent directory to iterate

  .PARAMETER $LiteralPath
    The parent directory to iterate

  .PARAMETER $Body
    The implementation script block that is to be implemented for each child file. The
    script block can either return $null or a PSCustomObject with fields Message(string) giving an
    indication of what was implemented, Product (string) which represents the item in question
    (ie the processed item as approriapte) and Colour(string) which is the console colour
    applied to the Product. Also, the Trigger should be set to true, if an action has been taken
    for any of the files iterated. This is so because if we iterate a collection of files, but the
    operation doesnt do anything to any of the files, then the whole operation should be considered
    a no-op, so we can keep output to a minimum.

  .PARAMETER $PassThru
    The dictionary object used to pass parameters to the $Body scriptblock provided.

  .PARAMETER $Filter
    The filter to apply to Get-ChildItem

  .PARAMETER $OnSummary
    A scriptblock that is invoked at the end of processing all processed files.
    (This still needs review; ie what can this provide that can't be as a result of
    invoking after calling invoke-ForeachFile)

  .PARAMETER $Condition
    The result of Get-ChildItem is piped to a where statement whose condition is specified by
    this parameter. The (optional) scriptblock specified must be a predicate.

  .PARAMETER $Inclusion
    Value that needs to be passed in into Get-ChildItem to additionally specify files
    in the include list.

  .PARAMETER $eachItemLine (THIS SHOULD GO INTO WRTE-HOST DECORATOR)
    The line type to display after each directory iteration.

  .PARAMETER $endOfProcessingLine (THIS SHOULD GO INTO WRTE-HOST DECORATOR)
    The line type to display at the end of the directory iteration.

  .PARAMETER $Verb (THIS IS SUPOSED TO BE VERBOSE); NO LONGER REQUITED / CmdletBinding
    Flag to indicate wether any output is generated for each file. Any output generated at a
    file level may become too much depending on the compound functionality implemented.

  .RETURNS
    Number of files found.
  #>

  [CmdletBinding()]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
  param
  (
    [Parameter(
      Mandatory = $true
    )]
    [string]$Path,

    [Parameter(
      Mandatory = $true
    )]
    [scriptblock]$Body,

    [Parameter(
      Mandatory = $false
    )]
    [System.Collections.Hashtable]$PassThru,

    [Parameter(
      Mandatory = $false
    )]

    [string]$Filter = '*',

    [Parameter(
      Mandatory = $false
    )]
    [scriptblock]$Condition = ( { return $true; })
  )

  [int]$index = 0;
  [boolean]$isVerbose = $false;
  [boolean]$trigger = $false;

  [System.Collections.Hashtable]$parameters = @{
    'Filter' = $Filter;
    'Path' = $Path;
  }

  & 'Get-ChildItem' @parameters | get-SortedFilesNatural | Where-Object {
    $Condition.Invoke($_);
  } | ForEach-Object {
    if ($isVerbose) {
      # TODO: CHANGE THIS:
      #
      Write-Verbose $eachItemLine -ForegroundColor $LineColour;
    }

    # Do the invoke
    #
    [PSCustomObject]$result = $Body.Invoke($_, $index, $PassThru, $trigger);

    # Handle the result
    #
    if ($result) {
      if (($result.psobject.properties.match('Trigger') -and ($result.Trigger))) {
        $trigger = $true;
      }

      if (($result.psobject.properties.match('Break') -and ($result.Break))) {
        break;
      }
    }

    $index++;
  } # ForEach-Object

  return $collection;
}
