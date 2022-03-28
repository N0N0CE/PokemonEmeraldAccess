-- Lua Script made by NONOCE
-- Started from some other Pokemon gen3 TAS script I need to write the name here.

-- OLD TODO
-- Hide eggs and egg hatching crash bug
-- does safari or pyramid work ?
-- Fly map bug in position sometimes ?
-- NVDA input bug sometimes ?
-- 

--[[
	To Add
	- fill all rom specific data

	Cool to add
	- Help button
	- Get Pokemon list from ROM
	- In game main menu and option menu navigation
	- Script options menu
	- Option to remove cracked floor tiles
	- Read map names in entity menu
	- Read quantity in scrolling menus
	- Phone texts
	- Entity menu targets
	- Better shops and scrolling menus
	- Less bugs
	
	Expensive features to add
	- Pathing
	- All special menus support
	- Some ROM hack support
	- Other Gen3 support
	
]]




DATA_FOLDER = "pkmgen3"
dofile (DATA_FOLDER .. "/defines.lua")
dofile (DATA_FOLDER .. "/voice_language.lua")
dofile (DATA_FOLDER .. "/rom_specific_data.lua")
dofile (DATA_FOLDER .. "/Data.lua")
dofile (DATA_FOLDER .. "/Memory.lua")
dofile (DATA_FOLDER .. "/GameSettings.lua")


console.clear()


console.write(string.char(10))

-- Initialize Game Settings before loading other files.
GameSettings.initialize()
dofile (DATA_FOLDER .. "/AccessSettings.lua")

if GameSettings.gamename == "Pokemon Emerald (FR)" then 
	access_settings.voice_language = "fr"
end
vl = access_settings.voice_language

dofile (DATA_FOLDER .. "/GraphicConstants.lua")
dofile (DATA_FOLDER .. "/LayoutSettings.lua")
dofile (DATA_FOLDER .. "/Forms.lua")
--dofile (DATA_FOLDER .. "/Map.lua")
dofile (DATA_FOLDER .. "/Utils.lua")
dofile (DATA_FOLDER .. "/Buttons.lua")
dofile (DATA_FOLDER .. "/Input.lua")
--dofile (DATA_FOLDER .. "/RNG.lua")
dofile (DATA_FOLDER .. "/Drawing.lua")
dofile (DATA_FOLDER .. "/Chars.lua")
dofile (DATA_FOLDER .. "/Program.lua")
dofile (DATA_FOLDER .. "/scanning.lua")
dofile (DATA_FOLDER .. "/access27032022.lua")
--dofile (DATA_FOLDER .. "/signatures.lua")
--dofile (DATA_FOLDER .. "/keyboard.lua")
--dofile (DATA_FOLDER .. "/menus.lua")

event.onloadstate(loadstate_reinit) 
loadstate_reinit()

memory.usememorydomain("System Bus")

local a_button = false

local keys_state = input.get() 

--[[tstring = ""
for i=1,255,1 do
tstring = tstring .. string.char(i)
end
voice_string(tstring,0) ]]

if GameSettings.game == 0 then
	client.SetGameExtraPadding(0, 0, 0, 0)
	while true do
		gui.text(0, 0, "Lua error: " .. GameSettings.gamename)
		emu.frameadvance()
	end 
else

	if access_settings.debuging == 1 then 
		client.SetGameExtraPadding(0, GraphicConstants.UP_GAP, GraphicConstants.RIGHT_GAP, GraphicConstants.DOWN_GAP)
		gui.defaultTextBackground(0)
	end
	
	if comm.socketServerIsConnected() then console.write( "connected" ..string.char(10)) else console.write( "connection error"..string.char(10)) end
	console.write(comm.socketServerGetInfo())
	console.write(string.char(10))	
	
	--memory.writebyte(0x03005E0A, 2,"System Bus") --set text speed to fast
	temp_printer = {}
	activate_temp_printer_char_event(true)
	
	local second_counter = 0
	local map_fps_counter = 0
	while true do
		second_counter = second_counter + 1
		if second_counter > 59 then 
			second_counter = 0 
			
			if access_settings.debuging == 0 or access_settings.debuging == 2 then console.clear() end
			collectgarbage()
			
		end
		
		if client.ispaused() == false then menu_mode = "game" end
		
		if access_settings.debuging == 1 then Program.main() end
	
		scan_values()

		values_change_logic()

		voice_when_no_input()
		keyboard_input_logic()
		
		if dialog.cursor == 1 then
			advance_dialog()
		end
	
		--gui.drawRectangle(0,0,50,50,0xFF000000,0xFF000000)

		--local map = scan_collision_map(4,3)
		map_fps_counter = map_fps_counter + 1
		if map_fps_counter > 3 then 
			map_fps_counter = 0 
			
			if draw_the_map > 0 and misc.values.inBattle == 0 then 
				--debug_print("x")
				draw_map(map) 
			end
			
		end		
		

		
		--block_next_frame_input()
		

		
		if client.ispaused == true then emu.frameadvance() else emu.yield() end
	
		
	end
end