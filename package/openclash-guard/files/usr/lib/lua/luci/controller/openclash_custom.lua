module("luci.controller.openclash_custom", package.seeall)

function index()
  entry({"admin", "services", "openclash_custom"}, call("action_index"), _("OpenClash 守护"), 89).dependent = false
end

function action_index()
  local http = require "luci.http"
  http.prepare_content("text/html")

  -- 状态读取
  local status_file = io.open("/tmp/openclash_status", "r")
  local guard_status = status_file and status_file:read("*l") or "未知"
  if status_file then status_file:close() end

  local clash_running = (os.execute("pidof clash > /dev/null") == 0) and "运行中 ✅" or "未运行 ❌"
  local watchdog_running = (os.execute("pgrep -f openclash_watchdog.sh > /dev/null") == 0) and "运行中 ✅" or "未运行 ❌"

  -- 操作反馈
  local result_message = ""
  local refresh_tag = ""
  local log_title = ""

  local action = http.formvalue("action")

  if action == "stop" then
    os.execute("echo off > /tmp/openclash_status &")
    os.execute("killall openclash_watchdog.sh &")
    os.execute("/etc/init.d/openclash stop &")
    result_message = "🛑 OpenClash 已关闭，守护已停止。"
  elseif action == "start" then
    os.execute("echo on > /tmp/openclash_status &")
    os.execute("/etc/init.d/openclash start &")
    os.execute("/root/openclash_launcher.sh &")
    result_message = "🔄 OpenClash 守护已启动。"
  elseif action == "log" then
    local log_path = "/tmp/openclash_watchdog_debug.log"
    local f = io.open(log_path, "r")
    if f then
      result_message = "<pre>" .. f:read("*a") .. "</pre>"
      f:close()
    else
      result_message = "📄 日志文件不存在或尚未生成。"
    end

    if watchdog_running then
      refresh_tag = '<meta http-equiv="refresh" content="5">'
      log_title = "📄 OpenClash 守护日志（每 5 秒自动刷新）"
    else
      log_title = "📄 OpenClash 守护日志（已停止刷新）"
    end
  end

  -- 页面输出
  http.write([[
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>📊 OpenClash 守护状态监控</title>
      ]] .. refresh_tag .. [[
      <style>
        body { font-family: sans-serif; padding: 20px; }
        .status, .result { margin-top: 20px; padding: 10px; border: 1px solid #ccc; background: #f9f9f9; }
        .status strong, .result strong { color: #007acc; }
        input[type=submit] { margin-right: 10px; padding: 8px 16px; }
        pre { background: #fff; padding: 10px; border: 1px solid #ccc; overflow-x: auto; }
      </style>
    </head>
    <body>
      <h2>📊 OpenClash 守护状态监控</h2>
    <form method="get">
      <button type="submit" name="action" value="stop">🛑 强制关闭 OpenClash 及守护</button>
      <button type="submit" name="action" value="start">🔄 手动开启 OpenClash 及守护</button>
      <button type="submit" name="action" value="log">📄 OpenClash 守护日志</button>
    </form>
    <div class="status">
        <p><strong>当前守护状态：</strong> ]] .. guard_status .. [[</p>
        <p><strong>Clash 运行状态：</strong> ]] .. clash_running .. [[</p>
        <p><strong>守护脚本状态：</strong> ]] .. watchdog_running .. [[</p>
      </div>
      <div class="result">
        <p><strong>操作反馈：</strong></p>
        ]] .. (log_title ~= "" and "<h3>" .. log_title .. "</h3>" or "") .. result_message .. [[
      </div>
    </body>
    </html>
  ]])
end
