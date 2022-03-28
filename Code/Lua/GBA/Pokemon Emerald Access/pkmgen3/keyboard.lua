game_keyboard = {}

game_keyboard.maj = {}
game_keyboard.maj[1] = {"A","B","C","D","E","F","G","H",".","Minuscules"}
game_keyboard.maj[2] = {"I","J","K","L","M","N","O","P",",","Retour"}
game_keyboard.maj[3] = {"Q","R","S","T","U","V","W","X"," ","OK"}
game_keyboard.maj[4] = {"Y","Z"," "," ","-"," "," "," "," "}

game_keyboard.min = {}
game_keyboard.min[1] = {"a","b","c","d","e","f","g","h",".","Autres"}
game_keyboard.min[2] = {"i","j","k","l","m","n","o","p",",","Retour"}
game_keyboard.min[3] = {"q","r","s","t","u","v","w","x"," ","OK"}
game_keyboard.min[4] = {"y","z"," "," ","-"," "," "," "," "," "}

game_keyboard.other = {}
game_keyboard.other[1] = {"0","1","2","3","4"," ","Majuscules"}
game_keyboard.other[2] = {"5","6","7","8","9"," ","Retour"}
game_keyboard.other[3] = {"!","?","m","f","/"," ","OK"}
game_keyboard.other[4] = {".","<",">","'","'"," "}

keyboard_values = {
	["maj"] = {
		x_max = 10,
		y_max = 4,
	},
	["min"] = {
		x_max = 10,
		y_max = 4,
	},
	other = {
		x_max = 7,
		y_max = 4,
	},
}

