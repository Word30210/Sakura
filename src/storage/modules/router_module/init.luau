--[[

urlPattern: scope@segment1::segment2::%argument1:int%::segment3::%argument2:alphabet%
url: scope@segment1::segment2::123456::segment3::abcdef?key1=value2&key2=value2

TODO LIST
- 음 좋아. 내가 왜 파서 만들 때 정규식을 안썼었는지 이제 이해가 가네.
- 미친 이스케이프 처리 때문에 정규식써서 만든 파서 상남자식으로 다시 만들어야 할듯...

]]

--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local module = {}

local SakuraStorage = ReplicatedStorage.sakura_storage

--#[ Modules ]#--
--

--#[ Types ]#--
type argumentType = "alhpa" | "any" | "base36" | "hex" | "int" | "uuid"

type parseURLPatternResult = {
    scope: string;
    path: {
        {
            type: "segment" | "argument";
            argumentType: argumentType?;
            value: string;
        }
    };

    failed: boolean?;
    reason: string?;
    -- reasonForUser: string?;
}

--#[ Variables ]#--
local globals = require(SakuraStorage.globals)

local urlOperators = {
    ["@"] = true;
    [":"] = true;
    ["::"] = true;
    ["%"] = true;
    ["^"] = true;
    ["?"] = true;
    ["="] = true;
    ["&"] = true;
}
local urlOperatorToName = {
    ["@"] = "at";
    [":"] = "colon";
    ["%"] = "percent";
    ["^"] = "caret";
    ["?"] = "question";
    ["="] = "equal";
    ["&"] = "ampersand";
}
local argumentTypes = {
    ["alhpa"] = true;
    ["any"] = true;
    ["base36"] = true;
    ["hex"] = true;
    ["int"] = true;
    ["uuid"] = true;
}

local registeredClientPages: { [string]: ModuleScript } = {}

--#[ Functions ]#--
local function isWhitespace(
    character: string
): boolean
    return character == "\32"
        or character == "\t"
        or character == "\n"
        or character == "\r"
        or character == "\f"
        or character == "\v"
end

local function isDigit(
    character: string
): boolean
    local byte = string.byte(character)

    return string.byte("0") <= byte and byte <= string.byte("9")
end

local function isAlphabet(
    character: string
): boolean
    local byte = string.byte(character)

    return (string.byte("A") <= byte and byte <= string.byte("Z")) or (string.byte("a") <= byte and byte <= string.byte("z"))
end

local function isHexadecimal(
    character: string
): boolean
    if isDigit(character) then
        return true
    end

    local byte = string.byte(character)

    return (string.byte("A") <= byte and byte <= string.byte("F")) or (string.byte("a") <= byte and byte <= string.byte("f"))
end

local function isBase36(
    character: string
): boolean
    return isDigit(character) or isAlphabet(character)
end

function module.parseURLPattern(
    urlPattern: string
): parseURLPatternResult
    local result = {} :: parseURLPatternResult
    local position = 1

    --// urlPattern 길이 검사
    if #urlPattern < 3 then
        result.failed = true
        result.reason = `urlPattern '{ urlPattern }' is too short.`

        return result
    end

    --// whitespace 제거
    urlPattern = urlPattern:gsub("%s", "")

    --// escape 문자 전처리
    --// "\0" ~= ""
    for operator, name in pairs(urlOperatorToName) do
        urlPattern = urlPattern:gsub(`%^%{ operator }`, `\0{ name }\0`)
    end

    urlPattern = urlPattern:gsub("%^(%d+)", function(
        character: string
    )
        return string.char(tonumber(character) :: number)
    end):gsub("%^(.)", "%1")

    --// urlScope 추출
    local urlScope = urlPattern:match("^(.-)@")

    --// urlScope 검사
    if not urlScope then
        result.failed = true
        result.reason = `urlPattern '{ urlPattern }' is missing '@'.`

        return result
    end

    if urlScope == "" then
        result.failed = true
        result.reason = `urlPattern '{ urlPattern }' must include a urlScope.`
    end

    if not urlScope:match("^[%w_]") then
        result.failed = true
        result.reason = `urlScope cannot start with '{ urlScope:sub(1, 1) }'.`

        return result
    end

    if not urlScope:match("[%w%-_]+") then
        result.failed = true
        result.reason = `urlScope '{ urlScope }' must contain only alphanumeric characters, '-' and "_".`
    end

    position += #urlScope + 1 --// the @
    result.scope = urlScope

    result.path = {}

    local segmentAndArgumentCount = 0

    --// urlPath 추출
    while position <= #urlPattern do
        local segmentOrArgument: string?, isLastSegmentOrArgument: boolean do
            warn("dddd", urlPattern:sub(position))

            local middleSegmentOrArgument = urlPattern:match("(.-)::", position)
            
            if middleSegmentOrArgument then
                warn(middleSegmentOrArgument, middleSegmentOrArgument == "")

                segmentOrArgument = middleSegmentOrArgument
                isLastSegmentOrArgument = false
            else
                segmentOrArgument = urlPattern:match("(.+[^:])$", position)
                isLastSegmentOrArgument = true
            end
        end

        if segmentOrArgument then
            warn(segmentOrArgument, isLastSegmentOrArgument)
            segmentAndArgumentCount += 1

            if segmentOrArgument == "" then
                result.failed = true
                result.reason = `{ globals.functions.toOrdinal(segmentAndArgumentCount) } segment/argument is empty.`

                return result
            end

            local argumentSet = segmentOrArgument:match("%%(.-)%%")

            if not argumentSet then
                --// the '%' is not paired. so it's just a segment
                local segment = segmentOrArgument

                table.insert(
                    result.path,
                    {
                        type = "segment";
                        value = segment;
                    }
                )

                position += #segment + if not isLastSegmentOrArgument then 2 else 0

                continue
            elseif argumentSet == "" then
                --// the '%' is paired. but the content is empty.
                result.failed = true
                result.reason = `the urlArgument of the { globals.functions.toOrdinal(segmentAndArgumentCount) } segment/argument item is empty`

                return result
            else
                --// approved.
                local argumentName, argumentType = argumentSet:match("(.-):(.+)")

                if argumentName == nil or argumentType == nil then
                    result.failed = true
                    result.reason = `the urlArgument of the { globals.functions.toOrdinal(segmentAndArgumentCount) } segment/argument item must contain ':'.`

                    return result
                end

                if argumentName == "" then
                    result.failed = true
                    result.reason = `name of the urlArgument of the { globals.functions.toOrdinal(segmentAndArgumentCount) } segment/argument item is empty.`

                    return result
                end

                if argumentType == "" then
                    result.failed = true
                    result.reason = `name of the urlArgument of the { globals.functions.toOrdinal(segmentAndArgumentCount) } segment/argument item is empty.`

                    return result
                end

                if not argumentTypes[argumentType] then
                    result.failed = true
                    result.reason = `'{ argumentType }' is invalid argumentType.`

                    return result
                end

                table.insert(
                    result.path,
                    {
                        type = "argument";
                        argumentType = argumentType :: argumentType;
                        value = argumentName;
                    }
                )

                position += #argumentSet + 2 + if not isLastSegmentOrArgument then 2 else 0

                continue
            end
        else
            --// just a malformed segment/argument
            result.failed = true
            result.reason = `the { globals.functions.toOrdinal(segmentAndArgumentCount) } segment/argument is malformed.`

            return result
        end
    end

    --// urlPath가 추출 되었는지 검사
    if not next(result.path) then
        result.failed = true
        result.reason = `urlPattern '{ urlPattern }' is malformed.`

        return result
    end

    --// escape 문자 후처리
    --// "\0" ~= ""
    for operator, name in next, urlOperatorToName do
        urlPattern = urlPattern:gsub(`\0{ name }\0`, operator)
    end

    return result
end

--#[ Main ]#--
function module.registerClientPage(
    urlPattern: string,
    pageModule: ModuleScript
)
    
end

return module