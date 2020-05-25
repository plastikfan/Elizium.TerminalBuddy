<#
.SYNOPSIS
  Sort a collection of files from the pipeline in natural order

.DESCRIPTION
  Sorts filenames in an order that makes sense to humans; ie 1 is followed by
	2 and not 10.

.PARAMETER $Pipeline
    collection of files from pipeline to be sorted

.EXAMPLE
	PS C:\> Get-SortedFolderNatural 'E:\Uni\audio'
	PS C:\> gci E:\Uni\audio | Get-SortedFilesNatural

.NOTES
	Author: Plastikfan
#>

function get-SortedFilesNatural {
  [Alias("SortFilesNatural")]
  param
  (
    [parameter(
      Mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true
    )]
    [System.Object[]]$Pipeline
  )

  begin { $files = @() }

  process {
    foreach ($item in $Pipeline) {
      $files += $item
    }
  }

  end { $files | Sort-Object { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) } }
}