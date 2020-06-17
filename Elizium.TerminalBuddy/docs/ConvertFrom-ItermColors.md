---
external help file: Elizium.TerminalBuddy-help.xml
Module Name: Elizium.TerminalBuddy
online version:
schema: 2.0.0
---

# ConvertFrom-ItermColors

## SYNOPSIS

Converts .itermcolor files into a format that can be used in Window Terminal Settings.
Depending on the parameters provided, will either integrate generated schemes into
the setting files, or generate a separate file from the existing settings file. Any
schemes already present in the setting files will be preserved.

## SYNTAX

```powershell
ConvertFrom-ItermColors [-Path] <String> [[-Filter] <String>] [[-Out] <String>] [-SaveTerminalSettings]
 [-Force] [[-DryRunFile] <String>] [[-BackupFile] <String>] [[-ThemeName] <String>]
 [[-LiveSettingsFile] <String>] [[-PseudoSettingsFile] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Since there is currently no settings UI in Windows Terminal Settings app and the format
that is used to express colour schemes is vastly different to that used by iterm, it
is not easy to leverage the work done by others in creating desirable terminal schemes.
This function makes it easier to apply iterm colour schemes into Windows Terminal.

There are multiple ways to use this function:

1) generate an Output file (denoted by $Out parameter), which will contain a JSON
object containing the colour schemes converted from iterm to Windows Terminal
format.
2) generate a new Dry Run file which is a copy of the current Windows Terminal
Settings file with the converted schemes integrated into it.
3) make a backup, of the Settings file, then integrate the generated schemes into
the current Settings file. (See caveats further down below).

  The function errs on the side of caution, and by default works in 'Dry Run' mode. Due
to the caveats, this method is effectively the same as not using the $SaveTerminalSettings
switch, using $Out instead, because in this scenario, the user would be expected to open
up the generated file and copy the generated scheme objects into the current Settings
file. This is the recommended way to use this command.

  If the user wants to integrate the generated schemes into the Settings file
automatically, then the $Force switch should be specified. In this case, the current live
Settings file is backed up and then over-written by the new content. Existing schemes
are preserved.

And the caveats ...

1) For some reason, Microsoft decided to include comments inside the JSON setting file
(probably in lieu of there not being a proper settings UI, making configuring the settings
easier). However, comments are not part of the current JSON schema (although they are
permitted in the rarely and sparsely supported json5 spec), which means that this conversion
process will not preserve the comments. There is an alternative api that supposedly supports
non standard JSON features, newtonsoft.json.ConvertTo-JsonNewtonsoft/ConvertFrom-JsonNewtonsoft
but using these functions yield unsatisfactory results.

2) ConvertFrom-Json/Converto-Json do not properly handle the profiles

## EXAMPLES

### Example 1

```powershell
ConvertFrom-ItermColors -Path 'C:\shared\Themes\ITerm2\Schemes\Banana Blueberry.itermcolors'
  -Out ~/terminal-settings.single.output.json
```

Convert a single file into Out file *~/terminal-settings.single.output.json*

### Example 2

```powershell
ConvertFrom-ItermColors -Path C:\shared\Themes\ITerm2\Schemes -Filter "B*.itermcolors"
  -Out ~/terminal-settings.output.json
```

Bulk convert multiple files into Out file *~/terminal-settings.output.json*

### Example 3

```powershell
ConvertFrom-ItermColors -Path 'C:\shared\Themes\ITerm2\Schemes\Banana Blueberry.itermcolors'
  -SaveTerminalSettings
```

Convert a single file into Dry Run file

### Example 4

```powershell
ConvertFrom-ItermColors -Path C:\shared\Themes\ITerm2\Schemes\ -Filter 'B*.itermcolors'
  -SaveTerminalSettings
```

Bulk convert multiple files into Dry Run file

## PARAMETERS

### -BackupFile

When not in Dry Run mode ($Force and $SaveTerminalSettings specified), this parameter
specifies the path to backup the live Windows Terminal Settings file to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DryRunFile

When run in Dry Run mode (by default), this is the path of the file written to.
It will contain a merge of the current Windows Terminal Settings file and newly generated
schemes as converted from iterm files specified by the $Path.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter

When Path refers to a directory, use Filter to specify files. A * can be used
as a wildcard.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

Switch to indicate whether live settings should be modified to include generated schemes.
To avoid accidental invocation, needs to be used in addition to SaveTerminalSettings.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiveSettingsFile

Well known path to the current windows terminal settings file. This is assumed to of
the well known path. This can be overridden by the user if so required (just in case it's
located elsewhere).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Out

The output file written to with the JSON represented the converted iterm themes. This
content is is just a fragment of the settings file, in fact it's a JSON object which
contains a single member named 'schemes' (after the corresponding entry in the
Windows Terminal Settings file.) which is set to an array of scheme objects.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

The path containing the iterm scheme files. If this refers to a directory, then a Filter
should be specified to identify the files. This Path can also just refer directly to an
individual file, in which case, no Filter is required.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PseudoSettingsFile

This file is only required because of certain caveats of the current implementation, owing
to Microsoft's choice in not using standard JSON file. In the interests of safety, instead
of integrating new schemes into the LiveSettingsFile, PseudoSettingsFile specifies the file
used instead of overwriting LiveSettingsFile. This function will indicating that the schemes
should be manually copied over at the end of the run.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SaveTerminalSettings

Switch, to indicate that the converted schemes should be saved into a complete settings
file. Which settings file depends on the presence of the Force parameter. If Force is
present, the the LiveSettingsFile path is used, otherwise the DryRunFile path is used.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ThemeName

The name of a Krayola Theme, that has been configured inside the global $KrayolaThemes
hashtable variable. If not present, then an internal theme is used. The Krayola Theme
shapes how output of this command is generated to the console.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
