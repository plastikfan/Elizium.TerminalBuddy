
function invoke-ForeachFile {
  <#
  .NAME invoke-ForeachFile

  .SYNOPSIS
    Performs iteration over a collection of files which are children of the directory
    specified by the caller.

  .DESCRIPTION
    Invoke an operation for each file found from the Path.
    (This needs to be refactored/redesigned to use the pipeline via InputObject as
    this is the idiomatic way to do this in PowerShell).

  .PARAMETER Path
    The parent directory to iterate.

  .PARAMETER Body
    The implementation script block that is to be implemented for each child file. The
    script block can either return $null or a PSCustomObject with fields Message(string) giving an
    indication of what was implemented, Product (string) which represents the item in question
    (ie the processed item as appropriate) and Colour(string) which is the console colour
    applied to the Product. Also, the Trigger should be set to true, if an action has been taken
    for any of the files iterated. This is so because if we iterate a collection of files, but the
    operation doesn't do anything to any of the files, then the whole operation should be considered
    a no-op, so we can keep output to a minimum.

  .PARAMETER PassThru
    The dictionary object used to pass parameters to the $Body scriptblock provided.

  .PARAMETER Filter
    The filter to apply to Get-ChildItem.

  .PARAMETER OnSummary
    A scriptblock that is invoked at the end of processing all processed files.
    (This still needs review; ie what can this provide that can't be as a result of
    invoking after calling invoke-ForeachFile).

  .PARAMETER Condition
    The result of Get-ChildItem is piped to a where statement whose condition is specified by
    this parameter. The (optional) scriptblock specified must be a predicate.

  .PARAMETER Inclusion
    Value that needs to be passed in into Get-ChildItem to additionally specify files
    in the include list.

  .OUTPUTS
    The collection of files iterated over.
  #>

  [CmdletBinding()]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
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
  [boolean]$trigger = $false;

  [System.Collections.Hashtable]$parameters = @{
    'Filter' = $Filter;
    'Path' = $Path;
  }

  $collection = & 'Get-ChildItem' @parameters | get-SortedFilesNatural | Where-Object {
    $Condition.Invoke($_);
  } | ForEach-Object {
    # Do the invoke
    #
    [PSCustomObject]$result = $Body.Invoke($_, $index, $PassThru, $trigger);

    # Handle the result
    #
    if ($result) {
      if (($result.psobject.properties['Trigger'] -and ($result.Trigger))) {
        $trigger = $true;
      }

      if (($result.psobject.properties['Break'] -and ($result.Break))) {
        break;
      }
    }

    $index++;
  } # ForEach-Object

  return $collection;
}
