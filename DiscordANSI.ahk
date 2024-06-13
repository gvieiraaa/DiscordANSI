class DiscordANSI {
	__New(exclude_white?) {
		this.parsed := ""
		this.exclude_white := exclude_white??True
		Try this.html_data := this.get_data()
	}

	get_data() {
		data := this.get_clipboard_html()
		hf := ComObject("htmlfile")
		hf.write(data)
		body_content := hf.getElementsByTagName("body")(0)
		this.default_color := hf.getElementsByTagName("div")(0).style.color
		this.parsed := Format("``````ansi`n{}``````", this.recursive_parse(body_content))
	}

	recursive_parse(HtmlElement) {
		children := HtmlElement.children
		len := children.length
		if !len {
			if HtmlElement.TagName == "BR"
				return "`n"		
			if HtmlElement.InnerText == ""
				return ""
			return this.ansi_escape(HtmlElement.InnerText, HtmlElement.style.color)
		}
		s := ""
		Loop children.length { 
			s .= this.recursive_parse(children.Item(A_Index - 1))
		}
		if HtmlElement.TagName == "DIV"
			s .= "`n"
		return s
	}

	ansi_escape(string, color) {
		r := Format("0x{}", SubStr(color, 2, 2)) + 0
		g := Format("0x{}", SubStr(color, 4, 2)) + 0
		b := Format("0x{}", SubStr(color, 6, 2)) + 0
		return Format("[2;3{}m{}", color==this.default_color?9:this.get_closest_color(r, g, b), string)
	}
	
	get_closest_color(r, g, b) {
		colors := [[78,80,87], [228,48,54], [129,153,45], [183,137,43], [21,139,205], [219,52,128], [0,161,152]]
		if !this.exclude_white
			colors.Push([255,255,255])
	
		min_distance := 256**3
		closest := 0
		for _, color in colors {
			sum := 0
			sum += (color[1] - r) ** 2
			sum += (color[2] - g) ** 2
			sum += (color[3] - b) ** 2
			if sum < min_distance {
				closest := A_Index
				min_distance := sum
			}
		}
		return closest - 1
	}
	 
	get_clipboard_html() {
		if !DllCall("IsClipboardFormatAvailable", "uint", HTML_FORMAT := 49352)
			return
		DllCall("OpenClipboard", "ptr", A_ScriptHwnd)
		hData := DllCall("GetClipboardData", "uint", HTML_FORMAT)
		pData := DllCall("GlobalLock", "ptr", hData, "ptr")
		lData := DllCall( "GlobalSize", "uint", hData, "uint")
		outStr := StrGet(hData, lData, "UTF-8")
		RegExMatch(outStr, "StartHTML:(\d+)\REndHTML:(\d+)", &out)
		DllCall("GlobalUnlock", "ptr", hData, "ptr")
		DllCall("CloseClipboard")
		return SubStr(outStr, out[1], out[2] - out[1] + 1)
	}

	paste() {
		A_Clipboard := ""
		ClipWait(1)
		A_Clipboard := this.parsed
		ClipWait(1)
		Send("^v")
		Sleep 100
	}

	get_parsed() {
		return this.parsed
	}
}
