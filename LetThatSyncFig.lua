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
-- Special thanks: Grandpa Scout, Pool & Mangodev
-- Version: 1.1.2

-- Create API
local syncAPI = {}

-- Syncs table
local syncs = {}

-- Interal sync data
local syncInternal = {}

-- Meta table setup
local syncMeta = {
	__index = syncInternal,
	__type = "SyncObject"
}

-- Create a sync object
function syncAPI.new(id, ...)
	
	-- Check if the id is a string
	if type(id) ~= "string" then error("\n\n§6ID must be a string!\n§c", 2) end
	
	-- Check if the id already exists
	for k, v in ipairs(syncs) do
		if v.id == id then
			error("\n\n§6ID must be unique!\n§c", 2)
		end
	end
	
	-- Determine which value should be applied, checking for nil before returning
	local result
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		if v ~= nil then
			result = v
		end
	end
	
	-- Create object
	local obj = setmetatable(
		{
			prev = result,
			curr = result,
			id = id
		},
		syncMeta
	)
	
	-- Add object to table
	table.insert(syncs, obj)
	
	-- Return object
	return obj
	
end

-- Sorts table deterministically
function events.ENTITY_INIT()
	
	-- Sorts table alphabetically
	table.sort(syncs, function(a, b)
		return a.id < b.id
	end)
	
	-- Grants each object a numerical id to be used when pinging
	for k, v in ipairs(syncs) do
		v.nid = k
	end
	
end

-- Updates sync values
local function updateValues(obj, v)
	
	-- Update current value
	obj.curr = v
	
	-- If value changed, preform the update
	if obj.curr ~= obj.prev then
		
		-- Preform optional function if it exists
		if obj.fn then obj.fn() end
		
		-- Update config if it exists
		if obj.cfg ~= nil then config:save(obj.cfg, v) end
		
		-- Update previous value
		obj.prev = v
		
	end
	
end

-- Sync variable via ping
function pings.sendSyncUpdate(k, v)
	
	-- Find sync object
	local obj = syncs[k]
	
	-- Update values
	updateValues(obj, v)
	
end

-- Sync ALL variables via ping
function pings.sendSyncUpdateAll(...)
	
	for k, v in ipairs({...}) do
		
		-- Find sync object
		local obj = syncs[k]
		
		-- Update values
		updateValues(obj, v)
		
	end
	
end

-- Update a sync object
function syncInternal:update(v)
	
	-- Check if change occured, and send ping
	-- Prevents spam caused by user
	if v ~= self.prev then
		
		pings.sendSyncUpdate(self.nid, v)
		
	end
	
	-- Return object
	return self
	
end

-- Apply a function
function syncInternal:applyFunc(func)
	
	-- Checks if function is actually a function
	if type(func) ~= "function" then error("\n\n§6Must be a function!\n§c", 2) end
	
	-- Apply function to sync
	self.fn = func
	
	-- Return object
	return self
	
end

-- Apply a config key
function syncInternal:config(name)
	
	-- Kill function if not host
	if not host:isHost() then return self end
	
	-- Apply config to sync
	self.cfg = name
	
	-- Get config value
	local cfgValue = config:load(name)
	
	-- Update object if config has value
	if cfgValue ~= nil then
		updateValues(self, cfgValue)
	end
	
	-- Return object
	return self
	
end

-- Host only instructions
if not host:isHost() then return syncAPI end

-- Sync on tick
events.TICK:register(function()
	
	-- Sync variables
	if world.getTime() % 200 == 0 then
		
		-- Gather values
		local syncTables = {} 
		for k, v in ipairs(syncs) do
			syncTables[k] = v.curr
		end
		
		-- Send values
		pings.sendSyncUpdateAll(table.unpack(syncTables))
		
	end
	
end, "tickSync")

-- Return API
return syncAPI