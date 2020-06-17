---
external help file: Elizium.TerminalBuddy-help.xml
Module Name: Elizium.TerminalBuddy
online version:
schema: 2.0.0
---

# new-SchemeJsonFromDocument

## SYNOPSIS

Builds the json content representing all the schemes previously collated.

## SYNTAX

```powershell
new-SchemeJsonFromDocument [[-XmlDocument] <XmlDocument>] [<CommonParameters>]
```

## DESCRIPTION

Local function new-SchemeJsonFromDocument, processes an xml document for an
iterm scheme. This format is not in a form particularly helpful for xpath
expressions. The key and values are all present at the same level in the
xml hierachy, so there is no direct relationship between the key and the value.
All we can do is make an assumption that consecutive items are bound together
by the key/value relationship. So these are processed as a result of 2 xpath
expressions, the first selecting the keys (/plist/dict/key) and the other
selecting the values (/plist/dict/dict) and we just make the assumption that
the length of both result sets are the same and that items in the same position
in their result sets are bound as a key/value pair. Used by ConvertFrom-ItermColors.

## PARAMETERS

### -XmlDocument

The XML document.

```yaml
Type: XmlDocument
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

### System.String

## NOTES

## RELATED LINKS
