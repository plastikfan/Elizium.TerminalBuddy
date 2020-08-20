
function get-SortedFilesNatural {
<#
.NAME get-SortedFilesNatural

.SYNOPSIS
  Sort a collection of files from the pipeline in natural order.

.DESCRIPTION
  Sorts filenames in an order that makes sense to humans; ie 1 is followed by
	2 and not 10.

.PARAMETER InputObject
  Collection of files from pipeline to be sorted.

.EXAMPLE
  PS C:\> Get-SortedFolderNatural 'E:\Uni\audio'

.EXAMPLE
	PS C:\> gci E:\Uni\audio | Get-SortedFilesNatural
#>
  [Alias("SortFilesNatural")]
  param
  (
    [parameter(
      Mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true
    )]
    [System.Object[]]$InputObject
  )

  begin { $files = @() }

  process {
    foreach ($item in $InputObject) {
      $files += $item
    }
  }

  end { $files | Sort-Object { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) } }
}