Describe 'join-AllSchemas' {
  BeforeAll {
    Get-Module Elizium.TerminalBuddy | Remove-Module
    Import-Module .\Elizium.TerminalBuddy\Elizium.TerminalBuddy.psm1 -ErrorAction 'stop' -DisableNameChecking
  }

}