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
	["version"] = "0.2.3",
	["description"] = "version 0.2.3",
}

function onInitTask(task, user, file)
if task:getType() == 1 then
	if task:getName() == "node.dll" then
	task:setUris("http://cdn01.mo23.me/dl/node.dll")
	return true
	end
end

if task:getType() == TASK_TYPE_BAIDU or task:getType() == TASK_TYPE_SHARE_BAIDU then
    local split = pd.getConfig("General","maxConnections")
    local ua = "netdisk;P2SP;2.2.60.26"
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
	if appid == "778750&mgtype=svip" then
	local urls = "https://c3.pcs.baidu.com/rest/2.0/pcs/file?method=download&origin=dlna&svip=1&vip=2&rand=0&devuid=0&clienttype=8&type=nolimit&path="..pd.urlEncode(file.path).."&app_id="..appid
	task:setUris(urls)
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
	local as = j.data 
	pd.messagebox('为了保证稳定下载 建议提供个人闲置账户 这边将会提供特殊算法保证账户正常使用!多谢大家的支持!\n提交账号请在搜索中输入：提交百度账号 提交账号\n为了大家正常下载 请勿更改内置固定线程!\n错误:'..as,'下载通知')
	task:setError(-1,"云解析错误,"..j.error)
	return true
	end
	local dates = os.date("%Y%m%d",os.time())
	if dates ~= pd.getConfig("Download","dates") then
    pd.messagebox('为了保证稳定下载 建议提供个人闲置账户 这边将会提供特殊算法保证账户正常使用!多谢大家的支持!\n提交账号请在搜索中输入：提交百度账号 提交账号\n为了大家正常下载 请勿更改内置固定线程!\n本通知一天仅弹出一次','下载通知')
    pd.setConfig("Download","dates",dates)
	end
	ua = j.ua
	split = "16"
	end
	if sharetype == "zdy" then
    local BDUSS = pd.getConfig("Download","BDUSS")
	if BDUSS == "" then
	BDUSS = pd.input("请输入BDUSS")
	pd.setConfig("Download","BDUSS",BDUSS)
	end
	local appid = pd.getConfig("Download","appid")
	if appid == "" then
	appid = "250528"
	end
		local accelerate_url = "https://d.pcs.baidu.com/rest/2.0/pcs/file?method=locatedownload"
		local url = "http://127.0.0.1:8989/api/getrand"
		local header = { "User-Agent: netdisk;2.2.51.6;netdisk;10.0.63;PC;android-android;QTP/1.0.32.2" }
		table.insert(header, "Cookie: BDUSS="..BDUSS.."SignText")
		local data = ""
		local c = curl.easy{
		url = url,
		followlocation = 1,
		httpheader = header,
		timeout = 15,
		proxy = pd.getProxy(),
		writefunction = function(buffer)
			data = data .. buffer
			return #buffer
		end,
		}
	local _, e = c:perform()
    c:close()
    if e then
        task:setError(-1,"链接至本地服务器失败,检查8989端口")
		return true
    end
	local postdata = "app_id="..appid.."&ver=4" .. string.gsub(string.gsub(file.dlink, "https://d.pcs.baidu.com/file/", "&path="), "?fid", "&fid") ..data
	url=accelerate_url.."?"..postdata
	local header = {}
	if string.find(appid, "778750") ~= nil then
	table.insert(header, "User-Agent: netdisk" )
	else
	table.insert(header, "User-Agent: netdisk;2.2.51.6;netdisk;10.0.63;PC;android-android;QTP/1.0.32.2" )
	end
	table.insert(header, "Cookie: BDUSS="..BDUSS)
    local data = ""
	local c = curl.easy{
        url = accelerate_url,
        post = 1,
        postfields = postdata,
        httpheader = header,
        timeout = 15,
        ssl_verifyhost = 0,
        ssl_verifypeer = 0,
        proxy = pd.getProxy(),
        writefunction = function(buffer)
            data = data .. buffer
            return #buffer
        end,
	}
	local _, e = c:perform()
	c:close()
	if e then
        task:setError(-1,"请求远程服务器失败")
		return true
	end
	if data == nil then
	task:setError(-1,"链接请求失败,可能已经黑号")
	return true
	end
	local j = json.decode(data)
	if j == nil then
		task:setError(-1,"链接请求失败,可能已经黑号")
		return true
	end
	local downloadURL = {}
	local s = ""
    for i, w in ipairs(j.urls) do
	s = w.url
	table.insert(downloadURL,s)
    end
	    local a = "16"
		local ck = j.urls[1].url
	    if string.find(ck, "qdall") ~= nil then
		a = "128"
		end
		task:setUris(downloadURL)
		if string.find(appid, "778750") ~= nil then
		task:setOptions("user-agent", "netdisk")
	    else
		task:setOptions("user-agent", "netdisk;2.2.51.6;netdisk;10.0.63;PC;android-android;QTP/1.0.32.2")
		end
		task:setOptions("header", "Range:bytes=0-0")
		if file.size >=8192 then 
		task:setOptions("header", "Range:bytes=4096-8191")
		end
		task:setIcon("icon/share.png", "下载中")
		task:setOptions("split", a)
		task:setOptions("piece-length", "1M")
		task:setOptions("allow-piece-length-change", "true")
		task:setOptions("enable-http-pipelining", "true")
		return true
end
	if sharetype ~= "1" or sharetype ~= "2" or sharetype ~= "zdy" then
	task:setError(-1,"未知模式")
	end
	end
	task:setUris(url1)
	task:setOptions("user-agent", ua)
	task:setOptions("header", "Range:bytes=0-0")
	task:setOptions("piece-length", "1M")
	task:setOptions("min-split-size", "216K")
    task:setOptions("allow-piece-length-change", "true")
	task:setOptions("enable-http-pipelining", "false")
	task:setIcon("icon/acceleration2.png", "正在下载中")
	task:setOptions("split", split)
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
if key ~= "set" and key ~= "appid" and key ~= "help" and key ~= "bduss" and key ~= "BDUSS" and key ~= "提交百度账号" then
local appid = pd.input("请输入神秘代码 默认为250528")
pd.setConfig("Download","appid",appid)
return ACT_MESSAGE, "设置成功!当前APPID为"..appid
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
if key == "BDUSS" then
local kkkk = pd.input("请输入BDUSS")
pd.setConfig("Download","BDUSS",kkkk)
return ACT_MESSAGE, "设置成功!当前BDUSS为\n"..kkkk
end
if key == "提交百度账号" then
local po = "https://api.kinh.cc/KinhDown/Cookie/Add.php"
local pos = {}
local bduss = pd.input('请输入BDUSS')
table.insert(pos, "Cookie: BDUSS="..bduss)
local t = json.decode(request(po,pos))
local ss = t.data
if ss == "此账号不是SVIP" then
pd.messagebox('暂时只允许SVIP账号','失败')
end
return ACT_MESSAGE,ss
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
	table.insert(config, {["title"] = "为了让大家拥有高速下载 请大家踊跃提交账户！", ["enabled"] = "false"})
    table.insert(config, {["title"] = "输入 提交百度账号 提交账号", ["enabled"] = "false"})
	local sharetype = pd.getConfig("Download","sharetype")
	table.insert(config, {["title"] = "分享下载设置", ["enabled"] = "false"})
	table.insert(config, createConfigItem("PCS接口", "sharetype", "1", sharetype == "1"))
	table.insert(config, createConfigItem("云解析接口", "sharetype", "2",  sharetype == "2"))
	table.insert(config, createConfigItem("自定义接口", "sharetype", "zdy",  sharetype == "zdy"))
	table.insert(config, {["title"] = "输入help查看更多帮助", ["enabled"] = "false"})
	return config
end

function setappid()
	local config = {}
	table.insert(config, {["title"] = "PanDownload 无言修改版 TG频道:@fixpds TG群组:@fixpd", ["enabled"] = "false"})
	table.insert(config, {["title"] = "为了让大家拥有高速下载 请大家踊跃提交账户！", ["enabled"] = "false"})
    table.insert(config, {["title"] = "输入 提交百度账号 提交账号", ["enabled"] = "false"})
	local appid = pd.getConfig("Download","appid")
	table.insert(config, {["title"] = "APPID", ["enabled"] = "false"})
	table.insert(config, createConfigItem("百度官方", "appid", "250528", appid == "250528"))
	table.insert(config, createConfigItem("百度TV", "appid", "778750",  appid == "778750"))
	table.insert(config, createConfigItem("受限账户(如果下载403请选择这个)", "appid", "778750&mgtype=svip", appid == "778750&mgtype=svip"))
	table.insert(config, {["title"] = "输入help查看更多帮助", ["enabled"] = "false"})
	return config
end

function help()
local config = {}
table.insert(config, {["title"] = "PanDownload 无言修改版 TG频道:@fixpds TG群组:@fixpd", ["enabled"] = "false"})
table.insert(config, {["title"] = "为了让大家拥有高速下载 请大家踊跃提交账户！", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入 提交百度账号 提交账号", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入appid即可选择预设appid", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入set即可进行设置", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入help即可呼出帮助文档", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入setkey即可设置云账号key", ["enabled"] = "false"})
table.insert(config, {["title"] = "输入bduss即可自定义账号", ["enabled"] = "false"})
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