Describe 'ConvertFrom-ItermColors' {
  BeforeAll {
    Get-Module Elizium.TerminalBuddy | Remove-Module
    Import-Module .\Elizium.TerminalBuddy\Output\Elizium.TerminalBuddy\Elizium.TerminalBuddy.psm1 `
      -ErrorAction 'stop' -DisableNameChecking
  }

  Context 'Out file mode' {
    Context 'Given: valid .itermcolors (Banana Blueberry) file' {
      It 'Should: convert to terminal settings format and write to "Out" file' {
        [string]$outputPath = "TestDrive:\terminal-settings.output.json";
        ConvertFrom-ItermColors -LiveSettingsFile './Tests/Data/windows-terminal.live.settings.json' `
          -Path './Tests/Data/Banana Blueberry.itermcolors' -Out $outputPath;

        $result = Get-Content -Path $outputPath | ConvertFrom-Json;
        $result.schemes | Should -Not -BeNullOrEmpty;
        $result.schemes.Count | Should -Be 1;
        $bananaBlueberry = $result.schemes[0];
        $bananaBlueberry.name | Should -Be "Banana Blueberry";
      }
    }

    Context 'Given: mutiple (x2) valid .itermcolors files' {
      It 'Should: convert to terminal settings format and write to "Out" file' {
        [string]$outputPath = "TestDrive:\terminal-settings.output.json";
        ConvertFrom-ItermColors -LiveSettingsFile './Tests/Data/windows-terminal.live.settings.json' `
          -Path './Tests/Data' -Filter 'B*.itermcolors' -Out $outputPath;

        $result = Get-Content -Path $outputPath | ConvertFrom-Json;
        $result.schemes | Should -Not -BeNullOrEmpty;
        $result.schemes.Count | Should -Be 2;
        $bananaBlueberry = $result.schemes[0];
        $bananaBlueberry.name | Should -Be "Banana Blueberry";
      }
    }
  } # Out file mode

  Context 'Dry run mode' {
    Context 'Given: valid .itermcolors (Banana Blueberry) file' {
      It 'Should: convert to terminal settings format and integrate into "DryRun" file' {
        [string]$outputPath = "TestDrive:\terminal-settings.dry-run.json";
        ConvertFrom-ItermColors -LiveSettingsFile './Tests/Data/windows-terminal.live.settings.json' `
          -Path './Tests/Data/Banana Blueberry.itermcolors' -SaveTerminalSettings `
          -DryRunFile $outputPath;

        $result = Get-Content -Path $outputPath | ConvertFrom-Json;
        $result.schemes | Should -Not -BeNullOrEmpty;
        $result.schemes.Count | Should -Be 13;
        $bananaBlueberry = $result.schemes | Where-Object { $_.name -eq 'Banana Blueberry' }
        $bananaBlueberry.name | Should -Not -BeNullOrEmpty;
      }
    }

    Context 'Given: a scheme (Cyberdyne) already present in settings file' {
      It 'Should: not integrate any new schemes' {
        [string]$outputPath = "TestDrive:\terminal-settings.dry-run.json";
        ConvertFrom-ItermColors -LiveSettingsFile './Tests/Data/windows-terminal.live.settings.json' `
          -Path './Tests/Data/Cyberdyne.itermcolors' -SaveTerminalSettings `
          -DryRunFile $outputPath;

        $result = Get-Content -Path $outputPath | ConvertFrom-Json;
        $result.schemes | Should -Not -BeNullOrEmpty;
        $result.schemes.Count | Should -Be 12; # Same no of schemes in original
      }
    }
  } # Dry run mode

  Context 'Live settings file mode' {
    Context 'Given: valid .itermcolors (Banana Blueberry) file' {
      It 'Should: convert to terminal settings format and integrate into alternative "Live" file' {
        [string]$outputPath = "TestDrive:\terminal-settings.live.json";
        ConvertFrom-ItermColors -LiveSettingsFile './Tests/Data/windows-terminal.live.settings.json' `
          -Path './Tests/Data/Banana Blueberry.itermcolors' -SaveTerminalSettings `
          -BackupFile 'TestDrive:\windows-terminal.back-up.settings.json' `
          -PseudoSettingsFile $outputPath -Force;

        $result = Get-Content -Path $outputPath | ConvertFrom-Json;
        $result.schemes | Should -Not -BeNullOrEmpty;
        $result.schemes.Count | Should -Be 13;
        $bananaBlueberry = $result.schemes | Where-Object { $_.name -eq 'Banana Blueberry' }
        $bananaBlueberry.name | Should -Not -BeNullOrEmpty;
      }
    }
  } # Live settings file mode
}
