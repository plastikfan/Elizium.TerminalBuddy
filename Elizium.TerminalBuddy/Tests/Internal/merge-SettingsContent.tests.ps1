Describe 'merge-SettingsContent' -Tag 'CURRENT' {
  BeforeAll {
    Get-Module Elizium.TerminalBuddy | Remove-Module
    Import-Module .\Output\Elizium.TerminalBuddy\Elizium.TerminalBuddy.psm1 `
      -ErrorAction 'stop' -DisableNameChecking

    $settingsPath = './Tests/Data/windows-terminal.live.settings.json';
    $null = $settingsPath;

    $outputPath = 'TestDrive:\merged-output.json';
    $null = $outputPath;

    . './Tests/Data/setup-schemes.data.ps1';
  }

  Context 'Given: content with single new scheme' {
    It 'Should: merge the new scheme with Settings' {
      $schemes = @($batmanJson);
      $content = build-TestContent -JsonSchemes $schemes;

      merge-SettingsContent -Content $content -SettingsPath $settingsPath -OutputPath $outputPath;
      $result = Get-Content -Path $outputPath;
      $settingsContent = Get-Content -Path $settingsPath;
      $settingsObject = $settingsContent | ConvertFrom-Json;
      $resultObject = $result | ConvertFrom-Json;
      $resultObject.schemes | Should -Not -BeNullOrEmpty;
      $resultObject.schemes | Where-Object { $_.name -eq 'Batman' } | Should -Not -BeNullOrEmpty;

      $settingsObject.schemes.Count | Should -Be $($resultObject.schemes.Count - 1);
    }
  }

  Context 'Given: content with multiple (x2) new schemes' {
    It 'Should: merge the new schemes with Settings' {
      $schemes = @($batmanJson, $highwayJson);
      $content = build-TestContent -JsonSchemes $schemes;

      merge-SettingsContent -Content $content -SettingsPath $settingsPath -OutputPath $outputPath;
      $result = Get-Content -Path $outputPath;
      $settingsContent = Get-Content -Path $settingsPath;
      $settingsObject = $settingsContent | ConvertFrom-Json;
      $resultObject = $result | ConvertFrom-Json;
      $resultObject.schemes | Should -Not -BeNullOrEmpty;
      $resultObject.schemes | Where-Object { $_.name -eq 'Batman' } | Should -Not -BeNullOrEmpty;
      $resultObject.schemes | Where-Object { $_.name -eq 'Highway' } | Should -Not -BeNullOrEmpty;

      $settingsObject.schemes.Count | Should -Be $($resultObject.schemes.Count - 2);
    }
  }

  Context 'Given: content with single scheme already present in settings' {
    It 'Should: not merge new scheme' {
      $schemes = @($cyberdyneJson);
      $content = build-TestContent -JsonSchemes $schemes;

      merge-SettingsContent -Content $content -SettingsPath $settingsPath -OutputPath $outputPath;
      $result = Get-Content -Path $outputPath;
      $settingsContent = Get-Content -Path $settingsPath;
      $settingsObject = $settingsContent | ConvertFrom-Json;
      $resultObject = $result | ConvertFrom-Json;
      $resultObject.schemes | Should -Not -BeNullOrEmpty;
      $resultObject.schemes | Where-Object { $_.name -eq 'Cyberdyne' } | Should -Not -BeNullOrEmpty;

      $settingsObject.schemes.Count | Should -Be $resultObject.schemes.Count;
    }
  }

  Context 'Given: content with 1 new scheme and 1 existing scheme' {
    It 'Should: only merge the new scheme with Settings' {
      $schemes = @($batmanJson, $cyberdyneJson);
      $content = build-TestContent -JsonSchemes $schemes;

      merge-SettingsContent -Content $content -SettingsPath $settingsPath -OutputPath $outputPath;
      $result = Get-Content -Path $outputPath;
      $settingsContent = Get-Content -Path $settingsPath;
      $settingsObject = $settingsContent | ConvertFrom-Json;
      $resultObject = $result | ConvertFrom-Json;
      $resultObject.schemes | Should -Not -BeNullOrEmpty;
      $resultObject.schemes | Where-Object { $_.name -eq 'Batman' } | Should -Not -BeNullOrEmpty;
      $resultObject.schemes | Where-Object { $_.name -eq 'Cyberdyne' } | Should -Not -BeNullOrEmpty;

      $settingsObject.schemes.Count | Should -Be $($resultObject.schemes.Count - 1);
    }
  }

  Context 'Given: content with existing (x2) schemes' {
    It 'Should: not merge new scheme' {
      $schemes = @($cyberdyneJson, $chalkboardJson);
      $content = build-TestContent -JsonSchemes $schemes;

      merge-SettingsContent -Content $content -SettingsPath $settingsPath -OutputPath $outputPath;
      $result = Get-Content -Path $outputPath;
      $settingsContent = Get-Content -Path $settingsPath;
      $settingsObject = $settingsContent | ConvertFrom-Json;
      $resultObject = $result | ConvertFrom-Json;
      $resultObject.schemes | Should -Not -BeNullOrEmpty;
      $resultObject.schemes | Where-Object { $_.name -eq 'Cyberdyne' } | Should -Not -BeNullOrEmpty;
      $resultObject.schemes | Where-Object { $_.name -eq 'Chalkboard' } | Should -Not -BeNullOrEmpty;

      $settingsObject.schemes.Count | Should -Be $resultObject.schemes.Count;
    }
  }
}
