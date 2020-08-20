---
external help file: Elizium.TerminalBuddy-help.xml
Module Name: Elizium.TerminalBuddy
online version:
schema: 2.0.0
---

# get-SortedFilesNatural

## SYNOPSIS

Sort a collection of files from the pipeline in natural order.

## SYNTAX

```powershell
get-SortedFilesNatural [-InputObject] <Object[]> [<CommonParameters>]
```

## DESCRIPTION

Sorts filenames in an order that makes sense to humans; ie 1 is followed by
2 and not 10.

## EXAMPLES

### Example 1

```powershell
Get-SortedFolderNatural 'E:\Uni\audio'
```

### Example 2

```powershell
gci E:\Uni\audio | Get-SortedFilesNatural
```

## PARAMETERS

### -InputObject

Collection of files from pipeline to be sorted.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Object[]

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
