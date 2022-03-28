callbacks = {
	["Pokemon Emerald (FR)"] = {
		intro = 135711805,
		ingame_keyboard = 135154657,
		bag = 135965065,
		pokemon_party = 135986669,
		title_screen = 134916929,
		region_map1 = 136081469,
		region_map2 = 135415065,
		main_menu = 134411953,
		shop = 135133661,
		--overworld = 134766101,
	},
	["Pokemon Emerald (U)"] = {
		intro = 135711745,
		ingame_keyboard = 135155545,
		bag = 135966045,
		pokemon_party = 135987633,
		title_screen = 134916909,
		region_map1 = 136081469,--to do*
		region_map2 = 135725685,
		main_menu = 134411953,
		shop = 135134565,
		--overworld = 134766101,--to do*
	},
}

ingame_keyboard_layout = {
	["Pokemon Emerald (FR)"] = {
		maj = {
			[1] = {"A","B","C","D","E","F","G","H","point","Minuscules"},
			[2] = {"I","J","K","L","M","N","O","P","virgule","Retour"};
			[3] = {"Q","R","S","T","U","V","W","X"," ","OK"},
			[4] = {"Y","Z"," "," ","tiret"," "," "," "," ","-"},
		},
		min = {
			[1] = {"a","b","c","d","e","f","g","h","point","Autres"},
			[2] = {"I","J","K","L","M","N","O","P","virgule","Retour"},
			[3] = {"Q","R","S","T","U","V","W","X"," ","OK"},
			[4] = {"Y","Z"," "," ","tiret"," "," "," "," ","-"},
		},
		other = {
			[1] = {"0","1","2","3","4"," ","Majuscules"},
			[2] = {"5","6","7","8","9"," ","Retour"},
			[3] = {"point d'exclamation","point d'interrogation","signe masculin","signe féminin","barre oblique"," ","OK"},
			[4] = {"trois petits points","ouvrez les guillemets","fermez les guillemets","ouvrez les guillemets d'apostrophes","fermez les guillemets d'apostrophes"," ","-"},
		},
	},
	["Pokemon Emerald (U)"] = {
		maj = {
			[1] = {"A","B","C","D","E","F"," ","dot","Lower"},
			[2] = {"G","H","I","J","K","L"," ","comma","Back"};
			[3] = {"M","N","O","P","Q","R","S"," ","OK"},
			[4] = {"T","U","V","W","X","Y","Z"," ","-"},
		},
		min = {
			[1] = {"A","B","C","D","E","F"," ","dot","Others"},
			[2] = {"G","H","I","J","K","L"," ","comma","Back"};
			[3] = {"M","N","O","P","Q","R","S"," ","OK"},
			[4] = {"T","U","V","W","X","Y","Z"," ","-"},
		},
		other = {
			[1] = {"0","1","2","3","4"," ","Upper"},
			[2] = {"5","6","7","8","9"," ","Back"},
			[3] = {"exclamation mark","question mark","male symbol","female symbol","slash","dash","OK"},
			[4] = {"three dots","open double quote","close double quote","open single quote","close single quote"," ","-"},
		},
	},
}