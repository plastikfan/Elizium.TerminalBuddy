---
external help file: Elizium.TerminalBuddy-help.xml
Module Name: Elizium.TerminalBuddy
online version:
schema: 2.0.0
---

# import-ItermColors

## SYNOPSIS

Imports XML data from iterm file and converts to JSON format.

## SYNTAX

```powershell
import-ItermColors [-Underscore] <FileSystemInfo> [-Index] <Int32> [-PassThru] <Hashtable>
 [[-Trigger] <Boolean>] [<CommonParameters>]
```

## DESCRIPTION

This function behaves like a reducer, because it populates an Accumulator
collection for each file it is presented with.

## PARAMETERS

### -Index

0 based numeric index specifying the ordinal of the file in the batch.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru

The dictionary object containing additional parameters. Also used by
this function to append it's result to an 'ACCUMULATOR' hash (indexed
by scheme name), which ultimately allows all the schemes to be collated
into the 'schemes' array field in the settings file.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Trigger

Trigger.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Underscore

fileinfo object representing the .itermcolors file.

```yaml
Type: FileSystemInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS
