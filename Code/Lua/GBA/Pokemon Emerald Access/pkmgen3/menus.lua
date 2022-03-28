menus = {}

menus.yes_no_gender = {
	voice = "yes_no_menu",
	cursor = "sMenu",
	tile = {
		pos = "yes_no_menu_gender_t",
		value = 8443,
	},
}

menus.yes_no_time = {
	voice = "yes_no_menu",
	cursor = "sMenu",
	tile = {
		pos = "yes_no_menu_time_t",
		value = 53846,
	},
}

menus.yes_no_seko_lab = {
	voice = "yes_no_menu",
	cursor = "sMenu",
	tile = {
		pos = "yes_no_menu_seko_lab_t",
		value = 57882,
	},
}

menus.main = {
	voice = "game_menu",
	cursor = {
		pos = 1,
		cmax = 2,
		roll = 0,
	}, 
	tile = {
		pos = "main_menu_t",
		value = 8661,
	},

}

menus.gender = {
	voice = "gender_menu",
	cursor = "sMenu",
	tile = {
		pos = "gender_menu_t",
		value = 8437,
	},
}

--[[
menus.pause_no_pokemon = {
	voice = "pause_menu",
	cursor = "sMenu",
	tile = {
		pos = "pause_menu_t",
		value = 57876,
	},
}
--]]

menus.shop = {
	voice = "shop_menu",
	cursor = "sMenu",
	tile = {
		pos = "shop_menu_t",
		value = 57884,
	},
}

--[[
menus.pc = {
	voice = "pc_menu",
	cursor = "sMenu",
	tile = {
		pos = "pc_menu_t",
		value = 57883,
	},
}
--]]

for k,v in pairs(menus) do
	v.name = k
end