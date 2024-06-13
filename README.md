# DiscordANSI
Autohotkey v2 Class to paste color formatted code from VSCode to Discord

Usage:

```ahk
#Requires AutoHotkey v2.0
#Include DiscordANSI.ahk

#HotIf WinActive("ahk_exe Discord.exe") ; conditional hotkey
^+v::DiscordANSI().paste() ; Hotkey ctrl shift v pastes the parsed text
```

Only tested locally, I'm not sure if it will work for everyone without changes.

DiscordANSI() can have an optional True/False argument to exclude the color White. The default is True.

Some lighter colors on my theme ended up comparing closer to white than their actual color, like light blue becoming white instead of blue, so I prefer that option as True (default).
