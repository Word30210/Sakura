--#[ Services ]#--
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local config = require(script.config)

--#[ Modules ]#--
local ClientModules = ReplicatedStorage.modules

local t = require(ClientModules.t)

--#[ Variables ]#--
--

--#[ Functions ]#--
local function call<ARGS..., RETS...>(
	func: (ARGS...) -> RETS...,
	...: ARGS...
): RETS...
	return func(...)
end

--#[ Main ]#--