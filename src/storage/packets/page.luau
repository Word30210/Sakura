--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

local ByteNet = require(Modules.bytenet)

--#[ Variables ]#--
--

--#[ Functions ]#--
--

--#[ Main ]#--
return ByteNet.defineNamespace("SakuraPage", function()
	return {
		getPageRequest = ByteNet.definePacket {
			value = ByteNet.string;
		};
		
		getPageResult = ByteNet.definePacket {
			value = ByteNet.struct {
				path = ByteNet.string;
				success = ByteNet.bool;
				message = ByteNet.optional(ByteNet.string);
			}
		}
	}
end)