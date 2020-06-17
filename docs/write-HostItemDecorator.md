---
external help file: Elizium.TerminalBuddy-help.xml
Module Name: Elizium.TerminalBuddy
online version:
schema: 2.0.0
---

# write-HostItemDecorator

## SYNOPSIS

Performs iteration over a collection of files which are children of the directory
    specified by the caller.

## SYNTAX

```powershell
write-HostItemDecorator [-Underscore] <FileSystemInfo> [-Index] <Int32> [-PassThru] <Hashtable>
 [[-Trigger] <Boolean>] [<CommonParameters>]
```

## DESCRIPTION

The purpose of this function is a act as a decorator to a custom function on
behalf of which any write-host operations are performed. This keeps any
display functionality out of that function so that it may be used in scenarios
where output is not required.

## PARAMETERS

### -Index

0 based numeric index specifying the ordinal of the iterated target.

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

The dictionary object used to pass parameters to the decorated scriptblock
(enclosed within the PassThru Hashtable).

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

The iterated target item provided by the parent iterator function.

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
