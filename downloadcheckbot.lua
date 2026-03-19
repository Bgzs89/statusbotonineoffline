-- COPY THIS TEXT AND PASTE IN LUCIFER EXECUTOR

link = "your webhook link"
messageId = msg id -- if u dont have msg id or first time using this, use *messageId = nil* then copy the message id and put in here

local client = HttpClient.new()
client.url = "https://raw.githubusercontent.com/Bgzs89/statusbotonineoffline/refs/heads/main/updated%20checkbot%20v1.4.lua"
local result = client:request()
getBot():runScript(result.body)
