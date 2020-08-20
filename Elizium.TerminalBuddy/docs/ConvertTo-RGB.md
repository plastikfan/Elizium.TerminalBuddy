---
external help file: Elizium.TerminalBuddy-help.xml
Module Name: Elizium.TerminalBuddy
online version:
schema: 2.0.0
---

# ConvertTo-RGB

## SYNOPSIS

Creates the colour specification in hex code form.

## SYNTAX

```powershell
ConvertTo-RGB [[-Components] <Hashtable>] [[-NamingScheme] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION

The Hex string generated represents the string value supported by Windows Terminal that allows rendering in that colour.

## PARAMETERS

### -Components

Hashtable containing colour component descriptor mapped to the real colour value.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NamingScheme

Mapping scheme that decouples external colour component names
from internal names (not of interest to end user).

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
