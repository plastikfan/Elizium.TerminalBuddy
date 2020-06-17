
function test-DoesContainScheme {
  <#
  .NAME
    test-DoesContainScheme

  .SYNOPSIS
    Predicate that returns true if SchemeName is present in the Schemes collection.

  .DESCRIPTION
    Used by ConvertFrom-ItermColors.

  .PARAMETER SchemeName
    Name of the scheme to search for.

  .PARAMETER Schemes
    0 based numeric index specifying the ordinal of the iterated target.

  .OUTPUTS
  [boolean]
    true if Schemes contains SchemeName, false otherwise
  #>
  [OutputType([boolean])]
  param(
    [Parameter()]
    [string]$SchemeName,

    [Parameter()]
    [object[]]$Schemes
  )

  # The assignment to $null because of a bug in PSScriptAnalyzer
  # https://github.com/PowerShell/PSScriptAnalyzer/issues/1472
  #
  $null = $SchemeName;
  $found = $Schemes | Where-Object { $_.name -eq $SchemeName };

  return ($null -ne $found);
}
