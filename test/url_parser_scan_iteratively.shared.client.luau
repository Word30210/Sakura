local LexerImpl = require("../src/storage/modules/url_parser_module/ast/lexer")

local myLexer = LexerImpl.new("sakura@ABCD::1234567890::menu?tab=profile&from=main${u1ab1}")

local lastSpan: vector? = nil
local malformedTokens: number = 0

for index, lexme in myLexer:scanIteratively() do
    local lexme = lexme :: LexerImpl.Lexme

    print(`{ lexme.malformed and "\u{1b}[31m" or "\u{1b}[32m" }{ myLexer:tostring(lexme) }\u{1b}[0m`)
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