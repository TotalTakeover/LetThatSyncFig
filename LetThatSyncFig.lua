-- LetThatSyncFig
-- By:
--   _________  ________  _________  ________  ___
--  |\___   ___\\   __  \|\___   ___\\   __  \|\  \
--  \|___ \  \_\ \  \|\  \|___ \  \_\ \  \|\  \ \  \
--       \ \  \ \ \  \\\  \   \ \  \ \ \   __  \ \  \
--        \ \  \ \ \  \\\  \   \ \  \ \ \  \ \  \ \  \____
--         \ \__\ \ \_______\   \ \__\ \ \__\ \__\ \_______\
--          \|__|  \|_______|    \|__|  \|__|\|__|\|_______|
--
-- Special thanks: Grandpa Scout & Pool
-- Version: 1.0.3

-- Config setup
config:name("NameHere")

-- Create table
local sync = {}

-- Determine which value should be applied, checking for nil before applying
function sync.pick(...)
	
	-- Determine result
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		if v ~= nil then
			return v
		end
	end
	
end

-- Adds variable to table under new index, and provides index for access later
function sync.add(...)
	
	-- New index number
	local n = #sync + 1
	
	-- Create synced variable
	sync[n] = sync.pick(...)
	
	-- Return index number
	return n
	
end

-- Sync variables via ping
function pings.syncVars(...)
	
	for i, v in ipairs({...}) do
		sync[i] = v
	end
	
end

-- Host only instructions
if not host:isHost() then return sync end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncVars(table.unpack(sync))
	end
	
end

-- Return table
return sync