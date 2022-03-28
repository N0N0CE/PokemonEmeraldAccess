voice_position_trigger = 0

local old_active = {}

voice_no_input = ""
voice_no_input_2 = ""

--[[
ingame_keyboard_values = {}
old_ingame_keyboard_values = {}
change_ingame_keyboard_values = {}
]]

battle_values = {
	actionCursor = {},
	moveCursor = {},
	moves = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
	},
	battle_func = {},
}
old_battle_values = clone(battle_values)
change_battle_values = clone(battle_values)

--frames = {}
--[[
bgr = {}
old_bgr = {}
change_bgr = {}

pbgr = {
	[0] = {},
	[1] = {},
	[2] = {},
	[3] = {},
}

bgs = {}
old_bgs = {}
change_bgs = {}


voice_modes = {
	battle_action = 0,
	battle_move = 0,	
	bag = 0,	
	pokemon_selection = 0,
	coordinates = 0,
} ]]

battlers = {}
battlers_internal_index = {}
for i=0,3,1 do
	battlers[i] = {
		pp = {},
	}
end

printers = {}
for i=0,31,1 do
	printers[i] = {}
end

dialog = {}
dialog.cursor = 2
dialog.entries = 1
dialog.text_array = {}
dialog.data_text_array = {}
dialog.ready = 0

timers = {}
function start_timer(timer,delay)
	local now = emu.framecount() 
	
	timers[timer] = now+delay
end

function stop_timer(timer)
	timers[timer] = nil
end

function timer(timerx)
	if timers[timerx] == nil then return false end
	
	local now = emu.framecount() 
	
	if timers[timerx] - now <= 0 then 
		timers[timerx] = nil
		return true 
	else return false end
end

cursor_drawn = {
	x = 0,
	y = 0,
	window_id = 0,
	change = 0,
}
function voice_print_cursor_string()
	for k, v in pairs(windows_print[cursor_drawn.window_id]) do
			--debug_print(v.text .. ";x=" .. v.x)
			--debug_print(string.char(10))	
			
		if v.y == cursor_drawn.y and v.x == cursor_drawn.x+8 then
			voice_string(v.text .. lang[vl].selected)
			return
		end
	end
end

temp_printer_char_event_active = false
temp_printer_char_event_guid = nil
function activate_temp_printer_char_event(activate)
	if activate == true and temp_printer_char_event_active == false then
		temp_printer_char_event_active = true
		if temp_printer_char_event_guid == nil then temp_printer_char_event_guid = event.onmemorywrite(temp_printer_char_event, 0x202018c, "temp_printer_char_event", "System Bus") end 
		debug_print("activate_temp_printer_char_event YES, GUID :" .. temp_printer_char_event_guid)
		debug_print(string.char(10))	
	elseif activate == false and temp_printer_char_event_active == true then
		temp_printer_char_event_active = false
		debug_print("activate_temp_printer_char_event NO")
		debug_print(string.char(10))
		--[[
		if event.unregisterbyid(temp_printer_char_event_guid)  then 
			temp_printer_char_event_active = false
			debug_print("activate_temp_printer_char_event NO")
			debug_print(string.char(10))	
		else
			debug_print("activate_temp_printer_char_event unregister failed")
			debug_print(string.char(10))
		end]]
	end
end

temp_printer_last_x = 0
temp_printer_last_y = 0
temp_printer_last_window_id = 0
temp_printer_last_value = 0

temp_printer_string_end = 0
temp_printer_table = {}
temp_printer_next_string = ""
temp_printer_new_line_y_offset = 0

windows_signature = {}
for i = 0, 31, 1 do
	windows_signature[i] = 0
end

function temp_printer_char_event() --Spaghetto function ahead, is triggered each time a char(with a few exeptions) is printed. 
	local string_ptr = Memory.read(0x202018c, 4)
	local x = Memory.read(0x2020192, 1)
	local y = Memory.read(0x2020193, 1)
	local window_id = Memory.read(0x2020190, 1)
	local value = Memory.read(string_ptr, 1)
	--debug_print(value .. ",")
	
	
	if (value == 0xFF or value == 0xFE) then
		if temp_printer_string_end == 0 then temp_printer_string_end = 1 end
		--if value == 0xFE then temp_printer_end_with_new_line = 1 else temp_printer_end_with_new_line = 0 end
		--debug_print("temp_printer_string_end = 1")
		--debug_print(string.char(10))	
	end --
	if value == 0xEF then -- Cursor selection change
		
		--if window_id ~= cursor_drawn.window_id then
		cursor_drawn.window_id = window_id
		cursor_drawn.change = 1
		cursor_drawn.x = x
		cursor_drawn.y = y
		
		--debug_print("*-*")
		if temp_printer_char_event_active == true then voice_print_cursor_string() end
		--end		
		
		debug_print("*cursor*" .. x .. "," .. y .. "," .. window_id)
		debug_print(string.char(10))	
		
	else
		if temp_printer_string_end == 1 then
			if windows_print[temp_printer_last_window_id] == nil then 
				debug_print("temp_printer_last_window_id:" .. temp_printer_last_window_id)
				debug_print(string.char(10))	
				return 
			end
			
		---debug_print("window_id " .. window_id .. "," .. "misc.values.sMenu_windowId " .. misc.values.sMenu_windowId)
		--debug_print(string.char(10))	
			for k,v in pairs(windows_print[temp_printer_last_window_id]) do
				--debug_print("y:"..v.y)
				--debug_print(string.char(10))	
				if v.y == temp_printer_last_y+temp_printer_new_line_y_offset and v.x == temp_printer_last_x then
					debug_print("removed same place:"..v.text)
					debug_print(string.char(10))	
					table.remove(windows_print[temp_printer_last_window_id],k)
				end
				
				if emu.framecount() - v.gametime > 15 then
					debug_print("removed too old:"..v.text)
					debug_print(string.char(10))	
					table.remove(windows_print[temp_printer_last_window_id],k)
				end
			end
			local window_signature = memory.read_u32_le(0x2020005+temp_printer_last_window_id*12)
			if window_signature ~= windows_signature[temp_printer_last_window_id] then windows_print[temp_printer_last_window_id] = {} end
			table.insert(windows_print[temp_printer_last_window_id],{text = temp_printer_next_string,y = temp_printer_last_y+temp_printer_new_line_y_offset,x = temp_printer_last_x,gametime = emu.framecount() })
			windows_signature[temp_printer_last_window_id] = window_signature
		
			if window_id ~= cursor_drawn.window_id and temp_printer_char_event_active == true then --misc.values.sMenu_windowId then 
				voice_string(temp_printer_next_string .. ".",0) 
				debug_print(temp_printer_next_string .. "*" .. temp_printer_last_y)
				debug_print(string.char(10))	
			else

			end 
		
			--table.insert(temp_printer_table,{text = temp_printer_next_string,pos = temp_printer_last_y})
			

			
			temp_printer_string_end = 2			
		end
		
		if (temp_printer_last_x == x and temp_printer_last_y == y) == false or temp_printer_last_value == 0xFE or temp_printer_last_window_id ~= window_id then
			temp_printer_next_string = ""
			temp_printer_string_end = 0
			if temp_printer_last_value == 0xFE then temp_printer_new_line_y_offset = temp_printer_new_line_y_offset+16 else temp_printer_new_line_y_offset = 0 end

		end
		
		if temp_printer_string_end == 0 then
			local chr = chars[value]		
			if chr == nil then chr = " " end
			if (chr == "?" and value ~= 0xAC) then chr = " " end	
			temp_printer_next_string = temp_printer_next_string .. chr
		end
			
	end
	
	temp_printer_last_x = x
	temp_printer_last_y = y
	temp_printer_last_window_id = window_id
	temp_printer_last_value = value
		
end

function check_no_input()
	local ipt = input.get()
	local i = 0

	for k, v in pairs(ipt) do
		i=i+1
	end

	if i == 0 then return true else return false end
end

function voice_when_no_input()
	local function doo(var)
		if check_no_input() and var ~= "" then
			if type(var) == "table" then
				if emu.framecount() > var.fc then
					voice_string(var.str,var.pr)
					var = ""
				end
			else
				voice_string(var)
				var = ""
			end		
		end
		
		return var
	end
	
	voice_no_input_2 = doo(voice_no_input_2)
	voice_no_input = doo(voice_no_input)

end

function advance_dialog()
	if dialog.ready == 1 then 
		dialog.ready = 0
	else 
		if dialog.cursor <= dialog.entries  and dialog.cursor > 1 then 
			comm.socketServerSendBytes(dialog.data_text_array[dialog.cursor-1])
			debug_print(dialog.text_array[dialog.cursor-1])
			debug_print(" " .. "ed" .. string.char(10))
		end
		return 
	end

	if dialog.cursor <= dialog.entries then
	
		--debug_print(dialog.text_array[dialog.cursor])
		--debug_print(" " .. "ed" .. string.char(10))
		comm.socketServerSendBytes(dialog.data_text_array[dialog.cursor]) 
		
		voice_log[voice_log_size+1] = clone(dialog.data_text_array[dialog.cursor])
		voice_log_size = voice_log_size + 1
		
		dialog.cursor = dialog.cursor + 1
		--debug_print(dialog.cursor ..string.char(10))
		
		
	end
	--debug_print(input.get())
	--debug_print(string.char(10))
end



function get_data_string_at_adress(addr,add_command)
	local add_command = add_command or false
	local data_str = {}
	local i = 0
	
	if add_command == true then 
		table.insert(data_str,1)
		--data_str[1] = 1
		--debug_print("get_data_string_at_adress command true")
		--debug_print(string.char(10))	
	end
	
	while(1) do
		if i > 1024 then 
			debug_print("get_data_string_at_adress overflow")
			debug_print(string.char(10))			
			break 
		end
		local value = memory.read_u8(addr+i)
		
		
		--data_str[i+1] = value
		table.insert(data_str,value)

		i = i + 1
		if value == 0xFF then break end
	end
	return data_str
end

function split_data_string(data_str)
	local t = {}
	local entries = 0
	local value = 0
	local i = 0
	local j = 0
	
	while true do
		entries = entries + 1
		t[entries] = {}
		j = 1
		
		t[entries][j] = 1 --first byte is command
		
		while true do
			j = j + 1
			
			
			t[entries][j] = data_str[i]
			i = i + 1
			if data_str[i] == 0xFA or data_str[i] == 0xFB or data_str[i] == 0xFF then break end
		end
		
		--debug_print(t[entries])
		--debug_print(string.char(10))
		if data_str[i] == 0xFF then break end
		
	end
	
	
	return t,entries
end

function scan_values()

	scan(joy_state)

	scan(misc)
	
	scan(tiles)	
	
	--old_bag_position = shallowcopy(bag_position)
	--scan_bag_position()
	--change_table_update(bag_position,old_bag_position,change_bag_position)		
	
	scan_windows()

	if misc.values.inBattle == 1 then 
		old_battle_values = clone(battle_values)
		scan_battle_values()
		change_table_update(battle_values,old_battle_values,change_battle_values)		
	else
		--scan_tasks()
		scan(object_events)
	end
	
end

function scan_battle_values()
	function scan_battler_table(battler_table,pointer,size,read_size)
		local read_size = read_size or size
		for i = 1,4,1 do
			battler_table[i] = Memory.read(pointer+(i-1)*size, read_size)
		end
	end
		
	local b = battle_values
	
	scan_battler_table(b.actionCursor,0x20244ac,1)
	scan_battler_table(b.moveCursor,0x20244b0,1)
	scan_battler_table(b.battle_func,0x3005d60,4,2)
	
	for i = 1,4,1 do
		for j = 1,4,1 do
			b.moves[i][j] = Memory.read(0x2023068+(i-1)*0x200+(j-1)*2, 2)
		end		
	end
		
	b.MUPlayerCur = Memory.read(0x3005d74, 1)
end

function reset_cursors()
	function reset_battler_table(pointer)
		for i = 1,4,1 do
			memory.writebyte(pointer+(i-1), 0x00)
		end
		
		reset_battler_table(b.actionCursor,0x20244ac,1)
		reset_battler_table(b.moveCursor,0x20244b0,1)
	end	
end

function scan_bag_position()
	if misc.values.callback2 == callbacks[GameSettings.gamename].bag then 
		bag_position.pocket = Memory.read(0x203ce58+5, 1)
		local p = bag_position.pocket
		bag_position.pos = Memory.read(0x203ce58+8+p*2, 2) + Memory.read(0x203ce58+8+10+p*2, 2)
		local ListBuffer2_ptr = Memory.read(0x203ce78, 4)
		bag_position.name = get_string_at_adress(ListBuffer2_ptr+bag_position.pos*24)
		bag_name = get_data_string_at_adress(ListBuffer2_ptr+bag_position.pos*24,true)
	end

end

ally_battler1 = battlers[1]
ally_battler2 = battlers[2]
function scan_battlers()
	ally_battler1 = nil
	ally_battler2 = nil
	local BattlersCount = Memory.read(0x202406c, 1)
	for i = 1, BattlersCount, 1 do
		local p = (i-1)*0x58
		local position = Memory.read((i-1)+0x2024076, 1)
		battlers_internal_index[position] = i-1
		
		battlers[position].specie = Memory.read(p+0x2024084, 2)
		battlers[position].hp = Memory.read(p+0x2024084+0x28, 2)
		battlers[position].maxHP = Memory.read(p+0x2024084+0x2C, 2)
		battlers[position].percent_hp = round(battlers[position].hp/battlers[position].maxHP*100)
		battlers[position].level = Memory.read(p+0x2024084+0x2A, 1)
		battlers[position].name = get_string_at_adress(p+0x2024084+0x30)
		battlers[position].personality = Memory.read(p+0x2024084+0x48, 4)
		battlers[position].pp[1] = Memory.read(p+0x2024084+0x24, 1)
		battlers[position].pp[2] = Memory.read(p+0x2024084+0x25, 1)
		battlers[position].pp[3] = Memory.read(p+0x2024084+0x26, 1)
		battlers[position].pp[4] = Memory.read(p+0x2024084+0x27, 1)
				
		--p = i-1
		
		
		if position == 3 or position == 1 then battlers[position].friendly = 0 else 
			battlers[position].friendly = 1 
			if position == 0 then 
				ally_battler1 = battlers[position]
			else
				ally_battler2 = battlers[position]
			end
			--debug_print(battlers[i].pp)	
		end
		if position == 0 or position == 3 then battlers[position].side = "left" else battlers[position].side = "right" end 
	end
	
	return BattlersCount
end

fishing_bite = 0
old_step = 0
function scan_fishing()
	local prevent_step = memory.read_u8(0x2037590+6)
	if prevent_step == 0 then return end
	
	for i=0, 16 do
		local p = i*40
		local isActive = memory.read_u8(p+0x3005e00+4) --gTasks
		
		if isActive == 1 then
			local fishing_gfx = memory.read_u8(p+0x3005e00+7+29)
			if fishing_gfx == object_event_gfx.MAY_NORMAL or 
			fishing_gfx == object_event_gfx.MAY_MACH_BIKE or 
			fishing_gfx == object_event_gfx.MAY_ACRO_BIKE or 
			fishing_gfx == object_event_gfx.MAY_SURFING or 
			--fishing_gfx == object_event_gfx.BRENDAN_NORMAL or 
			fishing_gfx == object_event_gfx.BRENDAN_MACH_BIKE or 
			fishing_gfx == object_event_gfx.BRENDAN_ACRO_BIKE or 			
			fishing_gfx == object_event_gfx.BRENDAN_SURFING then 

				local step = memory.read_u8(p+0x3005e00+8)
				--debug_print(step)	
				if  step == 7 and old_step < 7 then --fishing bite task step
					if fishing_bite == 0 then play_sound("fishing.wav",0) end
					fishing_bite = 1
					return
				elseif step == 8 then 
					play_sound("fishing.wav",0)

				else
					fishing_bite = 0

				end
				old_step = step
			end
			
		end
	end
end

function battlers_stats_resume()
	local BattlersCount = scan_battlers()
	
	if BattlersCount == 2 then
		local a = battlers[0]
		local e = battlers[1]
		
		--[[if battlers[1].friendly == 0 then 
			a = battlers[2]
			e = battlers[1]
		end]]
		
		voice_string(voice_battlers_duo(vl, a, e))
	else
		voice_string(voice_battlers_multi(vl,battlers))
	end
end

windows = {}
old_windows = {}
last_new_window = 0
windows_count = 0
--old_windows_count = 0
--cursor_drawn_window_id = -1
--cursor_drawn_change = 0
windows_print = {}

--[[window_write_event = {}
window_write_event[0] = function()	windows_print[0] = {}	end
window_write_event[1] = function()	windows_print[1] = {}	end
window_write_event[2] = function()	windows_print[2] = {}	end
window_write_event[3] = function()	windows_print[3] = {}	end
window_write_event[4] = function()	windows_print[4] = {}	end
window_write_event[5] = function()	windows_print[5] = {}	end
window_write_event[6] = function()	windows_print[6] = {}	end
window_write_event[7] = function()	windows_print[7] = {}	end
window_write_event[8] = function()	windows_print[8] = {}	end
window_write_event[9] = function()	windows_print[9] = {}	end
window_write_event[10] = function()	windows_print[10] = {}	end
window_write_event[11] = function()	windows_print[11] = {}	end
window_write_event[12] = function()	windows_print[12] = {}	end
window_write_event[13] = function()	windows_print[13] = {}	end
window_write_event[14] = function()	windows_print[14] = {}	end
window_write_event[15] = function()	windows_print[15] = {}	end
window_write_event[16] = function()	windows_print[16] = {}	end
window_write_event[17] = function()	windows_print[17] = {}	end
window_write_event[18] = function()	windows_print[18] = {}	end
window_write_event[19] = function()	windows_print[19] = {}	end
window_write_event[20] = function()	windows_print[20] = {}	end
window_write_event[21] = function()	windows_print[21] = {}	end
window_write_event[22] = function()	windows_print[22] = {}	end
window_write_event[23] = function()	windows_print[23] = {}	end
window_write_event[24] = function()	windows_print[24] = {}	end
window_write_event[25] = function()	windows_print[25] = {}	end
window_write_event[26] = function()	windows_print[26] = {}	end
window_write_event[27] = function()	windows_print[27] = {}	end
window_write_event[28] = function()	windows_print[28] = {}	end
window_write_event[29] = function()	windows_print[29] = {}	end
window_write_event[30] = function()	windows_print[30] = {}	end
window_write_event[31] = function()	windows_print[31] = {}	end

function test()
	debug_print("window_write_event")	
	debug_print(string.char(10))
end

function add_windows_write_events()
	debug_print("add_windows_write_events()")	
	debug_print(string.char(10))
	local window_write_event_guid = 0
	--for i = 0,31,1 do
	--	window_write_event_id = i
	--	window_write_event_guid = event.onmemorywrite(test, 0x2020004+i*12, "window_write_event" .. i, "System Bus")
	event.onmemorywrite(test, 0x2020018, "window_write_event", "System Bus")
	--end

end
add_windows_write_events() ]]

for i = 0,31,1 do
	--windows[i].string_array = {}
	windows_print[i] = {}
end
function scan_windows()
	local windows = windows
	local windows_print = windows_print	
	--if misc.change_values.callback2 == 0 then return end
	old_windows = shallowcopy(windows)
	
	--old_windows_count = windows_count
	windows_count = 0

	for i = 0,31,1 do
		--first = 
		if memory.read_u8(0x2020004+i*12) ~= 255 then

			windows_count = windows_count + 1
			windows[i] = 1
			last_new_window = i
			--if misc.values.sMenu_windowId == i then cursor_drawn.window_id = i end
				
		else
			windows[i] = 0
			windows_print[i] = {}		
			if cursor_drawn.window_id == i then 
				--old_cursor_drawn_window_id = cursor_drawn_window_id
				--cursor_drawn_window_id = -1 
				cursor_drawn.window_id = -1
			end
		end
		

	end
	
	
	--debug_print(windows_count)
	--debug_print("x")
	
	--[[
	if old_windows_count ~= windows_count then
		debug_print("windows_count:"..windows_count)
		debug_print(string.char(10))		
		debug_print("oldwindows_count:"..old_windows_count)
		debug_print(string.char(10))	
	end ]]
	
end

function print_windows_signature()
	local str = ""
	for k, v in pairs(windows) do
		str = str .. v .. ","
	end

	debug_print(str)
	debug_print(string.char(10))	
end

function lua_string_to_data_string(str, command)
	if str == nil then return end
	-- Hacking my way through the character encoding jungle here, sorry.
	if type(str) == "number" then
		str = tostring(str)
	end
	
	local data_str = {}
	local i = nil
	local j = 2
	local ch = nil
	local special_ch = false
	data_str[1] = command --first byte is command
	
	if command ~= 1 then  
		for i=2,string.len(str)+1,1 do
			ch = string.byte(string.sub(str,i-1,i-1))
			if ch ~= 195 then 
				if special_ch == true then ch = ch + 0x40 end
				data_str[j] = ch 
				--debug_print(data_str[j] .. ",")
				j = j + 1
				special_ch = false
			else 
				special_ch = true
			end		
		end
	else
		for i=2,string.len(str)+1,1 do
			ch = string.byte(string.sub(str,i-1,i-1))
			data_str[j] = ch 
			j = j + 1
		end	
	end

	--debug_print("lua_string_to_data_string called")
	--debug_print(string.char(10))

	--debug_print(data_str)
	--debug_print(string.char(10))
	
	return data_str
end

function voice_string(str,dolog)
	if str == nil then return end
	dolog = dolog or 1
	
	--debug_print("callback2: " .. misc.values.callback2)
	--debug_print(string.char(10))
	if misc.values.callback2 == 0 then return end

	voice_position_trigger = 0
	voice_no_input = ""

	local data_str = lua_string_to_data_string(str,2)


	
	--debug_print("voice_string called: " .. str)
	--debug_print(string.char(10))	
	
	--comm.socketServerSend(str)
	comm.socketServerSendBytes(data_str) 
	
	if dolog == 1 then 
		voice_log[voice_log_size+1] = clone(data_str)
		voice_log_size = voice_log_size + 1
	end
end

function play_sound(str,priority)
	if misc.values.callback2 == 0 then return end
	local command = 3
	if priority == 0 then command = 4 else command = 3 end
	local data_str = lua_string_to_data_string(str,command)

	--debug_print("sound to play: " .. str)
	--debug_print(string.char(10))	

	comm.socketServerSendBytes(data_str) 
end

function voice_battle_action()
	local action_cursor = battle_values.actionCursor[last_active_pokemon]

	if action_cursor == 0 then
		voice_string(lang[vl].fight)
	elseif action_cursor == 1 then
		voice_string(lang[vl].bag)
	elseif action_cursor == 2 then
		voice_string(lang[vl].pokemon)
	elseif action_cursor == 3 then
		voice_string(lang[vl].run)		
	end
end

function voice_battle_move()
	local lap = last_active_pokemon
	
	--local pp = battlers[lap-1].pp[battle_values.moveCursor[lap]+1]
	
	--local attack_n = battle_values.moves[lap][battle_values.moveCursor[lap]+1]

	--voice_string(try_concat({lang[vl].move[attack_n+1] , " " , pp}))

	read_window(3+battle_values.moveCursor[lap])
	read_window(9)
	read_window(10)

end

--[[
function parse_background_register(n)
	pbgr[n].size = Utils.getbits(bgr[n], 14, 2)
	pbgr[n].screen = Utils.getbits(bgr[n], 8, 5)
	pbgr[n].character = Utils.getbits(bgr[n], 2, 2)
	pbgr[n].priority = Utils.getbits(bgr[n], 0, 2)
end
]]

function set_dialog_speed()
	local gSaveBlock2Ptr = Memory.read(0x3005d90, 4)
	local dialog_speed_byte = Memory.read(gSaveBlock2Ptr+0x14, 1)
	
	if access_settings.dialog_speed == 0 then	
		dialog_speed_byte = set_bit(dialog_speed_byte,0,0)
		dialog_speed_byte = set_bit(dialog_speed_byte,1,0)
		dialog_speed_byte = set_bit(dialog_speed_byte,2,0)
	elseif access_settings.dialog_speed == 1 then
		dialog_speed_byte = set_bit(dialog_speed_byte,0,1)
		dialog_speed_byte = set_bit(dialog_speed_byte,1,0)
		dialog_speed_byte = set_bit(dialog_speed_byte,2,0)
	else
		dialog_speed_byte = set_bit(dialog_speed_byte,0,0)
		dialog_speed_byte = set_bit(dialog_speed_byte,1,1)
		dialog_speed_byte = set_bit(dialog_speed_byte,2,0)
	end
	
	memory.writebyte(gSaveBlock2Ptr+0x14, dialog_speed_byte) 
end

last_active_pokemon = 1
function values_change_logic()
	local misc = misc

	--battle events logic
	if misc.values.inBattle == 1 then
		if misc.change_values.inBattle == 1 and access_settings.debuging > 0 then
			savestate.save("battle_debug.state", true)
			debug_print("battle_debug save state saved")
			debug_print(string.char(10))	
		end
			
		--determining pokemon interface focus
		if change_battle_values.battle_func[1] == 1 then
			last_active_pokemon = 1
		elseif change_battle_values.battle_func[3] == 1 then
			last_active_pokemon = 3
		end
		
		local lap = last_active_pokemon

		--voice attacks name
		if change_battle_values.moveCursor[lap] == 1 and battle_values.battle_func[lap] == b_f["move"] then
			voice_battle_move()
		end
		if change_battle_values.battle_func[lap] == 1 and battle_values.battle_func[lap] == b_f["move"] then
			voice_string(lang[vl].move_menu)		
			voice_battle_move()
			debug_print("*******voice attacks name")	
			debug_print(string.char(10))	
		end

		--voice player's battler's action
		if change_battle_values.actionCursor[lap] == 1 and battle_values.battle_func[lap] == b_f["action"] then
			voice_battle_action()
		end
		if change_battle_values.battle_func[lap] == 1 and battle_values.battle_func[lap] == b_f["action"] then
			local name = "" 
			if battlers[lap-1].name ~= nil then name = battlers[lap-1].name end
			voice_string(lang[vl].action_menu .. name)	
			
			voice_battle_action()
		end
		
		-- target select
		if change_battle_values.MUPlayerCur == 1 and battle_values.battle_func[lap] == b_f["target"] then --battle_values.MUPlayerCur ~= 0xFF then
			if battlers[battle_values.MUPlayerCur].name ~= nil then
				voice_string(battlers[battle_values.MUPlayerCur].name .. lang[vl].targeted)
			end
		end

		-- voice player's battler new turn
		if change_battle_values.battle_func[lap] == 1 and battle_values.battle_func[lap] == b_f["new turn"] then		
			debug_print("new turn")
			debug_print(string.char(10))	
			battlers_stats_resume()
		end	
	elseif misc.values.callback1 ~= 0 then -- not battle, game in overworld
		scan_fishing()
		
				
		if misc.change_values.x == 1 or misc.change_values.y == 1 then

		end

		--player move
		if (misc.change_values.x_new == 1) or  (misc.change_values.y_new == 1) then
			if draw_the_map > 0 then map = scan_collision_map() end
		end
		if (misc.change_values.x == 1) or  (misc.change_values.y == 1) then
			
			if (misc.values.x ~= 0) and  (misc.values.y ~= 0) then
				play_step()
				
				if misc.values.bike_speed == 0 and check_no_input() then voice_position_trigger = 1
						
				else 
					voice_position_trigger = 0 
					voice_no_input = ""	
				end
				
			end
			
		end
		
		--voice position
		if voice_position_trigger == 1 and misc.values.runningState == 0 then 
			voice_no_input = {str=misc.values.x .. "  " .. misc.values.y, fc=emu.framecount()+60,pr=0}
			voice_position_trigger = 0

		end
		if misc.values.bike_speed ~= 0 then
			voice_position_trigger = 0
			voice_no_input = ""
		end

		--When map change
		if misc.change_values.map_name == 1 then
			--voice_string(lang[vl].youareon .. misc.values.map_name)	
			--voice_no_input_2 = lang[vl].youareon .. misc.values.map_name	
			--debug_print(misc.values.map_name)
			play_sound("notification.wav",1)
		end	

		if misc.change_values.gMapHeader == 1 then
			debug_print("map header change")
			debug_print(string.char(10))				

			step_outside = can_cycle()
			
			update_map_header()
			if draw_the_map > 0 then map = scan_collision_map() end
			
		end

		-- Read region map
		if (misc.change_values.rm_x == 1 or misc.change_values.rm_y == 1) and misc.old_values.region_map ~= 0 and misc.values.region_map ~= 0 and (misc.values.callback2 == callbacks[GameSettings.gamename].region_map1 or misc.values.callback2 == callbacks[GameSettings.gamename].region_map2) then -- then

			local map_name = get_string_at_adress(misc.values.region_map+0x04)
			--debug_print(map_name)
			--debug_print(string.char(10))	
			--debug_print(#map_name)
			--debug_print(string.char(10))		
			if #map_name <= 20 then voice_string(misc.values.rm_x .. "  " .. misc.values.rm_y .. " . " .. map_name) end
		end

	else
		--title screen
		if misc.change_values.callback2 == 1 and misc.values.callback2 == callbacks[GameSettings.gamename].title_screen then -- 

			voice_string(lang[vl].game_title)
			set_dialog_speed()
			old_printer_string = "."
		end
		
		--main menu
		if misc.values.callback2 == callbacks[GameSettings.gamename].main_menu then
			scan(main_menu)
			
			local cursor_selection = {}
			
			if main_menu.values.menu_type == 0 then
				cursor_selection[0] = lang[vl].new_game
				cursor_selection[1] = lang[vl].options
			elseif main_menu.values.menu_type == 1 then
				cursor_selection[0] = lang[vl].continue
				cursor_selection[1] = lang[vl].new_game
				cursor_selection[2] = lang[vl].options
			elseif main_menu.values.menu_type == 2 then
				cursor_selection[0] = lang[vl].continue
				cursor_selection[1] = lang[vl].new_game
				cursor_selection[2] = lang[vl].mystery_gift
				cursor_selection[3] = lang[vl].options
			elseif main_menu.values.menu_type == 3 then
				cursor_selection[0] = lang[vl].continue
				cursor_selection[1] = lang[vl].new_game
				cursor_selection[2] = lang[vl].mystery_gift
				cursor_selection[3] = lang[vl].mystery_events
				cursor_selection[4] = lang[vl].options
			end
			
			if main_menu.change_values.cursor == 1 then
				voice_string(cursor_selection[main_menu.values.cursor] .. lang[vl].selected)
			--debug_print(cursor_selection[main_menu.values.cursor])
			--debug_print(string.char(10))	
			end

		end
	end

	-- fly map
	if (misc.change_values.fm_x == 1 or misc.change_values.fm_y == 1) and misc.old_values.fly_map ~= 0 and misc.values.fly_map ~= 0 then --values.callback2 == 136081469 then

		local map_name = get_string_at_adress(misc.values.fly_map+0x04)
		debug_print(map_name.len)
		debug_print(string.char(10))	
		if map_name.len >= 20 then map_name = "" end
		--debug_print(map_name)
		--debug_print(string.char(10))	
		voice_string(misc.values.fm_x .. "  " .. misc.values.fm_y .. " . " .. map_name)
	end	
	
	-- battle mode start
	if misc.values.inBattle == 1 and misc.change_values.inBattle == 1 then
		activate_temp_printer_char_event(false)
		map = nil
		gui.clearGraphics()
		debug_print("Battle mode start")
		debug_print(string.char(10))	
	end 			
	-- battle mode stop
	if misc.values.inBattle == 0 and misc.change_values.inBattle == 1 then
		old_printer_string = nil -- don't get trigerred here when they init in the next battle
		reset_cursors() --reset battlers cursors values to 0 so they don't get trigerred here when they init in the next battle
		activate_temp_printer_char_event(true)
		debug_print("Battle mode stop")
		debug_print(string.char(10))	
	end 

	-- Read battle or intro dialog
	if misc.values.inBattle == 1 or tiles.values.intro_dialog == 61693 then
		scan_printer_text()
		--debug_print("intro")
		--debug_print(string.char(10))	
	end
	
	-- when dialog sentence end
	if misc.change_values.dialog_state == 1 and misc.values.dialog_state > 0 and misc.old_values.dialog_state == 0 then
		play_sound("stringend.wav",1)	
		dialog.ready = 1
	end
	if misc.change_values.dialog_active == 1 and misc.values.dialog_active == 0 and misc.old_values.dialog_active == 1 then
		play_sound("stringend.wav",1)
		dialog.ready = 1
	end
	
	-- When dialog box appear
	if tiles.change_values.dialog == 1 and (tiles.values.dialog == 61953 or tiles.values.dialog == 0xe270) and misc.values.inBattle == 0 then
		voice_position_trigger = 0
		voice_no_input = ""

		play_sound("blip.wav",1)

		get_printer_text()

	end
	-- When dialog box disappear
	if tiles.change_values.dialog == 1 and tiles.old_values.dialog == 61953 then
		play_sound("blop.wav",1)
	end
	
	-- Dialog restart
	if tiles.values.dialog == 61953 and misc.old_values.dialog_active == 0 and misc.old_values.dialog_state == 0 and misc.values.dialog_active == 1 then
		get_printer_text()
	end 
	
	-- Pokemon party menu
	if misc.change_values.callback2 == 1 and misc.values.callback2 == callbacks[GameSettings.gamename].pokemon_party then
		before_party_menu_temp_printer_char_event_active = temp_printer_char_event_active
		--voice_string(lang[vl].pokemon_choose)
		read_window(8)
		voice_string(lang[vl].slot .. misc.values.party_slotId+1)
		read_window(misc.values.party_slotId)
		activate_temp_printer_char_event(true)
	end
	if misc.change_values.callback2 == 1 and misc.old_values.callback2 == callbacks[GameSettings.gamename].pokemon_party then
		--voice_string(lang[vl].pokemon_choose)
		--read_window(misc.values.party_slotId)

		activate_temp_printer_char_event(before_party_menu_temp_printer_char_event_active)
	end
	if misc.values.callback2 == callbacks[GameSettings.gamename].pokemon_party and misc.change_values.party_slotId == 1 then
		if misc.values.party_slotId == 7 then
			--voice_string(lang[vl].leave)
		else
			--voice_string(voice_party_pokemon_stats(vl,misc.values.party_slotId+1,windows_print[misc.values.party_slotId].text) .. lang[vl].slot .. misc.values.party_slotId+1)
			voice_string(lang[vl].slot .. misc.values.party_slotId+1)
			read_window(misc.values.party_slotId)
		end
	end
	if misc.values.callback2 == callbacks[GameSettings.gamename].pokemon_party and misc.change_values.party_slotId2 == 1 then
		if misc.values.party_slotId2 == 7 then
			--voice_string(lang[vl].leave)
		else
			--voice_string(lang[vl].change .. voice_party_pokemon_stats(vl,misc.values.party_slotId+1,windows_print[misc.values.party_slotId].text) .. lang[vl].slot .. misc.values.party_slotId+1 .. ", " .. lang[vl]._for .. voice_party_pokemon_stats(vl,misc.values.party_slotId2+1,windows_print[misc.values.party_slotId].text) .. lang[vl].slot .. misc.values.party_slotId2+1)
			voice_string(lang[vl].slot .. misc.values.party_slotId2+1)
			read_window(misc.values.party_slotId2)
		end
	end
	
	-- Bag menu

	if misc.old_values.callback2 == callbacks[GameSettings.gamename].bag and misc.change_values.callback2 == 1 then
		--bag_position = {}

		activate_temp_printer_char_event(true)
	end
	if misc.change_values.callback2 == 1 and misc.values.callback2 == callbacks[GameSettings.gamename].bag then
		--debug_print("callbacks[GameSettings.gamename].bag ")
		--debug_print(string.char(10))	
		activate_temp_printer_char_event(false)
	end	
	if misc.values.callback2 == callbacks[GameSettings.gamename].bag then
		scan(bag)
		
		if bag.change_values.name == 1 and bag.change_values.pocket == 0 then
			voice_string(bag.values.name)
			read_window(1)
		end
		
		if bag.change_values.pocket == 1 then
			local p = bag.values.pocket
			if p == 0 then
				voice_string(lang[vl].items_pocket)
			elseif p == 1 then 
				voice_string(lang[vl].balls_pocket)
			elseif p == 2 then 
				voice_string(lang[vl].thhm_pocket)
			elseif p == 3 then 
				voice_string(lang[vl].berries_pocket)
			elseif p == 4 then 
				voice_string(lang[vl].keyitems_pocket)
			end
			
			voice_string(bag.values.name)
		end
	end
	
	-- Shop menu
	--ListMenuItem *sListMenuItems = F0530002?
	
	--ingame keyboard
	if misc.change_values.callback2 == 1 and misc.values.callback2 == callbacks[GameSettings.gamename].ingame_keyboard then
		activate_temp_printer_char_event(false)
		voice_string(lang[vl].game_keyboard .. "... A")
	end
	if misc.values.callback2 == callbacks[GameSettings.gamename].ingame_keyboard then
		--debug_print("game_keyboard_logic() call")	
		---debug_print(string.char(10))	
		game_keyboard_logic()
	end
	if misc.old_values.callback2 == callbacks[GameSettings.gamename].ingame_keyboard and misc.change_values.callback2 == 1 then
		activate_temp_printer_char_event(true)
		--event.onmemorywrite(temp_printer_char_event, 0x202018c, "temp_printer_char_event", "System Bus")  
	end

	--dialog advance
	if joy_state.values["A"] == true and joy_state.change_values["A"] == 1 then
		advance_dialog()
	end
	
	--debug callback1
	if misc.change_values.callback1 == 1 then
		debug_print("misc.values.callback1 changed:" .. misc.values.callback1)
		debug_print(string.char(10))	
	end
end

function can_cycle()
	local flags = Memory.read(0x2037318+0x1a, 1)
	local MAP_ALLOW_CYCLING = Utils.getbits(flags, 0, 1)
	if MAP_ALLOW_CYCLING == 1 then return 1 else return 0 end
end

primary_metatileAttributes = 0
secondary_metatileAttributes = 0
warpEvent = {}
warpEvent_count = 0
connections = {}
connections_count = 0
BgEvent = {}
BgEvent_count = 0
function update_map_header()
	local map_layout = memory.read_u32_le(0x2037318) --misc.values.gMapHeader --Memory.read( misc.values.gMapHeader , 4)
	local primaryTileset = Memory.read(map_layout+0x10 , 4)
	local secondaryTileset = Memory.read(map_layout+0x14 , 4)
	primary_metatileAttributes = Memory.read(primaryTileset+0x10 , 4)
	secondary_metatileAttributes = Memory.read(secondaryTileset+0x10 , 4)
	
	local map_events = Memory.read(0x2037318 + 0x04, 4)
	warpEvent_count = Memory.read(map_events+0x01 , 1)
	local p_warpEvent = Memory.read(map_events+0x08 , 4)
	BgEvent_count = Memory.read(map_events+0x03 , 1)
	local p_BgEvent = Memory.read(map_events+0x10 , 4)
	
	local MapConnections = Memory.read(0x2037318+0x0C , 4)
	connections_count = memory.read_s32_le(MapConnections) --Memory.read(MapConnections, 4)
	local p_connections = Memory.read(MapConnections+0x4 , 4)
	
	debug_print("gMapHeader update " .. ",BgEvent_count " .. BgEvent_count ..  ",connections_count " .. connections_count .. ",p_BgEvents " .. string.format("%x", p_BgEvent) ..  ",p_warpEvent " .. string.format("%x", p_warpEvent) .. ",MapConnections " .. string.format("%x", MapConnections) .. ",p_connections " .. string.format("%x", p_connections))	
	--local object_events_count = Memory.read(map_events, 1)	
	debug_print()
	debug_print(string.char(10))	

	warpEvent = {}
	for i = 1,warpEvent_count,1 do
		local x = Memory.read(p_warpEvent+0x00+(i-1)*8 , 2) + 7
		local y = Memory.read(p_warpEvent+0x02+(i-1)*8 , 2) + 7
		local mapNum = Memory.read(p_warpEvent+0x06+(i-1)*8 , 1)
		local mapGroup = Memory.read(p_warpEvent+0x07+(i-1)*8 , 1)

			--debug_print("x:" .. x .. ",y:" .. y .. ",mapNum:" .. mapNum)	
			--debug_print(string.char(10))			
			
		table.insert(warpEvent,{x=x,y=y,mapNum=mapNum,mapGroup=mapGroup})
				
	end	

	connections = {}
	for i = 1,connections_count,1 do
		local direction = Memory.read(p_connections+0x00+(i-1)*12 , 1)
		table.insert(connections,{direction = direction})
	end

	BgEvent = {}
	for i = 1,BgEvent_count,1 do
		local x = Memory.read(p_BgEvent+0x00+(i-1)*12 , 2) + 7
		local y = Memory.read(p_BgEvent+0x02+(i-1)*12 , 2) + 7
		local kind = Memory.read(p_BgEvent+0x05+(i-1)*12 , 1)	
			
		table.insert(BgEvent,{x=x,y=y,kind=kind})
		--debug_print("x:" .. x .. ",y:" .. y .. ", kind:" .. kind)	
		--debug_print(string.char(10))			
	end	
end


map_x_radius = 4
map_y_radius = 3
function scan_collision_map()
	--start = start or 0

	local map_height = map_y_radius*2+1 --y_radius*2+1
	local map_width = map_x_radius*2+1--x_radius*2+1
	
	local map = {}
	for i = 1,map_height,1 do
		map[i] = {}
		for j = 1,map_width,1 do
			map[i][j] = 0
		end	
	end	
	               
	local gBackupMapLayout_width = Memory.read( 0x3005dc0, 4)
	local gBackupMapLayout_height = Memory.read( 0x3005dc0+4, 4)
	local gBackupMapLayout_map = Memory.read( 0x3005dc0+8, 4)
	
	local function get_addr(x,y)		
		return gBackupMapLayout_map+x*2+y*2*gBackupMapLayout_width
	end
	
	local function get_metatile_behavior(map_tile)
		local metatile_id = Utils.getbits(map_tile,0,10)
		local attributes = nil
		--return metatile_id
		
		if metatile_id < 512 then
			attributes = primary_metatileAttributes
			return Memory.read(attributes+2*metatile_id , 1)
		else
			attributes = secondary_metatileAttributes
			return Memory.read(attributes+2*(metatile_id-512) , 1)
		end
		
		
	end
	
	local function test_collision(x,y)
		if x < 0 or y < 0 or x > gBackupMapLayout_width or y > gBackupMapLayout_height then return 1 end 
		local addr = get_addr(x,y)
		local map_tile =  memory.read_u16_le(addr) --Memory.read(addr, 2)
		if map_tile == 0x03FF then return 1 else
		
			if Utils.getbits(map_tile,10,2) == 1 then return 1
			else 
				return get_metatile_behavior(map_tile) --Utils.getbits(map_tile,0,8)
			end
		end
	end

	local cursor_x = misc.values.x_new - map_x_radius
	local cursor_y = misc.values.y_new - map_y_radius
	map.start_x = cursor_x
	map.start_y = cursor_y
	
	
	for i = 1,map_height,1 do
		
		for j = 1,map_width,1 do
			map[i][j] = test_collision(cursor_x,cursor_y)
			
			
			cursor_x = cursor_x + 1
		end	
		cursor_x = cursor_x - map_width
		cursor_y = cursor_y + 1
	end
	
	for k, v in pairs(warpEvent) do --i = 1,warpEvent_count,1 do
		
		if is_in_boundary(v.x, v.y, map.start_x, map.start_y, map.start_x+map_width-1, map.start_y+map_height-1) then
		
			map[v.y-map.start_y+1][v.x-map.start_x+1] = "warp"
		end
		
	end
	--debug_print("PC x:" .. misc.values.x_new .. ",y:" .. misc.values.y_new)	
	--debug_print(string.char(10))	
	return map
end

draw_the_map = 0
function draw_map()
	if map == nil then return end

	local map_height = #map
	local map_width = #map[1]
	
	local rectangle_width = 240/map_width
	local rectangle_height = 160/map_height

	local triangle = {
		[2] = { --up
			{0.5*rectangle_width,0.1*rectangle_height},
			{0.1*rectangle_width,0.9*rectangle_height},
			{0.9*rectangle_width,0.9*rectangle_height},
		},
		[1] = { --down
			{0.5*rectangle_width,0.9*rectangle_height},
			{0.1*rectangle_width,0.1*rectangle_height},
			{0.9*rectangle_width,0.1*rectangle_height},
		},
		[3] = { --left
			{0.1*rectangle_width,0.5*rectangle_height},
			{0.9*rectangle_width,0.1*rectangle_height},
			{0.9*rectangle_width,0.9*rectangle_height},
		},
		[4] = { --right
			{0.9*rectangle_width,0.5*rectangle_height},
			{0.1*rectangle_width,0.1*rectangle_height},
			{0.1*rectangle_width,0.9*rectangle_height},
		},
	}
	
	local function fill_tile(j,i,color,image_path)
		--if image_path == nil then 
			gui.drawRectangle((j-1)*rectangle_width,(i-1)*rectangle_height,rectangle_width,rectangle_height,color,color)
		--else
		--gui.drawText((j-1)*rectangle_width,(i-1)*rectangle_height, map[i][j])
			--gui.drawImage(image_path, (j-1)*rectangle_width, (i-1)*rectangle_height, rectangle_width, rectangle_height,true) 
		--end
	end
	
	--local arrow_anim_color = 0
	
	local game_time = emu.framecount()
	local function wave(low,high,phase,period) --bugged somewhere I think
		--period = period * 60
		--phase = phase * 60
		local y = math.cos((game_time/60+phase)*2*math.pi/period)
		local amplitude = (high-low)/2
		y = y*amplitude+low
		--debug_print( (game_time/60+phase)*2*math.pi/period ..",")	
		
		return  math.modf(y)
	end
	local function saw_tooth_func(low,high,phase,period)
		period = period * 60
		phase = phase * 60
		local period_start = math.modf(game_time/period)*period+phase
		local x = game_time - period_start
		local rise = high-low
		local y = x/period*rise+low
		--debug_print( math.modf(y)..",")	
		return math.modf(y)
	end
	
	local color_func = saw_tooth_func(0x20,0xFF,0,3)
	local arrow_oe_color = 0xFF200020 + color_func*0x100
	
	color_func = saw_tooth_func(0x20,0xFF,0,3)
	local bge_color = 0xFF002020 + color_func*0x10000
	
	color_func = wave(0x20,0x40,0,8)
	local wave1_color = 0xFF0000FF + color_func*0x100 + color_func*0x10000

	color_func = wave(0x20,0x40,4,8)
	local wave2_color = 0xFF0000FF + color_func*0x100 + color_func*0x10000
	
	local function checker_board(x,y,v1,v2)
		if math.mod(y, 2) == 0 then
			if math.mod(x, 2) == 0 then return v1 else return v2 end
		else
			if math.mod(x, 2) == 0 then return v2 else return v1 end
		end
	end
	
	gui.drawRectangle(0,0,240,160,0xFF000000,0xFF000000) --background
	
	for i = 1,map_height,1 do
		
		for j = 1,map_width,1 do
			if map[i][j] == 1 then			
				--gui.drawRectangle((j-1)*rectangle_width,(i-1)*rectangle_height,rectangle_width,rectangle_height,0xFFFFFFFF,0xFFFFFFFF)
				fill_tile(j,i,0xFFE0E0E0,DATA_FOLDER .. "/images/walls.bmp")
			elseif map[i][j] == metatile.TALL_GRASS or map[i][j] == metatile.LONG_GRASS then
				fill_tile(j,i,0xFF000000)
				gui.drawEllipse((j-1)*rectangle_width, (i-1)*rectangle_height, rectangle_width, rectangle_height, 0xFF007700, 0xFF009900) 
				--gui.drawEllipse(0, 0, 20, 20, 0xFF009900, 0xFF009900) 
			elseif map[i][j] == metatile.POND_WATER or map[i][j] == metatile.SEMI_DEEP_WATER or map[i][j] == metatile.OCEAN_WATER then
				fill_tile(j,i,checker_board(j,i,wave1_color,wave2_color))
			elseif map[i][j] == metatile.DEEP_WATER then
				fill_tile(j,i,0xFF101066)
			elseif map[i][j] == "warp" then
				fill_tile(j,i,arrow_oe_color)
			else
				--gui.drawRectangle((j-1)*rectangle_width,(i-1)*rectangle_height,rectangle_width,rectangle_height,0xFF000000,0xFF000000)
				--fill_tile(j,i,0xFF000000)
			end 
			
		end	
	
	end	
	
	if object_events == nil then return end
	--debug_print(object_events)	
	for k, v in pairs(object_events.values) do
		
		if type(v) == "table" and is_in_boundary(v.pos_x, v.pos_y, map.start_x, map.start_y, map.start_x+map_width-1, map.start_y+map_height-1) and v.active == 1 then
			--debug_print("1")	
			gui.drawPolygon(triangle[v.facingDirection], (v.pos_x-map.start_x)*rectangle_width, (v.pos_y-map.start_y)*rectangle_height, 0xFFFFFFFF, 0xFFFFFFFF) 
		end
	end
	
	for i = 1,BgEvent_count,1 do
		local bge = BgEvent[i]
		local bge_x = (bge.x-map.start_x)*rectangle_width
		local bge_y = (bge.y-map.start_y)*rectangle_height
		if is_in_boundary(bge.x, bge.y, map.start_x, map.start_y, map.start_x+map_width-1, map.start_y+map_height-1) then
			if bge.kind == 0 or bge.kind == 7 then
				gui.drawEllipse(bge_x, bge_y, rectangle_width, rectangle_height, bge_color, bge_color) 
			elseif bge.kind == 1 then
				gui.drawPolygon(triangle[2], bge_x, bge_y, bge_color, bge_color) 
			elseif bge.kind == 2 or bge.kind == 8 then
				gui.drawPolygon(triangle[1], bge_x, bge_y, bge_color, bge_color) 
			elseif bge.kind == 3 then
				gui.drawPolygon(triangle[4], bge_x, bge_y, bge_color, bge_color) 
			elseif bge.kind == 4 then
				gui.drawPolygon(triangle[3], bge_x, bge_y, bge_color, bge_color) 
			end
		end
	end
end


--menu_enum = {}
menu_entries = {}
function start_menu_logic()
	local change = 0

	if misc.values.sSaveDialogTimer == 5 and misc.change_values.sSaveDialogTimer == 1 then
		local size = Memory.read(0x203760f, 1)
		
		--menu_enum = {}
		menu_entries = {}
		
		--for i = 1,size,1 do
		--	menu_enum[i] = Memory.read(0x2037610+i-1, 1)+1
		--end

		local last_entry = get_string_at_adress(0x02021FC4)
		table.insert(temp_printer,last_entry)
		

		
		for i = 1,size,1 do
			menu_entries[i] = temp_printer[#temp_printer-size+i]
		end		
		
		debug_print("+++")	
		debug_print(menu_entries)	
		debug_print(string.char(10))			
		
		temp_printer = {}		
		change = 1
	end
	
	if misc.change_values.start_menu_cursor == 1 then change = 1 end
	
	if change == 1 then
		voice_string(menu_entries[misc.values.start_menu_cursor+1])
		--voice_string(lang[vl].menus.start_menu[misc.values.start_menu_cursor+1])
	end
	
end

step_timer = 0
last_step = 0
step_outside = 0
step = "step1.wav"
function play_step()
	local timer = emu.framecount()
	local delta = timer - step_timer
	
	--debug_print(misc.values.metatile .. "-")	
	
	if step_outside == 0 then
		step_type = "step"
	else
		step_type = "outside_step"
	end
	
	local function before_ret()
		last_step = misc.values.metatile
		step_timer = timer	
	end
	
	--debug_print(delta .. " " ) 
	if delta <= 6 then 
		--step_timer = timer
		last_step = misc.values.metatile
		return 
	end
	--step_timer = timer
	
	
	
	if step == 1 then step = 2 else step = 1 end

	if misc.values.bike_speed > 0 then
		play_sound("bicycle.wav",0)
		before_ret()
		return
	elseif bit.band(misc.values.avatar_flags , 16) == 16 then
		play_sound("bubble_step" .. step .. ".wav",0)
		before_ret()
		return
	end
	
	if last_step == 17 and misc.values.metatile == 18 then
		play_sound("bubble_step" .. step .. ".wav",1)
		before_ret()
		return
	end
	

	--if step == "step1.wav" then step = "step2.wav" else step = "step1.wav" end
	
	local sound = "step1.wav"
	local priority = 0
	
	if misc.values.metatile == metatile.SAND then
		sound = "sand_step" .. step .. ".wav"
	elseif misc.values.metatile == metatile.UNUSED_CAVE then
		sound = "cavern_step" .. step .. ".wav"
	elseif misc.values.metatile == metatile.TALL_GRASS or misc.values.metatile == metatile.LONG_GRASS then
		sound = "short_grass_step" .. step .. ".wav"
	elseif misc.values.metatile == metatile.OCEAN_WATER then
		sound = "ocean_step.wav"
	elseif misc.values.metatile == metatile.DEEP_WATER then	
		sound = "deep_ocean_step.wav"
	elseif misc.values.metatile == metatile.PUDDLE or misc.values.metatile == metatile.SHALLOW_WATER then
		sound = "puddle_step.wav"
	elseif misc.values.metatile == metatile.MUDDY_SLOPE then
		sound = "slide.wav"
	elseif misc.values.metatile == metatile.EASTWARD_CURRENT or misc.values.metatile == metatile.WESTWARD_CURRENT or misc.values.metatile == metatile.NORTHWARD_CURRENT or misc.values.metatile == metatile.SOUTHWARD_CURRENT then
		sound = "water_flow.wav"
		if last_step ~=  metatile.EASTWARD_CURRENT and last_step ~= metatile.WESTWARD_CURRENT and last_step ~= metatile.NORTHWARD_CURRENT and last_step ~= metatile.SOUTHWARD_CURRENT then 
			priority = 1 
			--debug_print("#")
		else 
			priority = 0 
			--debug_print(old_values.metatile .. " ")
		end 
	else
		sound = step_type .. step .. ".wav"
	end
	
	--debug_print(sound)	
	--debug_print(string.char(10))	
	
	
	play_sound(sound,priority)
	
	before_ret()
	return
end

key = ""
function game_keyboard_logic()

	local keyboard = ingame_keyboard_layout[GameSettings.gamename]

	scan(ingame_keyboard)
	
	local keyboard_type
	
	if ingame_keyboard.values.page == 0 then 
		keyboard_type = keyboard.other
	elseif ingame_keyboard.values.page == 1 then 
		keyboard_type = keyboard.maj
	else
		keyboard_type = keyboard.min
	end

	local x = ingame_keyboard.values.x + 1
	local y = ingame_keyboard.values.y + 1
	
			
	if 	ingame_keyboard.change_values.page == 1 then return end
			
	if ingame_keyboard.change_values.x == 1 or ingame_keyboard.change_values.y == 1 then

		if math.abs(ingame_keyboard.values.x - ingame_keyboard.old_values.x) > 1 then 

			if y ~= 3 then return end
		end
	

		
		
		

		
		key = keyboard_type[y][x]
		
		voice_string(key)
		
	end
	
	if (joy_state.values["A"] == true and joy_state.change_values["A"] == 1) or (joy_state.values["B"] == true and joy_state.change_values["B"] == 1) then
		local name = get_string_at_adress(ingame_keyboard.values.sNamingScreen_ptr+0x1800)
		voice_string(name .. key)
	end
end

function get_printer_text()
	misc.values.printer_string_address = memory.read_u32_le(0x202018c,"System Bus")
	--debug_print(misc.values.printer_string_address .. " sp " .. misc.values.text_speed .. " ")
	--debug_print("get_printer_text()")	
	--debug_print(string.char(10))	
	
	local printer = memory.read_u32_le(0x20201b0,"System Bus")
	if misc.values.printer_string_address+1 == printer or misc.values.printer_string_address == printer then
		--debug_print("toot")
	else 
		debug_print(misc.values.printer_string_address .. " " .. memory.read_u32_le(0x20201b0,"System Bus"))
		return
	end
	
	local data_string = get_data_string_at_adress(misc.values.printer_string_address)
	dialog.data_text_array,dialog.entries = split_data_string(data_string)
	dialog.cursor = 1
	dialog.ready = 1
end

old_printer_string = nil
function scan_printer_text()

	misc.values.printer_string_address = memory.read_u32_le(0x202018c,"System Bus")
	if not(misc.values.printer_string_address == 33697324 or misc.values.printer_string_address == 33693636) then return end --02021FC4
	local printer_string = get_string_at_adress(misc.values.printer_string_address)

	if old_printer_string ~= nil then
		if printer_string ~= old_printer_string then 
			--debug_print("new text")	
			--debug_print(string.char(10))
			
			local data_string = get_data_string_at_adress(misc.values.printer_string_address)
			dialog.data_text_array,dialog.entries = split_data_string(data_string)
			dialog.cursor = 1
			old_printer_string = printer_string 
			dialog.ready = 1
		end
	else
		debug_print("skip printer")	
		debug_print(string.char(10))	
		old_printer_string = printer_string 
	end
end

function read_window(n,entry)
	entry = entry or "all"
	if entry == "all" then
		for k, v in pairs(windows_print[n]) do
			voice_string(v.text .. " . ")
		end
	else
		voice_string(windows_print[entry].text)
	end
end

keys_state = input.get() 
--joy_state = joypad.get()
up_state = joy_state.values["Up"]
down_state = joy_state.values["Down"]
left_state = joy_state.values["Left"]
right_state = joy_state.values["Right"]
menu_mode = "game"
poi_menu_mode = 1
menu_cursor = 1
poi_menu_list = {}
voice_log = {}
voice_log_size = 0
voice_log_cursor = 1
function keyboard_input_logic()
	local ks = access_settings.keyboard_shortcuts

	local old_keys_state = shallowcopy(keys_state)
	keys_state = input.get() 
	
	local old_up_state = up_state
	up_state = joy_state.values["Up"]

	local old_down_state = down_state
	down_state = joy_state.values["Down"]

	local old_left_state = left_state
	left_state = joy_state.values["Left"]

	local old_right_state = right_state
	right_state = joy_state.values["Right"]	
	
	if keys_state[ks.voice_pokemon_party_extended_stats] == true and old_keys_state[ks.voice_pokemon_party_extended_stats] ~= true then
		voice_full_stats()
	end		
	
	local function voice_entry()
		if voice_log[voice_log_cursor] == nil then return end
		comm.socketServerSendBytes(voice_log[voice_log_cursor]) 
		voice_string("." .. lang[vl].entry .. voice_log_cursor,0)	
		debug_print("voice_log_cursor: " .. voice_log_cursor)	
		debug_print(string.char(10))
	end
	
	if keys_state[ks.voice_log] == true and old_keys_state[ks.voice_log] ~= true then
		if menu_mode ~= "log" then
			--debug_print(old_joy_state)
		
			client.pause()
			menu_mode = "log"
			--block_input = 1
			voice_log_cursor = voice_log_size
			voice_string(lang[vl].log_menu,0)
			voice_entry()
		else
			client.unpause()
			menu_mode = "game"
			--block_input = 0
			--voice_string(lang[vl].game_mode,0)
		end
	end		

	local function sort_event_objects()
		local list = {}
		local oev = object_events.values
		--debug_print(object_events.values)
		--debug_print(string.char(10))
		for i = 0, oev.count-1, 1 do --k, v in pairs(object_events.values) do
			
			if oev[i].invisible == 0 then
				--debug_print("*")
				local distance = math.sqrt((oev[i].pos_x-misc.values.x)^2+(oev[i].pos_y-misc.values.y)^2)
				--debug_print(",distance " .. distance)
				local entry = {
					x = oev[i].pos_x,
					y = oev[i].pos_y,
					distance = distance,
					name = lang[vl].event_objects_names[oev[i].graphicsId+1],
				}
				table.insert(list, entry)
			end
		end
		
		table.sort(list, function(a,b) return a.distance < b.distance end)
		
		--debug_print(list)	
		return list
	end
	
	local function sort_event_events()
		local list = {}
		
		for k, v in pairs(BgEvent) do
			local distance = math.sqrt((v.x-misc.values.x)^2+(v.y-misc.values.y)^2)
			local kind = ""
			if v.kind == 0 then kind = lang[vl].event
			elseif v.kind == 1 then kind = lang[vl].north_event
			elseif v.kind == 2 then kind = lang[vl].south_event
			elseif v.kind == 3 then kind = lang[vl].east_event
			elseif v.kind == 4 then kind = lang[vl].west_event
			elseif v.kind == 7 then kind = lang[vl].hidden_event
			else kind = lang[vl].secret_base_event end
			
			local entry = {
				x = v.x,
				y = v.y,
				distance = distance,
				kind = kind,
			}
			table.insert(list, entry)
		end
		
		table.sort(list, function(a,b) return a.distance < b.distance end)
		
		return list
	end

	local function sort_event_passages()
		local list = {}
		
		for k, v in pairs(warpEvent) do
			local distance = math.sqrt((v.x-misc.values.x)^2+(v.y-misc.values.y)^2)
			
			local entry = {
				x = v.x,
				y = v.y,
				zone = lang[vl].zone .. v.mapNum .. "." .. v.mapGroup,
				distance = distance,
			}
			table.insert(list, entry)
		end
		
		table.sort(list, function(a,b) return a.distance < b.distance end)
				
		return list
	end
	
	local function sort_connections()
		local list = {}
		
		for k, v in pairs(connections) do
			debug_print(" " .. connections_enum[v.direction] .. " ")
			if v.direction > 0 and v.direction < 7 then
				--debug_print(" " .. v.direction .. " ")
				
				--debug_print(lang[vl].connections[connections_enum[v.direction]] .. " ")
				local entry = {
					
					name = lang[vl].connections[connections_enum[v.direction]]
				}
				table.insert(list, entry)
			end
		end
		
		if #list == 0 then
			local entry = {
				name = " "
			}
			table.insert(list, entry)
		end 
		
		return list
	end

	local function poi_browse(direction)
		if direction == "down" then
			menu_cursor = menu_cursor - 1
			if menu_cursor < 1 then menu_cursor = #poi_menu_list end
		else
			menu_cursor = menu_cursor + 1
			if menu_cursor > #poi_menu_list then menu_cursor = 1 end
		end
		
		debug_print(menu_cursor)	
		--debug_print(poi_menu_list)	
		
		local e = poi_menu_list[menu_cursor]
		if e == nil then return end
		
		if poi_menu_mode == 1 then
			voice_string(e.x .. " " .. e.y .. " " .. e.name .. " ..." .. lang[vl].distance .. round(e.distance,0),0)
		
		elseif poi_menu_mode == 2 then
			voice_string(e.x .. " " .. e.y .. " " .. e.zone .. " ..." .. lang[vl].distance .. round(e.distance,0),0)
		elseif poi_menu_mode == 3 then
			voice_string(e.x .. " " .. e.y .. " " .. e.kind .. " ..." .. lang[vl].distance .. round(e.distance,0),0)
		else
			voice_string(e.name,0)
		end
	end

	if keys_state[ks.voice_map_entities] == true and old_keys_state[ks.voice_map_entities] ~= true then
		if menu_mode ~= "poi" then
			client.pause()
			
			menu_mode = "poi"		
			poi_menu_mode = 1
			
			poi_menu_list = sort_event_objects()
			
			voice_string(lang[vl].poi_menu,0)
			voice_string(lang[vl].entity_mode .. "...",0)
			menu_cursor = 2
			poi_browse("down")
		else
			client.unpause()
			menu_mode = "game"
		end
	end
	
	local function windows_browse(direction)
		--if #windows_print == 0 then return end
		
		local function browse_next(direction)
			if direction == "down" then
				menu_cursor = menu_cursor - 1
				if menu_cursor < 1 then menu_cursor = #windows_print end
			else
				menu_cursor = menu_cursor + 1
				if menu_cursor > #windows_print then menu_cursor = 1 end
			end
		--debug_print("menu_cursor: " .. menu_cursor)	
		--debug_print(string.char(10))
		end
		
		local i = 0
		browse_next(direction)
		while(#windows_print[menu_cursor-1] == 0) do
			
			browse_next(direction)
			i = i + 1
			if i == 31 then return end
		end
		
		voice_string(lang[vl].window .. menu_cursor)
		read_window(menu_cursor-1)
		
	end
	
	if keys_state[ks.read_windows_text] == true and old_keys_state[ks.read_windows_text] ~= true then
		if menu_mode ~= "windows" then
			client.pause()			
			menu_mode = "windows"	
			voice_string(lang[vl].read_windows,0)
			menu_cursor = 2
			windows_browse("down")
		else
			client.unpause()
			menu_mode = "game"
		end
	end
	
	local function poi_mode_change(direction)
		if direction == "left" then
			if poi_menu_mode == 1 then poi_menu_mode = 4 else poi_menu_mode = poi_menu_mode -1 end
		else
			if poi_menu_mode == 4 then poi_menu_mode = 1 else poi_menu_mode = poi_menu_mode +1 end
		end
		
		if poi_menu_mode == 1 then
			voice_string(lang[vl].entity_mode,0)
			poi_menu_list = sort_event_objects()
		elseif poi_menu_mode == 2 then
			voice_string(lang[vl].passage_mode,0)
			poi_menu_list = sort_event_passages()
		elseif poi_menu_mode == 3 then
			voice_string(lang[vl].event_mode,0)
			poi_menu_list = sort_event_events()
		else
			voice_string(lang[vl].connection_mode,0)
			poi_menu_list = sort_connections()
		end
		
		menu_cursor = 2
		poi_browse("down")
	end
		

	
	if keys_state[ks.show_contrast_view] == true and old_keys_state[ks.show_contrast_view] ~= true then
		if draw_the_map == 0 then 
			draw_the_map = 1
			map_x_radius = 7
			map_y_radius = 5
			
			update_map_header()
			map = scan_collision_map()
		elseif draw_the_map == 1 then 
			map_x_radius = 4
			map_y_radius = 3
			draw_the_map = 2

			update_map_header()
			map = scan_collision_map()
		elseif draw_the_map == 2 then
			draw_the_map = 0
			gui.clearGraphics()
		end
	end
	

	if menu_mode ~= "game" then
		if menu_mode == "poi" then
			if up_state == true and old_up_state == false then
				poi_browse("up")
			elseif down_state == true and old_down_state == false then
				poi_browse("down")
			elseif left_state == true and old_left_state == false then
				poi_mode_change("left")
			elseif right_state == true and old_right_state == false then
				poi_mode_change("right")
			end
		elseif menu_mode == "log" and voice_log_size > 0 then
			if up_state == true and old_up_state == false then
				--debug_print("x")	
				voice_log_cursor = voice_log_cursor + 1
				if voice_log_cursor > voice_log_size then voice_log_cursor = 1 end
				
				voice_entry()
			elseif down_state == true and old_down_state == false then
				voice_log_cursor = voice_log_cursor - 1
				if voice_log_cursor < 1 then voice_log_cursor = voice_log_size end
				
				voice_entry()
			end
		elseif menu_mode == "windows" then
			if up_state == true and old_up_state == false then
				windows_browse("up")
			elseif down_state == true and old_down_state == false then
				windows_browse("down")
			end
		end
	end
	
	if access_settings.debuging == 1 then 
		if keys_state["B"] == true and old_keys_state["B"] ~= true then
			--debug_print("test")
			--local test = {}
			--test = joypad.get()
			debug_print(joy_state.values)

			--gui.drawRectangle(0,0,50,50,0xFF000000,0xFF000000)

			--[[console.clear()
			for k,v in pairs(object_events.values) do
				if type(v) == "table" then
					debug_print("object_event: " .. k .. " active="..v.active.." ".. lang[vl].event_objects_names[v.graphicsId+1])
					debug_print(string.char(10))
				end
			end ]]
		end		
	end
end

full_stats_slot = 1
function voice_full_stats()
	local p = Program.getPokemonData({player = 1,slot = full_stats_slot})

	local hpiv = Utils.getbits(p["iv"], 0, 5)
	local atkiv = Utils.getbits(p["iv"], 5, 5)
	local defiv = Utils.getbits(p["iv"], 10, 5)
	local speiv = Utils.getbits(p["iv"], 15, 5)
	local spaiv = Utils.getbits(p["iv"], 20, 5)
	local spdiv = Utils.getbits(p["iv"], 25, 5)

	local hptype = math.floor(((hpiv%2 + 2*(atkiv%2) + 4*(defiv%2) + 8*(speiv%2) + 16*(spaiv%2) + 32*(spdiv%2))*15)/63)
	local hppower = math.floor(((Utils.getbits(hpiv,1,1) + 2*Utils.getbits(atkiv,1,1) + 4*Utils.getbits(defiv,1,1) + 8*Utils.getbits(speiv,1,1) + 16*Utils.getbits(spaiv,1,1) + 32*Utils.getbits(spdiv,1,1))*40)/63 + 30)
	
	--debug_print(p)
	--debug_print(full_stats_slot)
	
	local var = p["pokemonID"]
	--debug_print(var)
	--debug_print(string.char(10))
	
	if var > 439 then return end
	
	local str = 
		get_gender(p["personality"],p["pokemonID"]+1) .. " " ..
		"pokemon " .. full_stats_slot .. ". . ." ..
		lang.en.name[var + 1] .. ". . ." ..
		"HP " .. p["curHP"] .. " over " .. p["maxHP"] .. ". . ." ..
		"level " .. p["level"] .. ". . ." ..
		
		"items " .. PokemonData.item[p["heldItem"] + 1] .. ". . ." ..
		"pokerus " .. p["pokerus"] .. ". . ." .. 
		"nature " .. PokemonData.nature[p["nature"]+1] .. ". . ." ..
		"hidden power " .. PokemonData.type[hptype + 1] .. "  " .. hppower .. ". . ." ..
		
		
		"HP Stat " .. p["maxHP"] .. "  " .. hpiv .. "  " .. Utils.getbits(p["ev1"], 0, 8) .. ". . ." .. 
		"attack " .. p["atk"] .. "  " .. atkiv .. "  " .. Utils.getbits(p["ev1"], 8, 8) .. ". . ." .. 
		"defense " .. p["def"] .. "  " .. defiv .. "  " .. Utils.getbits(p["ev1"], 16, 8) .. ". . ." .. 
		"Sp. Atk " .. p["spa"] .. "  " .. spaiv .. "  " .. Utils.getbits(p["ev2"], 0, 8) .. ". . ." .. 
		"Sp. Def " .. p["spd"] .. "  " .. spdiv .. "  " .. Utils.getbits(p["ev2"], 8, 8) .. ". . ." .. 
		"speed " .. p["spe"] .. "  " .. speiv .. "  " .. Utils.getbits(p["ev1"], 24, 8)
		
	voice_string(str)
	full_stats_slot = full_stats_slot + 1 
	if full_stats_slot > 6 then full_stats_slot = 1 end
end

function debug_write_char_set_to_global_printer()
		debug_print("debug_write_char_set_to_global_printer() called")
		debug_print(string.char(10))

	local printer_string_address = memory.read_u32_le(0x202018c,"System Bus")
	
	local ptr = 0
	local counter = 1
	
	for i=0x0,0xF6,0x1 do
		memory.writebyte(printer_string_address+ptr,i,"System Bus")
		ptr = ptr + 1
		counter = counter + 1
		if counter == 32 then
			counter = 0
			memory.writebyte(printer_string_address+ptr,0xFA,"System Bus")
			ptr = ptr + 1
		end
		if i == 0x36 then i = 0x51 end
		if i == 0x5D then i = 0x68 end
		if i == 0x77 then i = 0x79 end
		if i == 0x6F then i = 0x77 end
		if i == 0x69 then i = 0x6F end
		if i == 0x7C then i = 0x84 end
		if i == 0x86 then i = 0xA0 end
	end
end

function loadstate_reinit()
	debug_print("loadstate_reinit")
	debug_print(string.char(10))

	--scan_values()

	step_timer = 0
	activate_temp_printer_char_event(true)
	step_outside = can_cycle()
	
	update_map_header()
	
	menu_mode = 0
	block_input = 0	
	
	set_dialog_speed()
end