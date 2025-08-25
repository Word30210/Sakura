--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local module = {}

local SakuraStorage = ReplicatedStorage.sakura_storage

--#[ Modules ]#--
--

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

--#[ Functions ]#--
local function char(
    character: string
): number
    return string.byte(character)
end

local function span(
    a: vector?,
    b: vector?,
    c: vector?,
    d: vector?,
    e: vector?,
    f: vector?,
    g: vector?,
    h: vector?
): vector
    return vector.create(
        a and a.x
            or b and b.x
            or c and c.x
            or d and d.x
            or e and e.x
            or f and f.x
            or g and g.x
            or h and h.x
            or 0,
        h and h.y
            or g and g.y
            or f and f.y
            or e and e.y
            or d and d.y
            or c and c.y
            or b and b.y
            or a and a.y
            or 0,
        a and a.z
            or b and b.z
            or c and c.z
            or d and d.z
            or e and e.z
            or f and f.z
            or g and g.z
            or h and h.z
            or 0
    )
end

export type Issue = {
    message: string;
    span: vector;
}

export type Output = {
    issues: { Issue };
    result: any;
}