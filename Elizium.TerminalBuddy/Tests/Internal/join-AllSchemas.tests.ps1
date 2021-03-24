Describe 'join-AllSchemas' {
  BeforeAll {
    Get-Module Elizium.TerminalBuddy | Remove-Module
    Import-Module .\Output\Elizium.TerminalBuddy\Elizium.TerminalBuddy.psm1 `
      -ErrorAction 'stop' -DisableNameChecking

    InModuleScope Elizium.TerminalBuddy {
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

      [string]$script:_bananaBlueberryJson = '{
        "name": "Banana Blueberry",
        "black": "#17141F",
        "red": "#FF6B7F",
        "brightGreen": "#98C379",
        "brightYellow": "#F9E46B",
        "brightBlue": "#91FFF4",
        "brightPurple": "#DA70D6",
        "brightCyan": "#BCF3FF",
        "brightWhite": "#FFFFFF",
        "green": "#00BD9C",
        "yellow": "#E6C62F",
        "blue": "#22E8DF",
        "purple": "#DC396A",
        "cyan": "#56B6C2",
        "white": "#F1F1F1",
        "brightBlack": "#495162",
        "brightRed": "#FE9EA1",
        "background": "#191323",
        "cursorColor": "#FFFFFF",
        "foreground": "#CCCCCC",
        "selectionBackground": "#220525"
      }';
      # $cyberdyneObj = ConvertFrom-Json $cyberdyneJson;
    }
  }

  Context 'Given: a single item scheme hashtable' {
    It 'Should: convert to json' {
      InModuleScope Elizium.TerminalBuddy {
        [System.Collections.Hashtable]$schemes = @{
          'Cyberdyne' = $_cyberdyneJson;
        }

        $jsonSchemes = join-AllSchemas -Schemes $schemes;

        $result = $jsonSchemes | ConvertFrom-Json
        $result.schemes | Should -Not -BeNullOrEmpty;
        $result.schemes.Count | Should -Be 1;
        $result.schemes[0].name | Should -Be "Cyberdyne";
      }
    }
  }

  Context 'Given: a mutiple (x2) item scheme hashtable' {
    It 'Should: convert to json' {
      InModuleScope Elizium.TerminalBuddy {
        [System.Collections.Hashtable]$schemes = @{
          'Cyberdyne'        = $_cyberdyneJson;
          'Blueberry Scheme' = $_bananaBlueberryJson;
        }

        $jsonSchemes = join-AllSchemas -Schemes $schemes;

        $result = $jsonSchemes | ConvertFrom-Json
        $result.schemes | Should -Not -BeNullOrEmpty;
        $result.schemes.Count | Should -Be 2;
      }
    }
  }
}
