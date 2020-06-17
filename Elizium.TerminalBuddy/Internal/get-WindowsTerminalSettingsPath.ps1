
function get-WindowsTerminalSettingsPath {
  <#
  .NAME get-WindowsTerminalSettingsPath

  .SYNOPSIS
    Gets the windows terminal settings path.

  .DESCRIPTION
    If Windows terminal is not installed, this file won't exist, so
  empty string is returned.

  OUTPUTS
    Resolved windows well known Windows Terminal settings file path.
  #>
  [OutputType([string])]
  param()
  [string]$relativePath = '~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json';

  if (Test-Path -Path $relativePath) {
    return Resolve-Path -Path $relativePath;
  } else {
    return '';
  }
}
