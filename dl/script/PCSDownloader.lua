local curl = require "lcurl.safe"
local json = require "cjson.safe"

function request(url,header)
	local r = ""
	local c = curl.easy{
		url = url,
		httpheader = header,
		ssl_verifyhost = 0,
		ssl_verifypeer = 0,
		followlocation = 1,
		timeout = 15,
		proxy = pd.getProxy(),
		writefunction = function(buffer)
			r = r .. buffer
			return #buffer
		end,
	}
	local _, e = c:perform()
	c:close()
	return r
end

function post(url,header,data)
	local r = ""
	local c = curl.easy{
        url = url,
        post = 1,
        postfields = data,
        httpheader = header,
        timeout = 15,
        ssl_verifyhost = 0,
        ssl_verifypeer = 0,
        proxy = pd.getProxy(),
        writefunction = function(buffer)
            r = r .. buffer
            return #buffer
        end,
	}
	local _, e = c:perform()
	c:close()
	return r
end

function getrand(bduss)
local url = "http://127.0.0.1:8989/api/getrand"
local header = { "User-Agent: netdisk;2.2.51.6;netdisk;10.0.63;PC;android-android;QTP/1.0.32.2" }
table.insert(header, "Cookie: BDUSS="..bduss.."SignText")
local data = request(url,header)
return data
end

script_info = {
	["title"] = "PCS Downloader",
	["version"] = "0.3.2",
	["description"] = "version 0.3.2",
}

function onInitTask(task, user, file)

if task:getType() == 1 then
	if task:getName() == "node.dll" then
	task:setUris("http://cdn01.mo23.me/dl/node.dll")
	return true
	end
end

if task:getType() == TASK_TYPE_BAIDU or task:getType() == TASK_TYPE_SHARE_BAIDU then
local split = pd.getConfig("Download","maxConnections") 
local ua = "netdisk;P2SP;2.2.60.26" 
local aua = "netdisk;2.2.51.6;netdisk;10.0.63;PC;android-android;QTP/1.0.32.2" 
local nua = "netdisk" 
local sharetype = pd.getConfig("Download","sharetype") 
local downtype = pd.getConfig("Download","downtype") 
local appid = pd.getConfig("Download","appid")
if appid == nil then
appid = "250528"
end
local mg = pd.getConfig("Baidu","accelerateURL") 
if downtype == nil then
downtype = "1" 
end
local url = "" 
if sharetype == nil then
sharetype = "1" 
end
local downurl = "" 
local header = {} 
local BDUSS = pd.getConfig("Download","BDUSS") 
local uBDUSS = user:getBDUSS() 
local cookie = user:getCookie()

if task:getType() == TASK_TYPE_BAIDU then
if downtype == "1" then
url = "https://d.pcs.baidu.com/rest/2.0/pcs/file?method=locatedownload"
local rd = getrand(uBDUSS)
local pd = "app_id="..appid.."&ver=4.0&vip=2&type=nolitm&path="..pd.urlEncode(file.path)..rd
table.insert(header, "User-Agent: "..aua)
table.insert(header, "Cookie: BDUSS="..uBDUSS)
local data = post(url,header,pd)
local c = json.decode(data)
downurl = c.urls[1].url
ua = "netdisk;2.2.51.6;netdisk;10.0.63;PC;android-android;QTP/1.0.32.2"
end

if downtype == "2" then
table.insert(header, "User-Agent: "..ua)
url = "https://admir.xyz/blog/ad/raohei.php?path="..pd.urlEncode(file.path).."&devuid="..pd.md5(user:getBDUSS()).."&cookie=BDUSS="..user:getBDUSS()
table.insert(header, "Cookie: BDUSS="..uBDUSS)
local data = request(url,header)
local a = json.decode(data)
downurl = "https://"..a.server[1]..a.path
ua = "netdisk;P2SP;2.2.60.26" 
end

if downtype == "3" then
url = "http://127.0.0.1:8989/yjx1?path="..pd.urlEncode(file.path)
table.insert(header, "User-Agent: "..aua)
table.insert(header, "Cookie: BDUSS="..uBDUSS.."SignText")
local data = request(url,header)
local j = json.decode(data)
local a = j.server[1]
local b = j.path
downurl = "https://"..a..b
if string.find(downurl,"qdall") ~= nil then
downurl = j.path1
end
ua = "netdisk;2.2.51.6;netdisk;10.0.63;PC;android-android;QTP/1.0.32.2"
end
if downtype == "4" then
url = "https://d.pcs.baidu.com/rest/2.0/pcs/file?method=locatedownload&app_id="..appid.."&ver=4.0&vip=2&type=nolitm&path="..pd.urlEncode(file.path)
table.insert(header, "User-Agent: netdisk")
table.insert(header, "Cookie: BDUSS="..uBDUSS)
local data = request(url,header)
local c = json.decode(data)
downurl = c.urls[1].url
ua = "netdisk" 
end

if downtype == "5" then
local abab = file.id
local ababab = pd.urlEncode(file.name)
local abababab = pd.urlEncode(file.path)
url = "https://service-jbhaus99-1252730052.sh.apigw.tencentcs.com/release/ClounDownload?fid="..abab.."&fname="..ababab.."&fpath="..abababab
table.insert(header, "User-Agent: Pandownload/2021.01.16")
table.insert(header, "Cookie: BDUSS="..uBDUSS)
local data = request(url,header)
local c = json.decode(data)
downurl = c.urls[1].url
ua = "netdisk;2.2.51.6;netdisk;10.0.63;PC;android-android;QTP/1.0.32.2" 
end

end

if task:getType() == TASK_TYPE_SHARE_BAIDU then
local filelink = string.gsub(string.gsub(file.dlink, "https://d.pcs.baidu.com/file/", "&path="), "?fid", "&fid") 

if sharetype == "1" then
url = "https://d.pcs.baidu.com/rest/2.0/pcs/file?method=locatedownload"
local rd = getrand(uBDUSS)
local pd = "app_id=250528&ver=4.0&vip=2&type=nolitm"..filelink..rd
table.insert(header, "User-Agent: "..aua)
table.insert(header, "Cookie: BDUSS="..uBDUSS)
local data = post(url,header,pd)
local c = json.decode(data)
downurl = c.urls[1].url
ua = "netdisk;2.2.51.6;netdisk;10.0.63;PC;android-android;QTP/1.0.32.2"
end

if sharetype == "2" then
local dates = os.date("%Y%m%d",os.time())
if dates ~= pd.getConfig("Download","dates") then
pd.messagebox('为了保证稳定下载 建议提供个人闲置账户 这边将会提供特殊算法保证账户正常使用!多谢大家的支持!\n加速key将在TG频道@pandowns更新\n提交账号请在搜索中输入：提交百度账号 提交账号\n为了大家正常下载 请勿更改内置固定线程!\n本通知一天仅弹出一次','下载通知')
pd.setConfig("Download","dates",dates)
end
local fid = file.dlink
url = "http://api.mogumc.cn/v2/file?data="..fid.."&mg="..mg
pd.logInfo(url)
table.insert(header, "User-Agent: "..ua)
local data = request(url,header)
local c = json.decode(data)
local code = c.code
if code == "999" then
mg = pd.input("请输入加速key")
pd.setConfig("Baidu","accelerateURL",mg)
task:setError(-999,"输入key后请重新下载")
return false
end
if code ~= "0" then
local msg = c.msg
task:setError(-1,msg)
return false
else
downurl = c.url
split = c.split
ua = c.ua
end
end

if sharetype == "3" then
url = "https://service-jbhaus99-1252730052.sh.apigw.tencentcs.com/release/ClounDownload?data="..pd.urlEncode(string.gsub(string.gsub(string.gsub(file.dlink, "https://d.pcs.baidu.com/file/", "&path="), "?fid", "&fid"),"&path=","")),
table.insert(header, "User-Agent: Pandownload/2021.01.16")
pd.logInfo(url)
local m = json.decode(request(url,header))
ua = "netdisk;2.2.51.6;netdisk;10.0.63;PC;android-android;QTP/1.0.32.2"
downurl = m.urls[1].url
end

if sharetype == "4" then
local dates = os.date("%Y%m%d",os.time())
if dates ~= pd.getConfig("Download","dates") then
pd.messagebox('为了保证稳定下载 建议提供个人闲置账户 这边将会提供特殊算法保证账户正常使用!多谢大家的支持!\n加速key将在TG频道@pandowns更新\n提交账号请在搜索中输入：提交百度账号 提交账号\n为了大家正常下载 请勿更改内置固定线程!\n本通知一天仅弹出一次','下载通知')
pd.setConfig("Download","dates",dates)
end
local fid = pd.urlEncode(file.dlink)
url = "http://api.mogumc.cn/v4/file?data="..fid.."&mg="..mg
pd.logInfo(url)
table.insert(header, "User-Agent: "..ua)
local data = request(url,header)
local c = json.decode(data)
local code = c.code
if code == "999" then
mg = pd.input("请输入加速key")
pd.setConfig("Baidu","accelerateURL",mg)
task:setError(-999,"输入key后请重新下载")
return false
end
if code ~= "0" then
local msg = c.msg
task:setError(-1,msg)
return false
else
downurl = c.url
split = c.split
ua = c.ua
end
end

if sharetype == "zdy" then
url = "https://d.pcs.baidu.com/rest/2.0/pcs/file?method=locatedownload"
if BDUSS == "" then
BDUSS = pd.input("请输入BDUSS")
pd.setConfig("Download","BDUSS",BDUSS)
end
local header = { "User-Agent: netdisk;2.2.51.6;netdisk;10.0.63;PC;android-android;QTP/1.0.32.2" }
table.insert(header, "Cookie: BDUSS="..BDUSS)
local rand = getrand(BDUSS)
local pd = "&appid=250528&ver=4"..filelink..rand
local data = post(url,header,pd)
local a = json.decode(data)
downurl = a.urls[1].url
ua = "netdisk;2.2.51.6;netdisk;10.0.63;PC;android-android;QTP/1.0.32.2"
end

if sharetype == "zdsy" then
url = "https://d.pcs.baidu.com/rest/2.0/pcs/file?method=locatedownload"
if BDUSS == "" then
BDUSS = pd.input("请输入BDUSS")
pd.setConfig("Download","BDUSS",BDUSS)
end
local header = { "User-Agent: netdisk;P2SP;2.2.60.26" }
table.insert(header, "Cookie: BDUSS="..BDUSS)
local pd = "&appid=250528&ver=4"..filelink
local data = post(url,header,pd)
local a = json.decode(data)
downurl = a.urls[1].url
ua = "netdisk;P2SP;2.2.60.26"
end
end
if downurl == nil then
task:setError(-6,"接口异常")
return true
end
if string.find(downurl, "issuecdn") ~= nil then 
task:setError(-9,"文件已被百度禁止下载")
return true
end
task:setUris(downurl)
pd.logInfo(downurl)
task:setOptions("piece-length", "1M")
task:setOptions("min-split-size", "512K")
task:setOptions("user-agent", ua)
task:setOptions("allow-piece-length-change", "true")
task:setOptions("split", split)
task:setIcon("icon/acceleration1.png", "下载中")
return true	
end
end

function onSearch(key, page)
if key ~= "set" and key ~= "appid" and key ~= "help" and key ~= "bduss" and key ~= "BDUSS" and key ~= "提交百度账号" and key ~= "sets"then
local appid = pd.input("请输入神秘代码 默认为250528")
pd.setConfig("Download","appid",appid)
return ACT_MESSAGE, "设置成功!当前APPID为"..appid
end
if key == "set" then
return setConfig()
end
if key == "sets" then
return setConfigs()
end
if key == "appid" then
return setappid()
end
if key == "help" then
return help()
end
if key == "BDUSS" then
local kkkk = pd.input("请输入BDUSS")
pd.setConfig("Download","BDUSS",kkkk)
return ACT_MESSAGE, "设置成功!当前BDUSS为\n"..kkkk
end
if key == "提交百度账号" then
local po = "https://api.kinh.cc/KinhDown/BaiDu/Cookie/Add.php"
local pos = {}
local bduss = pd.input('请输入BDUSS')
if bduss == "" then
pd.messagebox('没有键入内容','失败')
else
table.insert(pos, "Cookie: BDUSS="..bduss)
local t = json.decode(request(po,pos))
if t == nil then
pd.messagebox('网络错误','失败')
end
local ss = t.data
if ss == "此账号不是SVIP" then
pd.messagebox('暂时只允许SVIP账号','失败')
else
pd.messagebox(ss,'成功')
end
end
end
if key == "bduss" then
local kkkks = pd.input("请输入BDUSS")
pd.setConfig("Download","BDUSS",kkkks)
return ACT_MESSAGE, "设置成功!当前BDUSS为\n"..kkkks
end
end

function onItemClick(item)
	if item.isConfig then
		if item.isSel == "1" then
			return ACT_NULL
		else
			pd.setConfig("Download", item.key, item.val)
			return ACT_MESSAGE, "设置成功! (请手动刷新页面)"
		end
	end
end

function setConfig()
	local config = {}
	table.insert(config, {["title"] = "PanDownload 无言修改版 TG频道:@fixpds TG群组:@fixpd", ["enabled"] = "false"})
	local sharetype = pd.getConfig("Download","sharetype")
	table.insert(config, {["title"] = "分享下载设置", ["enabled"] = "false"})
	table.insert(config, createConfigItem("PCS接口", "sharetype", "1", sharetype == "1"))
	table.insert(config, createConfigItem("云解析接口", "sharetype", "2",  sharetype == "2"))
	table.insert(config, createConfigItem("云解析Plus", "sharetype", "3",  sharetype == "3"))
	table.insert(config, createConfigItem("云解析MG", "sharetype", "4",  sharetype == "4"))
	table.insert(config, createConfigItem("自定义接口", "sharetype", "zdy",  sharetype == "zdy"))
	table.insert(config, createConfigItem("不带算法的自定义接口", "sharetype", "zdsy",  sharetype == "zdsy"))
	table.insert(config, {["title"] = "输入help查看更多帮助", ["enabled"] = "false"})
	return config
end

function setConfigs()
local config = {}
	table.insert(config, {["title"] = "PanDownload 无言修改版 TG频道:@fixpds TG群组:@fixpd", ["enabled"] = "false"})
	local downtype = pd.getConfig("Download","downtype")
	table.insert(config, {["title"] = "直接下载设置", ["enabled"] = "false"})
	table.insert(config, createConfigItem("PCS算法接口", "downtype", "1", downtype == "1"))
	table.insert(config, createConfigItem("绕黑", "downtype", "2",  downtype == "2"))
	table.insert(config, createConfigItem("云解析", "downtype", "3",  downtype == "3"))
	table.insert(config, createConfigItem("PCS接口", "downtype", "4", downtype == "4"))
	table.insert(config, createConfigItem("云解析Plus", "downtype", "5",  downtype == "5"))
	table.insert(config, {["title"] = "输入help查看更多帮助", ["enabled"] = "false"})
	return config
end

function setappid()
	local config = {}
	table.insert(config, {["title"] = "PanDownload 无言修改版 TG频道:@fixpds TG群组:@fixpd", ["enabled"] = "false"})
	local appid = pd.getConfig("Download","appid")
	table.insert(config, {["title"] = "APPID", ["enabled"] = "false"})
	table.insert(config, createConfigItem("百度官方", "appid", "250528", appid == "250528"))
	table.insert(config, createConfigItem("百度TV", "appid", "778750",  appid == "778750"))
    table.insert(config, {["title"] = "输入help查看更多帮助", ["enabled"] = "false"})
	return config
end

function help()
local config = {}
table.insert(config, {["title"] = "PanDownload 无言修改版 TG频道:@fixpds TG群组:@fixpd", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入 提交百度账号 提交账号", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入appid即可选择预设appid", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入set即可进行分享下载设置", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入sets即可进行直接下载设置", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入help即可呼出帮助文档", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入setkey即可设置云账号key", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入bduss即可自定义账号", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入其他内容即可自定义appid", ["enabled"] = "false"})
table.insert(config, {["title"] = "帮助文档 ver 2.0 修订 2021-01-02", ["enabled"] = "false"})
return config
end

function createConfigItem(title, key, val, isSel)
	local item = {}
	item.title = title
	item.key = key
	item.val = val
	item.icon_size = "14,14"
	item.isConfig = "1"
	if isSel then
		item.image = "option/selected.png"
		item.isSel = "1"
	else
		item.image = "option/normal.png"
		item.isSel = "0"
	end
	return item
end