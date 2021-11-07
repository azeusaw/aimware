-- local variables for API functions. any changes to the line below will be lost on re-generation
local callbacks_Register, client_Command, client_SetConVar, draw_Color, draw_CreateFont, draw_GetScreenSize, draw_SetFont, draw_TextShadow, entities_GetLocalPlayer, gui_Checkbox, gui_Combobox, gui_Keybox, gui_Reference, gui_SetValue, gui_Slider, input_IsButtonPressed = callbacks.Register, client.Command, client.SetConVar, draw.Color, draw.CreateFont, draw.GetScreenSize, draw.SetFont, draw.TextShadow, entities.GetLocalPlayer, gui.Checkbox, gui.Combobox, gui.Keybox, gui.Reference, gui.SetValue, gui.Slider, input.IsButtonPressed

-- References

local ref = gui_Reference( "MISC", "GENERAL", "Main" );
local ref2 = gui_Reference( "MISC", "GENERAL", "Bypass" );

-- Check Boxes
local wasd = gui_Checkbox( ref, "lua_fb", "Full Bright", false )
local saveefps = gui_Checkbox( ref, "vis_savefps", "Save FPS", false)
local cb = gui_Checkbox(ref, "rbot_revolver_autocock_ex", "R8 Adjustment", 0)
local cockspeed = gui_Slider(ref, "rbot_revolver_adjustment", "", 15, 1, 15)

local checkbox_buybot = gui_Checkbox( ref2, "Checkbox", "Auto Purchase",  0)
local check_indicator = gui_Checkbox(ref2, "manual", "Manual", 0)
local primary_guns = gui_Combobox( ref2, "primary", "Primary", "Off", "Scar-20 | G3SG1","AK47 | M4A1", "SSG-08", "AWP", "SG553 | AUG")
local secondary_guns = gui_Combobox( ref2, "Secondary", "Secondary",  "Off", "Dual Berettas", "Deagle | Revolver", "P250","TEC-9 | CZ75-Auto" )
local weapons_ = {"pistol", "revolver", "smg", "rifle", "shotgun", "scout", "autosniper", "sniper", "lmg"}
local hitboxes_ = {"head", "neck", "chest", "stomach", "pelvis", "arms", "legs"}
local primary_w = {"buy scar20", "buy m4a1", "buy ssg08", "buy awp", "buy aug"}
local secondary_w = {"buy elite", "buy deagle", "buy p250", "buy tec9"}

local gui_set = gui_SetValue
local gui_get = gui.GetValue
local left_key = 0
local back_key = 0
local right_key = 0
local up_key = 0
local manual_left = gui_Keybox(ref2, "manual_left", "Left", 0)
local manual_right = gui_Keybox(ref2, "manual_right", "Right", 0)
local manual_back = gui_Keybox(ref2, "manual_back", "Back", 0)
local manual_up = gui_Keybox(ref2, "manual_up", "Up", 0)

-- Full Bright | Save FPS
local function FBz()
	if wasd:GetValue() then
		 client_SetConVar( "mat_fullbright", 1, true );
		 client_SetConVar( "mat_postprocess_enable", 0, true );		
	else
		 client_SetConVar( "mat_fullbright", 0, true );
		 client_SetConVar( "mat_postprocess_enable", 0, true );
		end
	end

-- Save FPS
local function savee()
	if saveefps:GetValue() then
		gui_SetValue("vis_norender_teammates", 1)
		gui_SetValue("vis_norender_ragdolls", 1)
		gui_SetValue("vis_norender_weapons", 1)
		gui_SetValue("vis_farmodels", 0)
		gui_SetValue("esp_filter_team", 1)
		gui_SetValue("esp_visibility_team", 1)
		gui_SetValue("esp_enemy_glow", 0)
		gui_SetValue("esp_team_skeleton", 1)
		gui_SetValue("rbot_pistol_autowall", 2)
		gui_SetValue("rbot_revolver_autowall", 2)
		gui_SetValue("rbot_scout_autowall", 2)
		gui_SetValue("rbot_autosniper_autowall", 2)
		gui_SetValue("rbot_sniper_autowall", 2)
	else
		gui_SetValue("vis_norender_teammates", 0)
		gui_SetValue("vis_norender_ragdolls", 0)
		gui_SetValue("vis_norender_weapons", 0)
		gui_SetValue("vis_farmodels", 1)
		gui_SetValue("esp_filter_team", 0)
		gui_SetValue("esp_visibility_team", 0)
		gui_SetValue("esp_team_skeleton", 1)
		gui_SetValue("rbot_pistol_autowall", 1)
		gui_SetValue("rbot_revolver_autowall", 1)
		gui_SetValue("rbot_scout_autowall", 1)
		gui_SetValue("rbot_autosniper_autowall", 1)
		gui_SetValue("rbot_sniper_autowall", 1)
		gui_SetValue("rbot_positionadjustment", 6)
		gui_SetValue("rbot_revolver_autocock", 1)
	end

end
-- Auto Buy
local function Events( event )
	if event:GetName() == "round_start" and checkbox_buybot:GetValue() then
		local needtobuy = ""
		local primary = primary_guns:GetValue()
		local secondary = secondary_guns:GetValue()

		if primary > 0 then needtobuy = needtobuy..primary_w[primary]..";"
	end
	if secondary > 0 then needtobuy = needtobuy..secondary_w[secondary]..";buy taser;buy defuser;buy vest;buy vesthelm;buy hegrenade;buy molotov;buy smokegrenade;"
end


client_Command(needtobuy, false)
end
end

-- Rev Adjustment
local function on_create_move(cmd)
	local me = entities.GetLocalPlayer()
	if cb:GetValue() and me ~= nil and me:GetHealth() > 0 then
		if ( cmd:GetButtons() & ( 1 << 0 ) ) > 0 then
			return
		end

		local wep = me:GetPropEntity("m_hActiveWeapon")
		if wep then
			if wep:GetClass() == "CDEagle" and wep:GetWeaponID() == 64 then
				cmd:SetButtons(cmd:GetButtons() | ( 1 << 0 ) )

				local m_flPostponeFireReadyTime = wep:GetPropFloat("m_flPostponeFireReadyTime")
				if m_flPostponeFireReadyTime > 0 and m_flPostponeFireReadyTime - ((cockspeed:GetValue() + 4) / 100) < globals.CurTime() then
					cmd:SetButtons( cmd:GetButtons() & ~( 1 << 0 ) )

					if m_flPostponeFireReadyTime + globals.TickInterval() * 16 + (cockspeed:GetValue() / 100) > globals.CurTime() then
						cmd:SetButtons( cmd:GetButtons() | ( 1 << 11 ) )
					end
				end
			end
		end
	end
end

-- Anti Aim Adjustment
local text_font = draw_CreateFont("Arial Bold", 30, 700)
local arrow_font = draw_CreateFont("ActaSymbolsW95-Arrows", 25, 700)
local function main()
if manual_left:GetValue() ~= 0 then
if input_IsButtonPressed(manual_left:GetValue()) then
	left_key = left_key + 1
	back_key = 0
	right_key = 0
	up_key = 0
end
end

if manual_back:GetValue() ~= 0 then
if input_IsButtonPressed(manual_back:GetValue()) then
	back_key = back_key + 1
	left_key = 0
	right_key = 0
	up_key = 0
end
end

if manual_right:GetValue() ~= 0 then
if input_IsButtonPressed(manual_right:GetValue()) then
	right_key = right_key + 1
	left_key = 0
	back_key = 0
	up_key = 0
end
end

if manual_up:GetValue() ~= 0 then
if input_IsButtonPressed(manual_up:GetValue()) then
	up_key = up_key + 1
	left_key = 0
	back_key = 0
	right_key = 0
end
end
end

function CountCheck()
if (left_key == 1) then
back_key = 0
right_key = 0
up_key = 0
elseif (back_key == 1) then
left_key = 0
right_key = 0
up_key = 0
elseif (right_key == 1)  then
left_key = 0
back_key = 0
up_key = 0
elseif (up_key == 1) then
left_key = 0
back_key = 0
right_key = 0
elseif (left_key == 2) then
left_key = 0
back_key = 0
right_key = 0
up_key = 0
elseif (back_key == 2) then
left_key = 0
back_key = 0
right_key = 0
up_key = 0
elseif (right_key == 2) then
left_key = 0
back_key = 0
right_key = 0
up_key = 0
elseif (up_key == 2) then
left_key = 0
back_key = 0
right_key = 0
up_key = 0
end
end

function SetLeft()
gui_SetValue("rbot_antiaim_stand_real_add", -90);
gui_SetValue("rbot_antiaim_move_real_add", -90);
gui_SetValue("rbot_antiaim_stand_fake_add", 90);
gui_SetValue("rbot_antiaim_move_fake_add", 90);
gui_SetValue("rbot_antiaim_autodir", 0);
gui_SetValue("rbot_antiaim_at_targets", 0)
gui_SetValue("rbot_antiaim_edge_pitch_real", 0)
gui_SetValue("rbot_antiaim_edge_real", 0)
gui_SetValue("rbot_antiaim_edge_fake", 0)
gui_SetValue("rbot_antiaim_edge_lby", 0)
gui_SetValue("rbot_antiaim_stand_lby_delta", 120)
end

function SetBack()
gui_SetValue("rbot_antiaim_stand_real_add", 0);
gui_SetValue("rbot_antiaim_move_real_add", 0);
gui_SetValue("rbot_antiaim_stand_fake_add", 180);
gui_SetValue("rbot_antiaim_move_fake_add", 180);
gui_SetValue("rbot_antiaim_autodir", 0)
gui_SetValue("rbot_antiaim_at_targets", 0)
gui_SetValue("rbot_antiaim_edge_pitch_real", 0)
gui_SetValue("rbot_antiaim_edge_real", 0)
gui_SetValue("rbot_antiaim_edge_fake", 0)
gui_SetValue("rbot_antiaim_edge_lby", 0)
gui_SetValue("rbot_antiaim_stand_lby_delta", 0)

end

function SetRight()
gui_SetValue("rbot_antiaim_stand_real_add", 90);
gui_SetValue("rbot_antiaim_move_real_add", 90);
gui_SetValue("rbot_antiaim_stand_fake_add", -90);
gui_SetValue("rbot_antiaim_move_fake_add", -90);
gui_SetValue("rbot_antiaim_autodir", 0)
gui_SetValue("rbot_antiaim_at_targets", 0)
gui_SetValue("rbot_antiaim_edge_pitch_real", 0)
gui_SetValue("rbot_antiaim_edge_real", 0)
gui_SetValue("rbot_antiaim_edge_fake", 0)
gui_SetValue("rbot_antiaim_edge_lby", 0)
gui_SetValue("rbot_antiaim_stand_lby_delta", -120)
end

function SetUp()
gui_SetValue("rbot_antiaim_stand_real_add", 180);
gui_SetValue("rbot_antiaim_move_real_add", -180);
gui_SetValue("rbot_antiaim_autodir", 0)
gui_SetValue("rbot_antiaim_at_targets", 0)
gui_SetValue("rbot_antiaim_edge_pitch_real", 0)
gui_SetValue("rbot_antiaim_edge_real", 0)
gui_SetValue("rbot_antiaim_edge_fake", 0)
gui_SetValue("rbot_antiaim_edge_lby", 0)
gui_SetValue("rbot_antiaim_stand_lby_delta", 0)
end

function SetAuto()
gui_SetValue("rbot_antiaim_stand_real_add", 0);
gui_SetValue("rbot_antiaim_move_real_add", 0);
gui_SetValue("rbot_antiaim_stand_fake_add", 180);
gui_SetValue("rbot_antiaim_move_fake_add", 180);
gui_SetValue("rbot_antiaim_autodir", 1)
gui_SetValue("rbot_antiaim_at_targets", 1)
gui_SetValue("rbot_antiaim_edge_pitch_real", 1)
gui_SetValue("rbot_antiaim_edge_real", 1)
gui_SetValue("rbot_antiaim_edge_fake", 2)
gui_SetValue("rbot_antiaim_edge_lby", 0)
end

function draw_indicator()
if not entities_GetLocalPlayer() or not entities_GetLocalPlayer():IsAlive() then return end
local active = check_indicator:GetValue()
if active then
local w, h = draw_GetScreenSize()
if (left_key == 1) then
	SetLeft()
	draw_Color(78, 126, 242, 200)
	draw_SetFont(arrow_font)
	draw_TextShadow( w/2 - 90, h/2 - 16, "g")
elseif (back_key == 1) then
	SetBack()
	draw_Color(78, 126, 242, 200)
	draw_SetFont(arrow_font)
	draw_TextShadow( w/2 - 13, h/2 + 33, "f")
elseif (right_key == 1) then
	SetRight()
	draw_Color(78, 126, 242, 200)
	draw_SetFont(arrow_font)
	draw_TextShadow( w/2 + 60, h/2 - 16, "h")
elseif (up_key == 1) then
	SetUp()
	draw_Color(78, 126, 242, 200)
	draw_SetFont(arrow_font)
	draw_TextShadow( w/2 - 14, h/2 + -66, "e")
elseif ((left_key == 0) and (back_key == 0) and (right_key == 0) and (up_key == 0)) then
	SetAuto()
	draw_Color(78, 126, 242, 200)
	draw_SetFont(text_font)
	draw_TextShadow(15, h - 560, "auto")
end
end
end
-- Callbacks
callbacks_Register( "Draw", "wasd", FBz )
callbacks_Register( "Draw", "saveefps", savee )
callbacks_Register( "FireGameEvent", Events)
callbacks_Register("CreateMove", on_create_move)
callbacks_Register("Draw", "main", main)
callbacks_Register("Draw", "CountCheck", CountCheck)
callbacks_Register("Draw", "draw_indicator", draw_indicator)
