do
syslog = {}
syslog.emergency = 0
syslog.alert = 1
syslog.critical = 2
syslog.error = 3
syslog.warning = 4
syslog.notice = 5
syslog.info = 6
syslog.debug = 7

local rdprint=dprint or function() end
setmetatable(syslog,{__call = function(_,msg, level, service)
 level, service = level or syslog.info, service or (os.taskInfo(os.pid()) or {}).name or "unknown"
 rdprint(string.format("syslog: [%s:%d/%d] %s",service,os.pid(),level,msg))
 computer.pushSignal("syslog",msg, level, service)
end})
function dprint(...)
 for k,v in pairs({...}) do
  syslog(v,syslog.debug)
 end
end
end
