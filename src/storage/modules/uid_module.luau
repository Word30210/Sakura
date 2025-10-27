--#[ Types ]#--
type fixedRng = {
    NextInteger: (self: fixedRng, min: number, max: number) -> number;
}

--#[ Services ]#--
--

--#[ Head Variables ]#--
local module = {}
local rng do
    if _VERSION == "Luau" then
        rng = (Random.new(os.time()) :: any) :: fixedRng
    else
        rng = {
            NextInteger = function(self, min: number, max: number): number
                return math.random(min, max)
            end
        }
    end
end


--#[ Variables ]#--
--

--#[ Functions ]#--
--

--#[ Main ]#--
function module.generateHashes(
    length: number
): string
    local uid = ""

    for i = 1, length do
        local randNum = rng:NextInteger(0, 15)

        uid ..= string.format("%x", randNum)
    end

    return uid
end

return module