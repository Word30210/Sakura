--!strict

--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local page = {}
local path = script.Name

local SakuraStorage = ReplicatedStorage.sakura_storage

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

--#[ Fusion ]#--
local Fusion = require(Modules.fusion)
local peek = Fusion.peek
local scoped = Fusion.scoped
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange

--#[ Variables ]#--
local globals = require(SakuraStorage.globals)
local scopes = globals.scopes

local pages: { [Scope]: Page } = {}

--#[ Functions ]#--
--

--#[ Types ]#--
type Fusion = typeof(Fusion)
type UsedAs<T> = Fusion.UsedAs<T>
type Scope<T = Fusion> = Fusion.Scope<T>

type Page<T=any> = globals.Page<T>

--#[ Main ]#--
function page.initialize()
	if scopes[path] then
		scopes[path]:doCleanup()
	end
	
	scopes[path] = globals.rootScope:innerScope(Fusion)
	
	warn(scopes[path])
end

function page.uninitialize()
	for scope, page in pages do
		page.Remover(scope)
		
		pages[scope] = nil
	end
end

function page.new<S>(
	scope: Fusion.Scope<typeof(Fusion) & S>,
	params: any
): Page<S>
	local scope = scope:innerScope(Fusion)
	
	local page: Page<S> = {
		Path = path;
		Icon = scope:Value("rbxassetid://135586789898242");

		Renderer = function(
			scope: Fusion.Scope<typeof(Fusion) & S>
		)
			return scope:New "Frame" {
				Size = UDim2.fromScale(1, 1);

				BackgroundColor3 = Color3.new(1, 0, 0);
			}
		end;

		Remover = function(
			scope: Fusion.Scope<typeof(Fusion) & S>
		)
			scope:doCleanup()
		end;
	}
	
	pages[scope] = page
	
	return page
end

return page