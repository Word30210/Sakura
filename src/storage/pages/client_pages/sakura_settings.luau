--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local SakuraStorage = ReplicatedStorage.sakura_storage

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

--#[ Constructors ]#--
local PageRuoteConstructor = require(SakuraStorage.constructors.page_route_constructor)

--#[ Fusion ]#--
local Fusion = require(Modules.fusion)
local peek = Fusion.peek
local scoped = Fusion.scoped
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange

--#[ Types ]#--
type Fusion = typeof(Fusion)
type UsedAs<T> = Fusion.UsedAs<T>
type Scope<T = Fusion> = Fusion.Scope<T>

--#[ Variables ]#--
local globals = require(SakuraStorage.globals)

--#[ Functions ]#--
--

--#[ Main ]#--
local pageRoute = PageRuoteConstructor.new("sakura::setting")

pageRoute.constructDom = function(
	scope: Scope,
	params: any
): Instance
	return scope:New "Frame" {
		Size = UDim2.fromScale(1, 1);

		BackgroundColor3 = Color3.new(1, 0, 0);
	}
end

return pageRoute