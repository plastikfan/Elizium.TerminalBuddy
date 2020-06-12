$bananaBlueberryJson = '{
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
$bananaBlueberryObj = ConvertFrom-Json $bananaBlueberryJson;
$null = $bananaBlueberryObj;

# Existing content (windows-terminal.live.settings.json)
#
$cyberdyneJson = '{
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
$cyberdyneObj = ConvertFrom-Json $cyberdyneJson;
$null = $cyberdyneObj;

$chalkboardJson = '{
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
$chalkboardObj = ConvertFrom-Json $chalkboardJson;
$null = $chalkboardObj;

# New content (windows-terminal.live.settings.json)
#
$batmanJson = '{
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
$batmanObj = ConvertFrom-Json $batmanJson;
$null = $batmanObj;

$highwayJson = '{
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
$highwayObj = ConvertFrom-Json $highwayJson;
$null = $highwayObj;
