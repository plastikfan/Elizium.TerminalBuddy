Describe 'merge-SettingsContent' {
  BeforeAll {
    Get-Module Elizium.TerminalBuddy | Remove-Module
    Import-Module .\Output\Elizium.TerminalBuddy\Elizium.TerminalBuddy.psm1 `
      -ErrorAction 'stop' -DisableNameChecking

    InModuleScope Elizium.TerminalBuddy {
      [string]$script:_settingsPath = './Tests/Data/windows-terminal.live.settings.json';
      [string]$script:_outputPath = 'TestDrive:\merged-output.json';

      [string]$script:_batmanJson = '{
        "name": "Batman",
        "black": "#1B1D1E",
        "red": "#E6DC44",
        "brightGreen": "#FFF27D",
        "brightYellow": "#FEED6C",
        "brightBlue": "#919495",
        "brightPurple": "#9A9A9D",
        "brightCyan": "#A3A3A6",
        "brightWhite": "#DADBD6",
        "green": "#C8BE46",
        "yellow": "#F4FD22",
        "blue": "#737174",
        "purple": "#747271",
        "cyan": "#62605F",
        "white": "#C6C5BF",
        "brightBlack": "#505354",
        "brightRed": "#FFF78E",
        "background": "#1B1D1E",
        "cursorColor": "#000000",
        "foreground": "#6F6F6F",
        "selectionBackground": "#4D504C"
      }';

      [string]$script:_highwayJson = '{
        "name": "Highway",
        "black": "#000000",
        "red": "#D00E18",
        "brightGreen": "#B1D130",
        "brightYellow": "#FFF120",
        "brightBlue": "#4FC2FD",
        "brightPurple": "#DE0071",
        "brightCyan": "#5D504A",
        "brightWhite": "#FFFFFF",
        "green": "#138034",
        "yellow": "#FFCB3E",
        "blue": "#006BB3",
        "purple": "#6B2775",
        "cyan": "#384564",
        "white": "#EDEDED",
        "brightBlack": "#5D504A",
        "brightRed": "#F07E18",
        "background": "#222225",
        "cursorColor": "#1F192A",
        "foreground": "#EDEDED",
        "selectionBackground": "#384564"
      }';

      [string]$script:_cyberdyneJson = '{
        "name": "Cyberdyne",
        "black": "#080808",
        "red": "#FF8373",
        "brightGreen": "#D6FCBA",
        "brightYellow": "#FFFED5",
        "brightBlue": "#C2E3FF",
        "brightPurple": "#FFB2FE",
        "brightCyan": "#E6E7FE",
        "brightWhite": "#FFFFFF",
        "green": "#00C172",
        "yellow": "#D2A700",
        "blue": "#0071CF",
        "purple": "#FF90FE",
        "cyan": "#6BFFDD",
        "white": "#F1F1F1",
        "brightBlack": "#2E2E2E",
        "brightRed": "#FFC4BE",
        "background": "#151144",
        "cursorColor": "#FFFFFF",
        "foreground": "#00FF92",
        "selectionBackground": "#454D96"
      }';

      [string]$script:_chalkboardJson = '{
        "name": "Chalkboard",
        "black": "#000000",
        "red": "#C37372",
        "brightGreen": "#AADBAA",
        "brightYellow": "#DADBAA",
        "brightBlue": "#AAAADB",
        "brightPurple": "#DBAADA",
        "brightCyan": "#AADADB",
        "brightWhite": "#FFFFFF",
        "green": "#72C373",
        "yellow": "#C2C372",
        "blue": "#7372C3",
        "purple": "#C372C2",
        "cyan": "#72C2C3",
        "white": "#D9D9D9",
        "brightBlack": "#323232",
        "brightRed": "#DBAAAA",
        "background": "#29262F",
        "cursorColor": "#29262F",
        "foreground": "#D9E6F2",
        "selectionBackground": "#073642"
      }';

      function script:build-TestContent {
        [OutputType([string])]
        param(
          [string[]]$JsonSchemes
        )

        [string]$outputContent = '{ "schemes": [';
        foreach ($scheme in $JsonSchemes) {
          $outputContent += $scheme;
          $outputContent += ',';
        }

        [int]$last = $outputContent.LastIndexOf(',');
        $outputContent = $outputContent.Substring(0, $last);

        [string]$close = '] }';
        $outputContent += $close;
        $outputContent = $outputContent | ConvertFrom-Json | ConvertTo-Json;

        return $outputContent;
      }
    }
  }

  Context 'Given: content with single new scheme' {
    It 'Should: merge the new scheme with Settings' {
      InModuleScope Elizium.TerminalBuddy {
        $schemes = @($_batmanJson);
        $content = build-TestContent -JsonSchemes $schemes;

        merge-SettingsContent -Content $content -SettingsPath $_settingsPath -OutputPath $_outputPath;
        $result = Get-Content -Path $_outputPath;
        $settingsContent = Get-Content -Path $_settingsPath;
        $settingsObject = $settingsContent | ConvertFrom-Json;
        $resultObject = $result | ConvertFrom-Json;
        $resultObject.schemes | Should -Not -BeNullOrEmpty;
        $resultObject.schemes | Where-Object { $_.name -eq 'Batman' } | Should -Not -BeNullOrEmpty;

        $settingsObject.schemes.Count | Should -Be $($resultObject.schemes.Count - 1);
      }
    }
  }

  Context 'Given: content with multiple (x2) new schemes' {
    It 'Should: merge the new schemes with Settings' {
      InModuleScope Elizium.TerminalBuddy {
        $schemes = @($_batmanJson, $_highwayJson);
        $content = build-TestContent -JsonSchemes $schemes;

        merge-SettingsContent -Content $content -SettingsPath $_settingsPath -OutputPath $_outputPath;
        $result = Get-Content -Path $_outputPath;
        $settingsContent = Get-Content -Path $_settingsPath;
        $settingsObject = $settingsContent | ConvertFrom-Json;
        $resultObject = $result | ConvertFrom-Json;
        $resultObject.schemes | Should -Not -BeNullOrEmpty;
        $resultObject.schemes | Where-Object { $_.name -eq 'Batman' } | Should -Not -BeNullOrEmpty;
        $resultObject.schemes | Where-Object { $_.name -eq 'Highway' } | Should -Not -BeNullOrEmpty;

        $settingsObject.schemes.Count | Should -Be $($resultObject.schemes.Count - 2);
      }
    }
  }

  Context 'Given: content with single scheme already present in settings' {
    It 'Should: not merge new scheme' {
      InModuleScope Elizium.TerminalBuddy {
        $schemes = @($_cyberdyneJson);
        $content = build-TestContent -JsonSchemes $schemes;

        merge-SettingsContent -Content $content -SettingsPath $_settingsPath -OutputPath $_outputPath;
        $result = Get-Content -Path $_outputPath;
        $settingsContent = Get-Content -Path $_settingsPath;
        $settingsObject = $settingsContent | ConvertFrom-Json;
        $resultObject = $result | ConvertFrom-Json;
        $resultObject.schemes | Should -Not -BeNullOrEmpty;
        $resultObject.schemes | Where-Object { $_.name -eq 'Cyberdyne' } | Should -Not -BeNullOrEmpty;

        $settingsObject.schemes.Count | Should -Be $resultObject.schemes.Count;
      }
    }
  }

  Context 'Given: content with 1 new scheme and 1 existing scheme' {
    It 'Should: only merge the new scheme with Settings' {
      InModuleScope Elizium.TerminalBuddy {
        $schemes = @($_batmanJson, $_cyberdyneJson);
        $content = build-TestContent -JsonSchemes $schemes;

        merge-SettingsContent -Content $content -SettingsPath $_settingsPath -OutputPath $_outputPath;
        $result = Get-Content -Path $_outputPath;
        $settingsContent = Get-Content -Path $_settingsPath;
        $settingsObject = $settingsContent | ConvertFrom-Json;
        $resultObject = $result | ConvertFrom-Json;
        $resultObject.schemes | Should -Not -BeNullOrEmpty;
        $resultObject.schemes | Where-Object { $_.name -eq 'Batman' } | Should -Not -BeNullOrEmpty;
        $resultObject.schemes | Where-Object { $_.name -eq 'Cyberdyne' } | Should -Not -BeNullOrEmpty;

        $settingsObject.schemes.Count | Should -Be $($resultObject.schemes.Count - 1);
      }
    }
  }

  Context 'Given: content with existing (x2) schemes' {
    It 'Should: not merge new scheme' {
      InModuleScope Elizium.TerminalBuddy {
        $schemes = @($_cyberdyneJson, $_chalkboardJson);
        $content = build-TestContent -JsonSchemes $schemes;

        merge-SettingsContent -Content $content -SettingsPath $_settingsPath -OutputPath $_outputPath;
        $result = Get-Content -Path $_outputPath;
        $settingsContent = Get-Content -Path $_settingsPath;
        $settingsObject = $settingsContent | ConvertFrom-Json;
        $resultObject = $result | ConvertFrom-Json;
        $resultObject.schemes | Should -Not -BeNullOrEmpty;
        $resultObject.schemes | Where-Object { $_.name -eq 'Cyberdyne' } | Should -Not -BeNullOrEmpty;
        $resultObject.schemes | Where-Object { $_.name -eq 'Chalkboard' } | Should -Not -BeNullOrEmpty;

        $settingsObject.schemes.Count | Should -Be $resultObject.schemes.Count;
      }
    }
  }
}
