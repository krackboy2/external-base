while (not game:IsLoaded()) do task['wait'](0.5) end

print('environment loading! - external ud (ultra detected)')

local CoreGui = game:GetService('CoreGui')
local RunService = game:GetService('RunService')
local RobloxGui = CoreGui:FindFirstChild('RobloxGui')
local Modules = RobloxGui:FindFirstChild('Modules')

local ScriptsHolder = Instance['new']('ObjectValue', CoreGui)
ScriptsHolder['Name'] = 'external_holder'

local ogetfenv = getfenv
local orequire = require
local oxpcall = xpcall
local otable = table
local odebug = debug
local ogame = game
local ocoroutine = coroutine
local ostring = string

local AllModules = {}
local ModulesIndex = 1
local Blacklist = {
	['Common'] = true,
	['Settings'] = true,
	['PlayerList'] = true,
	['InGameMenu'] = true,
	['PublishAssetPrompt'] = true,
	['TopBar'] = true,
	['InspectAndBuy'] = true,
	['VoiceChat'] = true,
	['Chrome'] = true,
	['PurchasePrompt'] = true,
	['VR'] = true,
	['EmotesMenu'] = true,
	['FTUX'] = true,
	['TrustAndSafety'] = true
}

for _, Script in ipairs(Modules:GetDescendants()) do
	if Script['ClassName'] == 'ModuleScript' then
		if not Blacklist[Script['Name']] then
			local BlacklistedParent = false
			for BlockedName in pairs(Blacklist) do
				if Script:IsDescendantOf(Modules:FindFirstChild(BlockedName)) then
					BlacklistedParent = true
					break
				end
			end
			if not BlacklistedParent then
				local Clone = Script:Clone()
				Clone['Name'] = 'Volt'
				table['insert'](AllModules, Clone)
			end
		end
	end
end

local function GetRandomModule()
	ModulesIndex = ModulesIndex + 1

	local FetchedModule = AllModules[ModulesIndex]

	if FetchedModule and FetchedModule['ClassName'] == 'ModuleScript' then
		return FetchedModule
	elseif ModulesIndex < #AllModules then
		return GetRandomModule()
	else
		return nil
	end
end

task['spawn'](function() -- Env
	local renv = {
		print = print,
		warn = warn,
		error = error,
		assert = assert,
		collectgarbage = collectgarbage,
		require = require,
		select = select,
		tonumber = tonumber,
		tostring = tostring,
		type = type,
		xpcall = xpcall,
		pairs = pairs,
		next = next,
		ipairs = ipairs,
		newproxy = newproxy,
		rawequal = rawequal,
		rawget = rawget,
		rawset = rawset,
		rawlen = rawlen,
		gcinfo = gcinfo,

		coroutine = {
			create = coroutine.create,
			resume = coroutine.resume,
			running = coroutine.running,
			status = coroutine.status,
			wrap = coroutine.wrap,
			yield = coroutine.yield,
		},

		bit32 = {
			arshift = bit32.arshift,
			band = bit32.band,
			bnot = bit32.bnot,
			bor = bit32.bor,
			btest = bit32.btest,
			extract = bit32.extract,
			lshift = bit32.lshift,
			replace = bit32.replace,
			rshift = bit32.rshift,
			xor = bit32.xor,
		},

		math = {
			abs = math.abs,
			acos = math.acos,
			asin = math.asin,
			atan = math.atan,
			atan2 = math.atan2,
			ceil = math.ceil,
			cos = math.cos,
			cosh = math.cosh,
			deg = math.deg,
			exp = math.exp,
			floor = math.floor,
			fmod = math.fmod,
			frexp = math.frexp,
			ldexp = math.ldexp,
			log = math.log,
			log10 = math.log10,
			max = math.max,
			min = math.min,
			modf = math.modf,
			pow = math.pow,
			rad = math.rad,
			random = math.random,
			randomseed = math.randomseed,
			sin = math.sin,
			sinh = math.sinh,
			sqrt = math.sqrt,
			tan = math.tan,
			tanh = math.tanh
		},

		string = {
			byte = string.byte,
			char = string.char,
			find = string.find,
			format = string.format,
			gmatch = string.gmatch,
			gsub = string.gsub,
			len = string.len,
			lower = string.lower,
			match = string.match,
			pack = string.pack,
			packsize = string.packsize,
			rep = string.rep,
			reverse = string.reverse,
			sub = string.sub,
			unpack = string.unpack,
			upper = string.upper,
		},

		table = {
			concat = table.concat,
			insert = table.insert,
			pack = table.pack,
			remove = table.remove,
			sort = table.sort,
			unpack = table.unpack,
		},

		utf8 = {
			char = utf8.char,
			charpattern = utf8.charpattern,
			codepoint = utf8.codepoint,
			codes = utf8.codes,
			len = utf8.len,
			nfdnormalize = utf8.nfdnormalize,
			nfcnormalize = utf8.nfcnormalize,
		},

		os = {
			clock = os.clock, date = os.date, difftime = os.difftime, time = os.time,
		},

		delay = delay,
		elapsedTime = elapsedTime,
		spawn = spawn,
		tick = tick,
		time = time,
		typeof = typeof,
		UserSettings = UserSettings,
		version = version,
		wait = wait,
		_VERSION = _VERSION,

		task = {
			defer = task.defer, delay = task.delay, spawn = task.spawn, wait = task.wait,
		},

		debug = {
			traceback = debug.traceback, profilebegin = debug.profilebegin, profileend = debug.profileend,
		},

		game = ogame,
		workspace = ogame.Workspace,
		Game = ogame,
		Workspace = ogame.Workspace,

		getmetatable = getmetatable,
		setmetatable = setmetatable
	}
	table.freeze(renv)

	ogetfenv(0)['getgenv'] = function()
		return ogetfenv(0)
	end

	ogetfenv(0)['getrenv'] = function()
		return renv
	end

	ogetfenv(0)['getsenv'] = function(script_instance)
		local env = getfenv(debug.info(2, 'f'))
		return setmetatable({
			script = script_instance,
		}, {
			__index = function(self, index)
				return env[index] or rawget(self, index)
			end,
			__newindex = function(self, index, value)
				xpcall(function()
					env[index] = value
				end, function()
					rawset(self, index, value)
				end)
			end,
		})
	end

	ogetfenv(0)['gettenv'] = function()
		return ogetfenv(0)
	end

	ogetfenv(0)['getmenv'] = function(mod)
		local mod_env = nil

		for I, V in pairs(getreg()) do
			if typeof(V) == "thread" then
				if gettenv(V).script == mod then
					mod_env = gettenv(V)
					break
				end
			end
		end

		return mod_env
	end

	ogetfenv(0)['isreadonly'] = function(tble)
		return otable['isfrozen'](tble)
	end

	ogetfenv(0)['iscclosure'] = function(closure)
		return odebug['info'](closure, 's') == '[C]'
	end

	ogetfenv(0)['islclosure'] = function(closure)
		return not iscclosure(closure)
	end

	ogetfenv(0)['isexecutorclosure'] = function(closure)
		if iscclosure(closure) then
			return odebug['info'](closure, 'n') == ('' or nil)
		end

		return true
	end

	ogetfenv(0)['isourclosure'] = ogetfenv(0)['isexecutorclosure']
	ogetfenv(0)['is_our_closure'] = ogetfenv(0)['isexecutorclosure']
	ogetfenv(0)['checkclosure'] = ogetfenv(0)['isexecutorclosure']
	ogetfenv(0)['is_synapse_closure'] = ogetfenv(0)['isexecutorclosure']
	ogetfenv(0)['is_protosmasher_closure'] = ogetfenv(0)['isexecutorclosure']

	ogetfenv(0)['getinstances'] = function()
		local instances = {}

		for _, instance in ipairs(ogame:GetDescendants()) do
			otable['insert'](instances, instance)
		end

		return instances
	end

	ogetfenv(0)['getscripts'] = function()
		local scripts = {}

		for _, instance in ipairs(getinstances()) do
			if instance:IsA('LocalScript') or instance:IsA('ModuleScript') then
				otable['insert'](scripts, instance)
			end
		end

		return scripts
	end


	getfenv(0)['newcclosure'] = function(closure)
		if iscclosure(closure) then
			return closure
		end

		local wrapped = ocoroutine['wrap'](function(...)
			local args = { ... }
			while true do
				args = { ocoroutine['yield'](closure(unpack(args))) }
			end
		end)

		return wrapped
	end

	getfenv(0)['gethui'] = function()
		return CoreGui
	end --

	local windowActive = true
	ogame:GetService("UserInputService").WindowFocused:Connect(function()
		windowActive = true
	end)
	ogame:GetService("UserInputService").WindowFocusReleased:Connect(function()
		windowActive = false
	end)

	getfenv(0)['isrbxactive'] = function()
		return windowActive
	end

	getfenv(0)['iswindowactive'] = getfenv(0)['isrbxactive']
	getfenv(0)['isgameactive'] = getfenv(0)['isrbxactive']

	getfenv(0)['isscriptable'] = function(object, property)
		local dummy = function(result)
			return result
		end

		local success, result = oxpcall(object['GetPropertyChangedSignal'], dummy, object, property)
		if not success then
			success = not ostring['find'](result, 'scriptable property', nil, true)
		end
		return success
	end

	getfenv(0)['identifyexecutor'] = function()
		return "Volt", "1.0"
	end

	getfenv(0)['getexecutorname'] = function()
		return "Volt"
	end

	getfenv(0)['getexecutorversion'] = function()
		return "1.0"
	end

	getfenv(0)['getthreadidentity'] = function()
		return 3
	end

	getfenv(0)['getidentity'] = getthreadidentity()
	getfenv(0)['getthreadcontext'] = getthreadidentity()

	getfenv(0)['setthreadidentity'] = function()
		return 3, "Can't be changed!"
	end

	getfenv(0)['setidentity'] = setthreadidentity()
	getfenv(0)['setthreadcontext'] = setthreadidentity()

	local metatables = {}

	local rsetmetatable = setmetatable

	getfenv(0)['setmetatable'] = function(tabl, meta)
		local object = rsetmetatable(tabl, meta)
		metatables[object] = meta
		return object
	end

	getfenv(0)['getrawmetatable'] = function(object)
		return metatables[object]
	end

	getfenv(0)['setrawmetatable'] = function(taaable, newmt)
		local currentmt = getrawmetatable(taaable)
		if not currentmt then
			currentmt = getmetatable(taaable)
		end
		table.foreach(newmt, function(key, value)
			currentmt[key] = value
		end)
		return true
	end

	getfenv(0)['getconnections'] = function()
		return { {
			Enabled = true,
			ForeignState = false,
			LuaConnection = true,
			Function = function() end,
			Thread = task.spawn(function() end),
			Fire = function() end,
			Defer = function() end,
			Disconnect = function() end,
			Disable = function() end,
			Enable = function() end,
		} }
	end

	getfenv(0)['fireclickdetector'] = function(part)
		assert(typeof(part) == "Instance", "#1 argument in fireclickdetector must be an Instance", 2)

		local clickDetector = part:FindFirstChild("ClickDetector") or part

		assert(clickDetector ~= nil, "Couldn't fetch click detector on the part provided", 2)

		local previousParent = clickDetector.Parent

		local newPart = Instance.new("Part", ogame.Workspace)
		do
			newPart.Transparency = 1
			newPart.Size = Vector3.new(30, 30, 30)
			newPart.Anchored = true
			newPart.CanCollide = false
			delay(15, function()
				if newPart:IsDescendantOf(game) then
					newPart:Destroy()
				end
			end)
			clickDetector.Parent = newPart
			clickDetector.MaxActivationDistance = math.huge
		end

		local vUser = game:FindService("VirtualUser") or game:GetService("VirtualUser")

		local connection = RunService.Heartbeat:Connect(function()
			local camera = ogame.Workspace.CurrentCamera or ogame.Workspace.Camera
			newPart.CFrame = camera.CFrame * CFrame.new(0, 0, -20) *
				CFrame.new(camera.CFrame.LookVector.X, camera.CFrame.LookVector.Y, camera.CFrame.LookVector.Z)
			vUser:ClickButton1(Vector2.new(20, 20), camera.CFrame)
		end)

		clickDetector.MouseClick:Once(function()
			connection:Disconnect()
			clickDetector.Parent = previousParent
			newPart:Destroy()
		end)
	end

	local metatable = setmetatable({ game, ["GC"] = {} }, { ["__mode"] = "v" })

	getfenv(0)['getgc'] = function(s)
		for _, v in game:GetDescendants() do
			table.insert(metatable, v)
		end
		repeat task.wait() until not metatable["GC"]
		local non_gc = {}
		for _, c in metatable do
			table.insert(non_gc, c)
		end
		return non_gc
	end

	local nilinstances, cache = { Instance.new("Part") }, { cached = {} }

	getfenv(0)['getnilinstances'] = function()
		return nilinstances
	end

	getfenv(0)['getloadedmodules'] = function()
		local returnable = {}
		for _, v in getinstances() do
			if v:IsA("ModuleScript") then
				returnable[#returnable + 1] = v
			end
		end
		return returnable
	end

	getfenv(0)['getrunningscripts'] = function()
		return getscripts()
	end

	local ssbs = {}

	getfenv(0)['setscriptable'] = function(object, property, bool)
		local scriptable = isscriptable(object, property)
		local s = pcall(function()
			ssbs[object][property] = bool
		end)
		if not s then
			ssbs[object] = { [property] = bool }
		end
		return scriptable
	end

	getfenv(0)['filtergc'] = function(...)
        local args = { ... }
        local type_or_callback = args[1]
 
        -- Handle callback-style API: filtergc(function(obj) return condition end)
        if typeof(type_or_callback) == "function" then
            local callback = type_or_callback
            local matches = {}
 
            for i, v in getgc(true) do
                local success, passed = pcall(callback, v)
                if success and passed then
                    table.insert(matches, v)
                end
            end
 
            return matches
        end
 
        -- Handle structured API
        local filterType = type_or_callback
        local filterOptions = args[2] or {}
        local returnOne = args[3]
        local matches = {}
 
        if filterType == "table" then
            for i, v in getgc(true) do
                if typeof(v) ~= "table" then
                    continue
                end
 
                local passed = true
 
                -- Check Keys filter
                if filterOptions.Keys and typeof(filterOptions.Keys) == "table" and passed then
                    for _, key in filterOptions.Keys do
                        if rawget(v, key) == nil then
                            passed = false
                            break
                        end
                    end
                end
 
                -- Check Values filter
                if filterOptions.Values and typeof(filterOptions.Values) == "table" and passed then
                    local tableVals = {}
                    for _, value in next, v do
                        table.insert(tableVals, value)
                    end
                    for _, value in filterOptions.Values do
                        if not table.find(tableVals, value) then
                            passed = false
                            break
                        end
                    end
                end
 
                -- Check KeyValuePairs filter
                if filterOptions.KeyValuePairs and typeof(filterOptions.KeyValuePairs) == "table" and passed then
                    for key, value in filterOptions.KeyValuePairs do
                        if rawget(v, key) ~= value then
                            passed = false
                            break
                        end
                    end
                end
 
                -- Check Metatable filter
                if filterOptions.Metatable and passed then
                    local success, mt = pcall(getrawmetatable, v)
                    if success then
                        passed = filterOptions.Metatable == mt
                    else
                        passed = false
                    end
                end
 
                if passed then
                    if returnOne then
                        return v
                    else
                        table.insert(matches, v)
                    end
                end
            end
        elseif filterType == "function" then
            -- Default IgnoreExecutor to true if not specified
            if filterOptions.IgnoreExecutor == nil then
                filterOptions.IgnoreExecutor = true
            end
 
            for i, v in getgc(false) do
                if typeof(v) ~= "function" then
                    continue
                end
 
                local passed = true
                local isCClosure = pcall(function() return iscclosure(v) end) and iscclosure(v) or false
 
                -- Check Name filter
                if filterOptions.Name and passed then
                    local success, funcName = pcall(function()
                        local info = debug.info(v, "n")
                        return info
                    end)
                    if success and funcName then
                        passed = funcName == filterOptions.Name
                    else
                        -- Try alternative method for function names
                        local success2, funcString = pcall(function()
                            return tostring(v)
                        end)
                        if success2 and funcString then
                            passed = string.find(funcString, filterOptions.Name) ~= nil
                        else
                            passed = false
                        end
                    end
                end
 
                -- Check IgnoreExecutor filter
                if filterOptions.IgnoreExecutor == true and passed then
                    local success, isExec = pcall(function() return isexecutorclosure(v) end)
                    if success then
                        passed = not isExec
                    else
                        passed = true -- If can't check, assume it's not executor
                    end
                end
 
                -- Skip C closure specific filters for C functions
                if isCClosure and (filterOptions.Hash or filterOptions.Constants or filterOptions.Upvalues) then
                    passed = false
                end
 
                -- Handle non-C closure filters
                if not isCClosure and passed then
                    -- Check Hash filter
                    if filterOptions.Hash and passed then
                        local success, hash = pcall(function()
                            return getfunctionhash and getfunctionhash(v) or nil
                        end)
                        if success and hash then
                            passed = hash == filterOptions.Hash
                        else
                            passed = false
                        end
                    end
 
                    -- Check Constants filter
                    if filterOptions.Constants and typeof(filterOptions.Constants) == "table" and passed then
                        local success, constants = pcall(function()
                            return debug.getconstants and debug.getconstants(v) or {}
                        end)
                        if success and constants then
                            local funcConsts = {}
                            for idx, constant in constants do
                                if constant ~= nil then
                                    table.insert(funcConsts, constant)
                                end
                            end
                            for _, constant in filterOptions.Constants do
                                if not table.find(funcConsts, constant) then
                                    passed = false
                                    break
                                end
                            end
                        else
                            passed = false
                        end
                    end
 
                    if filterOptions.Upvalues and typeof(filterOptions.Upvalues) == "table" and passed then
                        local success, upvalues = pcall(function()
                            return debug.getupvalues and debug.getupvalues(v) or {}
                        end)
                        if success and upvalues then
                            local funcUpvals = {}
                            for idx, upval in upvalues do
                                if upval ~= nil then
                                    table.insert(funcUpvals, upval)
                                end
                            end
                            for _, upval in filterOptions.Upvalues do
                                if not table.find(funcUpvals, upval) then
                                    passed = false
                                    break
                                end
                            end
                        else
                            passed = false
                        end
                    end
                end
 
                if passed then
                    if returnOne then
                        return v
                    else
                        table.insert(matches, v)
                    end
                end
            end
        else
            error("Expected type 'function' or 'table', got '" .. tostring(filterType) .. "'")
        end
 
        return returnOne and nil or matches
    end

	local fpscap = math.huge
	getfenv(0)['setfpscap'] = function(cap)
		cap = tonumber(cap)
		assert(type(cap) == "number", "#1 argument in setfps cap must be a number", 2)
		if cap < 1 then cap = math.huge end
		fpscap = cap
	end

	local clock = tick()
	RunService.RenderStepped:Connect(function()
		while clock + 1 / fpscap > tick() do end
		clock = tick()

		task.wait()
	end)
	getfenv(0)['getfpscap'] = function()
		return ogame.Workspace:GetRealPhysicsFPS()
	end
end)

task['wait'](0.50)
task['spawn'](function()
	ScriptsHolder['Value'] = GetRandomModule()

	RunService['RenderStepped']:Connect(function()
		local CurrentScript = ScriptsHolder['Value']

		if not CurrentScript then
			ScriptsHolder['Value'] = GetRandomModule()
			CurrentScript = ScriptsHolder['Value']
		end

		local Success, Returned = pcall(function()
			return orequire(CurrentScript)
		end)

		if Success then
			if type(Returned) == 'table' and Returned['external'] and typeof(Returned['external']) == 'function' then
				if ModulesIndex == #AllModules then
					ModulesIndex = 1
				end

				CurrentScript:Destroy()
				ScriptsHolder['Value'] = GetRandomModule()
				CurrentScript = ScriptsHolder['Value']

				task['spawn'](setfenv(Returned['external'], ogetfenv()))
			end
		end
	end)
end)

task['wait'](0.50)
task['spawn'](function()
	ScriptsHolder['Value'] = GetRandomModule()

	RunService['RenderStepped']:Connect(function()
		local CurrentScript = ScriptsHolder['Value']

		if not CurrentScript then
			ScriptsHolder['Value'] = GetRandomModule()
			CurrentScript = ScriptsHolder['Value']
		end

		local Success, Returned = pcall(function()
			return orequire(CurrentScript)
		end)

		if Success then
			if type(Returned) == 'table' and Returned['external'] and typeof(Returned['external']) == 'function' then
				if ModulesIndex == #AllModules then
					ModulesIndex = 1
				end

				CurrentScript:Destroy()
				ScriptsHolder['Value'] = GetRandomModule()
				CurrentScript = ScriptsHolder['Value']

				task['spawn'](setfenv(Returned['external'], ogetfenv()))
			end
		end
	end)
end)
