
Set-StrictMode -Version Latest

$functionFolders = @('Public', 'Internal')
foreach ($folder in $functionFolders)
{
    $folderPath = Join-Path -Path $PSScriptRoot -ChildPath $folder
    if (Test-Path -Path $folderPath)
    {
        Write-Verbose -Message "Importing from $folder"
        $functions = Get-ChildItem -Path $folderPath -Filter '*.ps1'
        foreach ($function in $functions)
        {
            Write-Verbose -Message "  Importing $($function.BaseName)"
            . $($function.FullName)
        }
    }
}

# This has to be done manually, because there is no direct relationship between
# the file name and the function name, eg "Write-ThemedPairsInColour" => write-coloured-pairs.ps1
# Perhaps we should correct this in the future or we remove the dashes from "coloured-pairs"
# in order to yield "ColouredPairs". If this functionality is implmented, don't forget to
# port this back into the module plaster.
#
# $publicFunctions = (Get-ChildItem -Path "$PSScriptRoot/Public" -Filter '*.ps1').BaseName
#
# Export-ModuleMember -Function <TODO>
# Export-ModuleMember -Variable [TODO]
# Export-ModuleMember -Alias [TODO]

# ============================================================================================
# NOTES:
#

# https://powers-hell.com/2020/04/05/replicate-your-favorite-vscode-theme-in-windows-terminal/



# Capture the xml content:
#
# $xc = [xml]@(Get-Content .\AtelierSulphurpool.itermcolors)

# select the keys
#
# Select-Xml '/plist/dict/key' $xc | % { $_.Node.FirstChild }

# Select-Xml '/plist/dict/dict' $xc | % { $_.Node.FirstChild }

# select tghe cour portions
#
# Select-Xml '/plist/dict/dict' $xc | % { $_.Node.ChildNodes }

# the item color format is rubbish because the keys and values are not tied together own their own parent.

# So you'll have to create 2 xpath querys and popluation 2 separate arrays where the position
# of each key corresponds to the value in the same position
#

# Alpha ==> is the transparency component, (0-255 or if 0-1, => multiply by 255)
# 0 -> fully transparent
# 1/255 -> fully opaque

# http://www.ryanjuckett.com/programming/rgb-color-space-conversion/
# https://en.wikipedia.org/wiki/CIE_1931_color_space

# http://www.easyrgb.com/en/math.php#text2

# Color-Space = 'Calibrated', but what does thsi mean in the conversio of RGB from %value to hex?
# https://github.com/gnachman/iTerm2/pull/149
# https://ethanschoonover.com/solarized/#the-values


# XYZ:
# - Y = relative luminance as perceived by human eye
# 2 dimensional chromaticity space XY
# chromaticity = description of a clour ignoring it's luminance Y

# here is a javascript implemenation of a colour conversion utility:
# https://github.com/stayradiated/colr



# Here is the iterm2 color conversion algorthm as implemted in pyton (color.py):

<#
    def from_dict(self, input_dict):
        """Updates the color from the dictionary's contents."""
        self.red = float(input_dict["Red Component"]) * 255
        self.green = float(input_dict["Green Component"]) * 255
        self.blue = float(input_dict["Blue Component"]) * 255
        if "Alpha Component" in input_dict:
            self.alpha = float(input_dict["Alpha Component"]) * 255
        else:
            self.alpha = 255
        if "Color Space" in input_dict:
            self.color_space = ColorSpace(input_dict["Color Space"])
        else:
            # This is the default because it is what profiles use by default.
            self.color_space = ColorSpace.CALIBRATED
#>
