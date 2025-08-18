--!strict

--#[ Services ]#--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui
local __sakuraServerPageReplication = playerGui:WaitForChild("__SakuraServerPageReplication") :: ScreenGui

local module = {}

local SakuraStorage = ReplicatedStorage.sakura_storage

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

--#[ Packets ]#--
local Packets = SakuraStorage.packets

local PagePacket = require(Packets.page)

--#[ Fusion ]#--
local Fusion = require(Modules.fusion)
local peek = Fusion.peek
local scoped = Fusion.scoped

--#[ Types ]#--
type UsedAs<T> = Fusion.UsedAs<T>

export type Page<S=any> = {
	Path: string;
	Title: UsedAs<string>?;
	Icon: UsedAs<string>;

	Renderer: (
		scope: Fusion.Scope<S>
	) -> any;

	Remover: (
		scope: Fusion.Scope<S>
	) -> ();
}

--#[ Variables ]#--
local pages = SakuraStorage.Pages
local clientPages = pages.ClientPages

local loadedServerPageModuleScripts: { [string]: ModuleScript } = {}
local pageRequestYields: { [string]: { thread } } = {}

--#[ Functions ]#--
local function call<ARG..., RET...>(
	fn: (
		ARG...
	) -> RET...,
	...: ARG...
): RET...
	return fn(...)
end

local function getPageRequest(
	path: string
): (ModuleScript?, boolean, string?)
	if not pageRequestYields[path] then
		pageRequestYields[path] = {}
		
		PagePacket.getPageRequest.send(path)
	end
	
	table.insert(pageRequestYields[path], coroutine.running())
	
	return coroutine.yield()
end

--#[ Main ]#--
function module.getPage(
	path: string
): (Page?, boolean, string?)
	local clientPage = clientPages:FindFirstChild(path) :: ModuleScript
	
	if clientPages then
		return call(require, clientPage) :: Page, true, nil
	end
	
	if loadedServerPageModuleScripts[path] then
		return call(require, loadedServerPageModuleScripts[path]) :: Page, true, nil
	end
	
	local pageModuleScript, success, message = getPageRequest(path)
	
	if success then
		return call(require, pageModuleScript :: ModuleScript) :: Page, true, nil
	else
		return nil, false, message
	end
end

PagePacket.getPageResult.listen(function(
	data
)
	if pageRequestYields[data.path] then
		if data.success then
			local pageModuleScript = __sakuraServerPageReplication:WaitForChild(data.path)
			
			for _, thread in pageRequestYields[data.path] do
				coroutine.resume(thread, pageModuleScript, true, nil)
			end
		else
			for _, thread in pageRequestYields[data.path] do
				coroutine.resume(thread, nil, false, data.message)
			end
		end
	end
end)