---
external help file: Elizium.TerminalBuddy-help.xml
Module Name: Elizium.TerminalBuddy
online version:
schema: 2.0.0
---

# invoke-ForeachFile

## SYNOPSIS

Performs iteration over a collection of files which are children of the directory
specified by the caller.

## SYNTAX

```powershell
invoke-ForeachFile [-Path] <String> [-Body] <ScriptBlock> [[-PassThru] <Hashtable>] [[-Filter] <String>]
 [[-Condition] <ScriptBlock>] [<CommonParameters>]
```

## DESCRIPTION

Invoke an operation for each file found from the Path.
(This needs to be refactored/redesigned to use the pipeline via InputObject as
this is the idiomatic way to do this in PowerShell).

## PARAMETERS

### -Body

The implementation script block that is to be implemented for each child file. The
script block can either return $null or a PSCustomObject with fields Message(string) giving an
indication of what was implemented, Product (string) which represents the item in question
(ie the processed item as appropriate) and Colour(string) which is the console colour
applied to the Product. Also, the Trigger should be set to true, if an action has been taken
for any of the files iterated. This is so because if we iterate a collection of files, but the
operation doesn't do anything to any of the files, then the whole operation should be considered
a no-op, so we can keep output to a minimum.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Condition

The result of Get-ChildItem is piped to a where statement whose condition is specified by
this parameter. The (optional) scriptblock specified must be a predicate.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter

The filter to apply to Get-ChildItem.

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

### -PassThru

The dictionary object used to pass parameters to the $Body scriptblock provided.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

The parent directory to iterate.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
