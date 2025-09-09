local LexerImpl = require("../src/storage/modules/url_parser_module/ast/lexer")

local myLexer = LexerImpl.new("sakura@${u41}use${114}::1234567890::menu?tab=profile&from=main")

while not myLexer:eof() do
    local token = myLexer:readKind()

    print(myLexer:tostring(token))

    if token.metadata then
        for key, value in token.metadata do
            print("  ", key, "=", tostring(value))
        end
    end

    local t = os.clock()
    repeat until os.clock() - t > 0.1
end

print("Issues found:")

for _, issue in myLexer.issues do
    print(issue.why, tostring(issue.span))
end

print("Source length:", myLexer.length)
print("Expected last position:", myLexer.length - 1)
print("Tokens found:", #myLexer.tokens)
print("All done.")