--!strict

-- StyLua Roblox
-- Version 1.3.0

local AnalyticsService = game:GetService("AnalyticsService")
local HttpService = game:GetService("HttpService")
local ScriptEditorService = game:GetService("ScriptEditorService")
local StudioService = game:GetService("StudioService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")

assert(plugin, "This code must run inside of a plugin")

if game:GetService("RunService"):IsRunning() then
	return
end

local ConfigInfo = {
	column_width = {
		DefaultValue = 120,
		Options = "<number>",
	},
	line_endings = {
		DefaultValue = "Unix",
		Options = "Unix,Windows",
	},
	indent_type = {
		DefaultValue = "Tabs",
		Options = "Tabs,Spaces",
	},
	indent_width = {
		DefaultValue = 4,
		Options = "<number>",
	},
	quote_style = {
		DefaultValue = "AutoPreferDouble",
		Options = "AutoPreferDouble, AutoPreferSingle, ForceDouble, ForceSingle",
	},
	call_parentheses = {
		DefaultValue = "Always",
		Options = "Always, NoSingleString, NoSingleTable, None, Input",
	},
	collapse_simple_statement = {
		DefaultValue = "Never",
		Options = "Never, FunctionOnly, ConditionalOnly, Always",
	},
	space_after_function_names = {
		DefaultValue = "Never",
		Options = "Never, Definitions, Calls, Always",
	},
	sort_requires = {
		DefaultValue = false,
		Options = "<boolean>",
	},
}

function wrap(Value)
	if type(Value) == "string" then
		return '"' .. Value .. '"'
	else
		return tostring(Value)
	end
end

function generateSettings()
	local Settings = plugin:GetSetting("StyLuaSettings") or {}
	local Output = "-- StyLua Configuration\nreturn {\n\n"
	for CName, CValue in Settings do
		if ConfigInfo[CName] then
			Output = Output
				.. "\t"
				.. CName
				.. " = "
				.. wrap(CValue)
				.. ",	--| "
				.. ConfigInfo[CName].Options
				.. " | "
				.. "\n"
		end
	end

	Output = Output .. "\n}"

	return Output
end

function validateSettings(Module)
	local result: any, _: any = loadstring(Module.Source)
	if result == nil then
		return false
	end
	local Settings
	local ok = pcall(function()
		setfenv(result, {})
		Settings = result()
	end)
	if not ok or type(Settings) ~= "table" then
		return false
	end
	-- type and option checks
	for Cname, CValue in Settings do
		if not ConfigInfo[Cname] then
			return false
		end
		if type(CValue) ~= type(ConfigInfo[Cname].DefaultValue) then
			return false
		end
		if type(ConfigInfo[Cname].DefaultValue) == "string" then
			local Options = string.split(ConfigInfo[Cname].Options:gsub("%s+", ""), ",")
			if not table.find(Options, CValue) then
				return false
			end
		end
	end
	return Settings
end

local Connection: RBXScriptConnection? = nil
function applySettings(Module: ModuleScript)
	if Connection then
		Connection:Disconnect()
		Connection = nil
	end
	Connection = ScriptEditorService.TextDocumentDidChange:Connect(function(document)
		if (document:GetScript() :: any) ~= Module then
			return
		end
		local NewSetting = validateSettings(Module)
		if NewSetting then
			plugin:SetSetting("StyLuaSettings", NewSetting)
		end
	end)
end

function openSettings()
	local Module = AnalyticsService:FindFirstChild("StyLua_Settings") :: ModuleScript?

	if not Module then
		local newModule = Instance.new("ModuleScript")
		newModule.Name = "StyLua_Settings"
		newModule.Archivable = false
		newModule.Parent = AnalyticsService
		Module = newModule
	end
	assert(Module, "Failed to create StyLua_Settings ModuleScript")

	if not plugin:GetSetting("StyLuaSettings") then
		local ConfigTable = {}
		for ConfigName, ConfigData in pairs(ConfigInfo) do
			ConfigTable[ConfigName] = ConfigData.DefaultValue
		end
		plugin:SetSetting("StyLuaSettings", ConfigTable)
	end

	ScriptEditorService:UpdateSourceAsync(Module, function()
		return generateSettings()
	end)
	applySettings(Module)
	ScriptEditorService:OpenScriptDocumentAsync(Module)
end

function fetchSettings()
	local Config = {}

	-- Place Only Settings
	local PlaceSetting = ServerStorage:FindFirstChild("StyLua")
	if PlaceSetting and PlaceSetting:IsA("LuaSourceContainer") then
		local PlaceConfig = validateSettings(PlaceSetting)
		if PlaceConfig then
			for setting, value in PlaceConfig :: any do
				if ConfigInfo[setting] and value ~= ConfigInfo[setting].DefaultValue then
					Config[setting] = value
				end
			end
			return Config
		end
	end

	--Global Settings
	local globalSettings = plugin:GetSetting("StyLuaSettings")
	if not globalSettings then
		local configTable = {}
		for configName, configData in pairs(ConfigInfo) do
			configTable[configName] = configData.DefaultValue
		end
		plugin:SetSetting("StyLuaSettings", configTable)
		globalSettings = configTable
	end

	for setting, value in globalSettings do
		if ConfigInfo[setting] and value ~= ConfigInfo[setting].DefaultValue then
			Config[setting] = value
		end
	end
	return Config
end

local function getScriptSource(scriptObj: LuaSourceContainer): string
	local doc = ScriptEditorService:FindScriptDocument(scriptObj)
	if doc then
		return ScriptEditorService:GetEditorSource(scriptObj)
	end
	return (scriptObj :: any).Source
end

local function updateScriptSource(scriptObj: LuaSourceContainer, newSource: string)
	local doc = ScriptEditorService:FindScriptDocument(scriptObj)
	if doc then
		ScriptEditorService:UpdateSourceAsync(scriptObj, function()
			return newSource
		end)
	else
		(scriptObj :: any).Source = newSource
	end
end

local FormatAction =
	plugin:CreatePluginAction("StyLua Format", "Format", "Formats the code", "rbxassetid://15177733701", true)

function formatter(script: LuaSourceContainer)
	local currentSource = getScriptSource(script)
	local ConfigJSON = fetchSettings()
	local encodedConfig = HttpService:UrlEncode(HttpService:JSONEncode(ConfigJSON))

	local success, result = pcall(HttpService.RequestAsync, HttpService, {
		Method = "POST" :: "POST",
		Url = "http://127.0.0.1:18259/stylua?Config=" .. encodedConfig,
		Headers = {
			["Content-Type"] = "text/plain",
		},
		Body = currentSource,
	})
	if not success then
		warn("[StyLua] Connecting to server failed: " .. tostring(result))
	elseif not result.Success then
		local body = result.Body :: any
		if typeof(body) == "string" and body:match("<!DOCTYPE html>") then
			local preText = body:match("<pre>(.-)</pre>")
			if preText then
				warn("[StyLua] " .. preText:gsub("&#39;", "'"):gsub("<br>", "\n"))
			else
				warn(
					"[StyLua] Request failed: " .. tostring(result.StatusCode) .. " " .. tostring(result.StatusMessage)
				)
			end
		else
			warn("[StyLua] " .. tostring(body))
		end
	else
		if currentSource == result.Body then
			return
		end

		local recording = ChangeHistoryService:TryBeginRecording("StyLua Format")
		updateScriptSource(script, result.Body)
		if recording then
			ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		else
			ChangeHistoryService:SetWaypoint("StyLua")
		end
	end
end

function format()
	if StudioService.ActiveScript then
		formatter(StudioService.ActiveScript)
		return
	end
	local Selected = Selection:Get()
	for _, Object in Selected do
		if Object:IsA("LuaSourceContainer") then
			formatter(Object)
		end
	end
end

local toolbar = plugin:CreateToolbar("StyLua")

local FormatButton = toolbar:CreateButton("StyLua", "Format Document", "rbxassetid://15177733701", "StyLua")
FormatButton.ClickableWhenViewportHidden = true

local SettingButton =
	toolbar:CreateButton("StyLuaSettings", "StyLua Settings", "rbxassetid://15177736312", "StyLua Settings")
SettingButton.ClickableWhenViewportHidden = true

FormatAction.Triggered:Connect(format)
FormatButton.Click:Connect(format)
SettingButton.Click:Connect(openSettings)

plugin.Unloading:Connect(function()
	if Connection then
		Connection:Disconnect()
		Connection = nil
	end
end)
