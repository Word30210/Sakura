local LexerImpl = require("../src/storage/modules/url_parser_module/ast/lexer")

local myLexer = LexerImpl.new("sakura@ABCD::1234567890::menu?tab=profile&from=main${u1ab1}")

local lastSpan: vector? = nil
local malformedTokens: number = 0

while not myLexer:eof() do
    local token = myLexer:readKind()

    if lastSpan and lastSpan.x == token.span.x and lastSpan.y == token.span.y then
        warn("Something went wrong, stuck at the same position: " .. tostring(token.span))
        warn("Stucked token:", myLexer:tostring(token))

        break
    else
        lastSpan = token.span
    end

    malformedTokens += token.malformed and 1 or 0

    print(`{ token.malformed and "\u{1b}[31m" or "\u{1b}[32m" }{ myLexer:tostring(token) }\u{1b}[0m`)
end

print("----------------")

print("Issues found:")

for _, issue in myLexer.issues do
    print(`\u{1b}[31m{ issue.why }\u{1b}[0m | \u{1b}[35m{ issue.span.x }, { issue.span.y }\u{1b}[0m`)
end

print("----------------")

local function isSuccessful()
    if next(myLexer.issues) then
        return false
    end

    if lastSpan and lastSpan.y ~= myLexer.length - 1 then
        return false
    end

    if malformedTokens > 0 then
        return false
    end

    return true
end

print("Source length:", myLexer.length)
print("Expected last position of the content:", myLexer.length - 1)
print("Expected position of EOF:", myLexer.length)
print("Tokens found:", #myLexer.tokens)
print("Malformed tokens found:", malformedTokens)
print(`All done. { isSuccessful() and "\u{1b}[32mSuccess!" or "\u{1b}[31mFailed." }\u{1b}[0m`)