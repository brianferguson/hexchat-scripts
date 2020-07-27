--[[
        Name: open-tabs.lua
      Author: Brian Ferguson
     Website: https://github.com/brianferguson/hexchat-scripts/
        Date: 2020.07.27
     Version: 1.0
     License: CC BY-NC-SA 4.0  https://creativecommons.org/licenses/by-nc-sa/4.0/
 Description: This opens certain tabs when connecting to a server and joining a channel
    Platform: Hexchat 2.14.3 
     Network: freenode#rainmeter (brian)
]]

--[[
 Note: I prefer to have my irc tabs to be in a certain order, but Hexchat does not allow
  re-ordering of tabs once opened (that I know of). So, I use the Hexchat option
  |Settings > Preferences > Channel switcher > Placement of notices > "In a extra tab"| to
  forward server and user notices to 2 separates tabs "(snotices)" and "(notices)" respectively.
  I then like to have a private window open before the main channel opens.
  To achieve this, this script opens tabs on connection to the server and on joining a channel.
  For me, the tab order is: freenode, (snotices), (notices), jsmorley, #rainmeter
]]

local script_name = "open-tabs.lua"
local script_version = "1.0"
local script_description = "Automatically opens tabs once logged on"

hexchat.register(script_name, script_version, script_description)

local function on_connect_opentab(word, eol)

	local nick = hexchat.get_info("nick")
	local tabs = { ["(notices)"] = "notice ".. nick .." Opened (notices) tab." }

	for tab, cmd in pairs(tabs) do
		local server = hexchat.get_info("server")
		if server then
			local context = hexchat.find_context(server, tab)
			if context == nil then
				hexchat.command(cmd)
			end
		end
	end

	return hexchat.EAT_NONE

end

local function on_join_opentab(word, eol)

	local tabs = { "jsmorley" }

	for _, name in ipairs(tabs) do
		local server = hexchat.get_info("server")
		if server then
			local context = hexchat.find_context(server, name)
			if context == nil then
				hexchat.command("query -nofocus " .. name)
			end
		end
	end

	return hexchat.EAT_NONE
	
end

-- https://irc.com/foundation/docs/refs/numerics/376
hexchat.hook_server("376", on_connect_opentab, hexchat.PRI_HIGHEST)
hexchat.hook_server("JOIN", on_join_opentab, hexchat.PRI_HIGHEST)

hexchat.print("* " .. script_name .. ":" .. script_version .. " is loaded.")
