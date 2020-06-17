---
external help file: Elizium.TerminalBuddy-help.xml
Module Name: Elizium.TerminalBuddy
online version:
schema: 2.0.0
---

# convertFrom-ColourComponents

## SYNOPSIS

Convert colour components from raw real to numerics representation
(ie the number value prior to hex conversion).

## SYNTAX

```powershell
convertFrom-ColourComponents [[-ColourDictionary] <SelectXmlInfo>] [<CommonParameters>]
```

## DESCRIPTION

Given an ANSI colour (eg 'Ansi 1 Color') and a dictionary of colour
definitions as real numbers, creates a hash table of the colour
component name, to colour value.

## PARAMETERS

### -ColourDictionary

XML info representing the colour components for a single ansi colour.

```yaml
Type: SelectXmlInfo
Parameter Sets: (All)
Aliases:

Required: False
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

### System.Collections.Hashtable

## NOTES

## RELATED LINKS
