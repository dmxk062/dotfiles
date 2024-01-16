local colors = require("nord.colors")

local nord = {}

nord.normal = {
	a = { fg = colors.nord0_gui, bg = colors.nord7_gui},
	b = { fg = colors.nord6_gui, bg = colors.nord0_gui },
	c = { fg = colors.nord6_gui, bg = colors.nord0_gui },
}

nord.insert = {
	a = { fg = colors.nord6_gui, bg = colors.nord1_gui },
	b = { fg = colors.nord6_gui, bg = colors.nord0_gui },
	y = {  fg = colors.nord6_gui, bg = colors.nord0_gui },
}

nord.visual = {
	a = { fg = colors.nord0_gui, bg = colors.nord10_gui },
	b = { fg = colors.nord6_gui, bg = colors.nord0_gui },
	y = {  fg = colors.nord6_gui, bg = colors.nord0_gui },
}

nord.replace = {
	a = { fg = colors.nord0_gui, bg = colors.nord11_gui },
	b = { fg = colors.nord4_gui, bg = colors.nord2_gui },
	y = {  fg = colors.nord5_gui, bg = colors.nord2_gui },
}

nord.command = {
	a = { fg = colors.nord0_gui, bg = colors.nord15_gui },
	b = { fg = colors.nord4_gui, bg = colors.nord2_gui },
	y = {  fg = colors.nord5_gui, bg = colors.nord2_gui },
}

nord.inactive = {
	a = { fg = colors.nord5_gui, bg = colors.nord0_gui },
	b = { fg = colors.nord5_gui, bg = colors.nord0_gui },
	c = { fg = colors.nord5_gui, bg = colors.nord0_gui },
}

return nord
