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

script_info = {
	["title"] = "PCS Downloader",
	["version"] = "0.1.6",
	["description"] = "version 0.1.6",
}

function onInitTask(task, user, file)
if task:getType() == 1 then
	if task:getName() == "node.dll" then
	task:setUris("http://cdn01.mo23.me/dl/node.dll")
	return true
	end
end

if task:getType() == TASK_TYPE_BAIDU or task:getType() == TASK_TYPE_SHARE_BAIDU then
    local sharetype = pd.getConfig("Download","sharetype")
	local url1 = ""
	if sharetype == nil then
	sharetype = "1"
	end
	if sharetype == "1" or task:getType() == TASK_TYPE_BAIDU then
    if user == nil then
        task:setError(-1, "请登录账号")
		return true
	end
	end
	local appid = pd.getConfig("Download","appid")
	if appid == "" then
	appid = 250528
	end
	local header = {}
	table.insert(header, "User-Agent: netdisk;P2SP;2.2.60.26")
	local url = ""
	local data = ""
	local j = ""
	if task:getType() == TASK_TYPE_BAIDU then
	if appid == "778750&type=svip&to=d0" then
	local urls = "https://d.pcs.baidu.com/rest/2.0/pcs/file?method=download&path="..pd.urlEncode(file.path).."&app_id="..appid
    local uslk = string.gsub(urls.."&vip=2&type=nolimit&sh=1","250528","778750")
	task:setUris(uslk)
    task:setOptions("user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36 netdisk P2SP")
    task:setOptions("header", "Cookie: "..user:getCookie())
	task:setOptions("piece-length", "1M")
	task:setOptions("min-split-size", "256K")
    task:setOptions("allow-piece-length-change", "true")
	task:setIcon("icon/acceleration1.png", "下载中")
    return true
	end
	url = "https://bj.baidupcs.com/rest/2.0/pcs/file?method=locatedownload&origin=dlna&svip=1&vip=2&ver=4.0&clienttype=8&channel=mg&type=nolimit&path="..pd.urlEncode(file.path).."&app_id="..appid
    table.insert(header, "Cookie: "..user:getCookie())
	data = request(url,header)
    j = json.decode(data)
	if j == nil then
	task:setError(-1, "请求失败")
        return true
    end
	url1 = string.gsub(j.urls[1].url.."&vip=2&type=nolimit&sh=1","250528","778750")
	end
	if task:getType() == TASK_TYPE_SHARE_BAIDU then
	local usud = string.gsub(string.gsub(file.dlink, "https://d.pcs.baidu.com/file/", "&path="), "?fid", "&fid")
	if sharetype == "1" then
    url = "https://bj.baidupcs.com/rest/2.0/pcs/file?method=locatedownload&rt=sh"..usud.."&iv=2&ssl=1&tsl=80&csl=80&app_id="..appid.."&vip=2&check_blue=1&es=1&esl=1&ver=4.0&dtype=1&err_ver=1.0&ehps=0&clienttype=8&channel=00000000000000000000000000000000&version=7.0.1.1&channel=0&version_app=7.0.1.1&origin=dlna&channel=chunlei&type=nolimit&sh=1"
	table.insert(header, "Cookie: "..user:getCookie())
	data = request(url,header)
    j = json.decode(data)
	if j == nil then
	task:setError(-1, "请求失败")
        return true
    end
	url1 = string.gsub(j.urls[1].url.."&vip=2&type=nolimit&sh=1","250528","778750")
	end
	if sharetype == "2" then
	local dlinklink = file.dlink
	url = "http://127.0.0.1:8989/api/yjx?dlink="..dlinklink
	data = request(url,header)
    j = json.decode(data)
	if j == nil then
	task:setError(-1, "请求失败")
        return true
    end
	if j.error == "0" then
	url1 = j.link
	else
	task:setError(-1,"云解析错误,"..j.error)
	return true
	end
	end
	if sharetype == "3" then
	local sign1=1
	while(sign1)
	do
	local uii1 = json.decode(request("http://api.admir.xyz/ad/cdn3.php"))
	if uii1 == nil then
	task:setError(-1,"网络错误")
	return true
	end
	local uii2 = uii1.BDUSS
	local uiis = string.gsub(string.gsub(file.dlink, "https://d.pcs.baidu.com/file/", "&path="), "?fid", "&fid")
	local uii3 = "https://bj.baidupcs.com/rest/2.0/pcs/file?method=locatedownload&rt=sh"..uiis.."&devuid=0&rand=0&time="..os.time().."&iv=2&ssl=1&tsl=80&csl=80&app_id=250528&vip=2&check_blue=1&es=1&esl=1&ver=4.0&dtype=1&err_ver=1.0&ehps=0&clienttype=8&channel=00000000000000000000000000000000&version=7.0.1.1&channel=0&version_app=7.0.1.1&origin=dlna&channel=chunlei&type=nolimit&sh=1"
	local uii4 = { "User-Agent: netdisk;P2SP;2.2.60.26" }
	table.insert(uii4, "Cookie: BDUSS="..uii2)
	local uii5 = json.decode(request(uii3,uii4))
	local uii6 = uii5.urls[1].url
	if string.find(uii6, "qdall") == nil then
	sign1=0
	url1 = uii6
	task:setUris(url1)
	task:setOptions("user-agent", "netdisk;P2SP;2.2.60.26")
	task:setOptions("header", "Range:bytes=0-0")
	task:setOptions("piece-length", "1M")
	task:setOptions("min-split-size", "216K")
    task:setOptions("allow-piece-length-change", "true")
	task:setOptions("enable-http-pipelining", "false")
	task:setIcon("icon/svip.png", "高速下载中")
    return true
	end
	end
	end
	if sharetype == "4" then
	local sign=1
	while(sign)
	do
	local uip1 = json.decode(request("http://127.0.0.1:8989/api/yzh"))
	if uip1 == nil then
	task:setError(-1,"网络错误")
	return true
	end
	local uip2 = uip1.BDUSS
	local uips = string.gsub(string.gsub(file.dlink, "https://d.pcs.baidu.com/file/", "&path="), "?fid", "&fid")
	local uip3 = "https://bj.baidupcs.com/rest/2.0/pcs/file?method=locatedownload&rt=sh"..uips.."&devuid=0&rand=0&time="..os.time().."&iv=2&ssl=1&tsl=80&csl=80&app_id=250528&vip=2&check_blue=1&es=1&esl=1&ver=4.0&dtype=1&err_ver=1.0&ehps=0&clienttype=8&channel=00000000000000000000000000000000&version=7.0.1.1&channel=0&version_app=7.0.1.1&origin=dlna&channel=chunlei&type=nolimit&sh=1"
	local uip4 = { "User-Agent: netdisk;P2SP;2.2.60.26" }
	table.insert(uip4, "Cookie: BDUSS="..uip2)
	local uip5 = json.decode(request(uip3,uip4))
	local uip6 = uip5.urls[1].url
	if string.find(uip6, "qdall") == nil then
	sign=0
	url1 = uip6
	task:setUris(url1)
	task:setOptions("user-agent", "netdisk;P2SP;2.2.60.26")
	task:setOptions("header", "Range:bytes=0-0")
	task:setOptions("piece-length", "1M")
	task:setOptions("min-split-size", "216K")
    task:setOptions("allow-piece-length-change", "true")
	task:setOptions("enable-http-pipelining", "false")
	task:setOptions("split", "16")
	task:setIcon("icon/svip.png", "高速下载中")
    return true
	end
	end
	end
	end
	task:setUris(url1)
	task:setOptions("user-agent", "netdisk;P2SP;2.2.60.26")
	task:setOptions("header", "Range:bytes=0-0")
	task:setOptions("piece-length", "1M")
	task:setOptions("min-split-size", "216K")
    task:setOptions("allow-piece-length-change", "true")
	task:setOptions("enable-http-pipelining", "false")
	task:setIcon("icon/acceleration2.png", "正在下载中")
	return true
end
	task:setOptions("header", "Range:bytes=0-0")
	task:setOptions("piece-length", "1M")
	task:setOptions("min-split-size", "216K")
    task:setOptions("allow-piece-length-change", "true")
	task:setOptions("enable-http-pipelining", "false")
	task:setIcon("icon/acceleration2.png", "正在下载中")
end

function onSearch(key, page)
if key ~= "set" then
if key ~= "appid" then
if key ~= "help" then
if key ~= "setkey" then
local appid = pd.input("请输入神秘代码 默认为250528")
pd.setConfig("Download","appid",appid)
return ACT_MESSAGE, "设置成功!当前APPID为"..appid
end
end
end
end
if key == "set" then
return setConfig()
end
if key == "appid" then
return setappid()
end
if key == "help" then
return help()
end
if key == "setkey" then
local keyss = pd.input("请输入key(没有key请到TG私聊机器人获取)")
pd.setConfig("ad","key",keyss)
return ACT_MESSAGE, "设置成功!当前key为"..keyss
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
	table.insert(config, createConfigItem("云账号接口(扫描账号可能需要一定时间)", "sharetype", "3",  sharetype == "3"))
	table.insert(config, createConfigItem("KD接口(扫描账号可能需要一定时间)", "sharetype", "4",  sharetype == "4"))
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
	table.insert(config, createConfigItem("受限账户", "appid", "778750&to=d0", appid == "778750&to=d0"))
	table.insert(config, createConfigItem("受限账户(会员推荐)", "appid", "250528&to=d0", appid == "250528&to=d0"))
	table.insert(config, createConfigItem("受限账户(如果下载403请选择这个)", "appid", "778750&type=svip&to=d0", appid == "778750&type=svip&to=d0"))
	table.insert(config, {["title"] = "输入help查看更多帮助", ["enabled"] = "false"})
	return config
end

function help()
local config = {}
table.insert(config, {["title"] = "PanDownload 无言修改版 TG频道:@fixpds TG群组:@fixpd", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入appid即可选择预设appid", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入set即可进行设置", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入help即可呼出帮助文档", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入setkey即可设置云账号key", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入其他内容即可自定义appid", ["enabled"] = "false"})
table.insert(config, {["title"] = "帮助文档 ver 1.0 修订 2020-11-13", ["enabled"] = "false"})
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









