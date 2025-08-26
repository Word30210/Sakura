--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local module = {}

local SakuraStorage = ReplicatedStorage.sakura_storage

--#[ Modules ]#--
--

--#[ Types ]#--
export type Issue = {
    why: string;
    span: vector;
}

export type Token<K = "scope" | "segment" | "argument" | "operator"> = {
    kind: K;
    value: string;
    span: vector;
}

export type Output = {
    result: { Token };
    issues: { Issue };
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

--#[ Functions ]#--
local function char(
    character: string
): number
    return string.byte(character)
end

local function expand_span(
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

local function isWhitespace(
    character: number
): boolean
    return character == char "\32"
        or character == char "\t"
        or character == char "\r"
        or character == char "\n"
        or character == char "\f"
        or character == char "\v"
end

local function isDigit(
    character: number
): boolean
    return char "0" <= character and character <= char "9"
end

local function isAlpha(
    character: number
): boolean
    return (char "A" <= character and character <= char "Z")
        or (char "a" <= character and character <= char "z")
end

local function isHex(
    character: number
): boolean
    return (char "0" <= character and character <= char "9")
        or (char "A" <= character and character <= char "H")
        or (char "a" <= character and character <= char "h")
end

local function isBase36(
    character: number
): boolean
    return (char "0" <= character and character <= char "9")
        or (char "A" <= character and character <= char "Z")
        or (char "a" <= character and character <= char "z")
end

local function isIdent(
    character: number
): boolean
    return (char "0" <= character and character <= char "9")
        or (char "A" <= character and character <= char "Z")
        or (char "a" <= character and character <= char "z")
        or character == char "_" or character == char "-"
end

local function isSkipable(
    character: number
): boolean
    return character == char "\32" or character == char "\t" or character == char "\f"
end

local function parseURLPattern(
    source: buffer
): Output
    local position = 0
    local line = 0
    local length = buffer.len(source)
    local issues: { Issue } = {}

    local function throw(
        message: string,
        span: vector
    )
        table.insert(
            issues,
            {
                why = message;
                span = span;
            }
        )
    end

    local function panic(
        message: string?
    ): never
        if message then
            table.insert(
                issues,
                {
                    why = message;
                    span = vector.zero;
                }
            )
        end

        error {
            result = nil;
            issues = issues;
        }
    end

    local function eof(
        message: string
    )
        if position >= length then
            table.insert(
                issues,
                {
                    why = message;
                    span = vector.create(position, position, line)
                }
            )

            error({
                result = nil;
                issues = issues;
            }, 0)
        end

        return false
    end

    local function peek(): number
        if position == length then return 0 end

        return buffer.readu8(source, position)
    end

    local function peekNext(): number
        if position + 1 >= length then return 0 end

        return buffer.readu8(source, position + 1)
    end 

    local function bump()
        position = math.min(position + 1, length)
    end

    local function bumpAny()
        if peek() == char "\n" then
            line += 1
        end

        bump()
    end

    local function bumpPeek(): number
        bump()

        return peek()
    end

    local function stringBackslash()
        local character = peek()

        if character == char "\r" then
            character = bumpPeek()

            if character == char "\n" then
                bump()

                line += 1
            end
        elseif character == char "z" then
            bump()

            while isWhitespace(peek()) do
                bumpAny()
            end
        else
            bumpAny()
        end
    end

    local function readScope(): "scope" | "error"
        local character: number = peek()

        while
            isIdent(character)
            or not eof(`expected scope to be finished at { position }`)
        do
            if
                character == 0
                or character == char "\r"
                or character == char "\n"
                or character == char "\v"
            then
                return "error"
            end

            character = bumpPeek()
        end

        bump()

        return "scope"
    end

    local function readSegment(): "segment" | "error"
        local character: number = peek()

        while
            isIdent(character)
            or character == char "\\"
            or not eof(`expected segment to be finished at { position }`)
        do
            if
                character == 0
                or character == char "\r"
                or character == char "\n"
                or character == char "\v"
            then
                return "error"
            elseif character == char "\\" then
                bump()
                stringBackslash()
            else
                bump()
            end

            character = peek()
        end

        bump()

        return "segment"
    end

    local function readArgument(): "argument" | "error"
        local percent: number = peek()
        local character: number = bumpPeek()

        while
            isIdent(character) or character == char "\\" or not eof(`expected argument name to be finished at { position }`)
        do
            if
                character == 0
                or character == char "\r"
                or character == char "\n"
                or character == char "\v"
            then
                return "error"
            elseif character == char "\\" then
                bump()
                stringBackslash()
            else
                bump()
            end

            character = peek()
        end

        if peek() ~= char ":" then
            return "error"
        end

        bump()

        while
            isBase36(character) or not eof(`expected argument type to be finished at { position }`)
        do
            if
                character == 0
                or character == char "\r"
                or character == char "\n"
                or character == char "\v"
            then
                return "error"
            end

            character = bumpPeek()
        end

        bump()

        return "argument"
    end

    
end