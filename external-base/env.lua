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
	['Common'] = true, ['Settings'] = true, ['PlayerList'] = true, ['InGameMenu'] = true,
	['PublishAssetPrompt'] = true, ['TopBar'] = true, ['InspectAndBuy'] = true,
	['VoiceChat'] = true, ['Chrome'] = true, ['PurchasePrompt'] = true, ['VR'] = true,
	['EmotesMenu'] = true, ['FTUX'] = true, ['TrustAndSafety'] = true
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
	ogetfenv(0)['getgenv'] = function()
		return ogetfenv(0)
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
			local args = {...}
			while true do
				args = { ocoroutine['yield'](closure(unpack(args))) }
			end
		end)

		return wrapped
	end

	getfenv(0)['gethui'] = function()
		return CoreGui
	end --

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
