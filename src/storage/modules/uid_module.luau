--#[ Services ]#--
--

--#[ Head Variables ]#--
local module = {}
local rng = Random.new(os.time())

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