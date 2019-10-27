dprint=dprint or function() end

syslog = {}
syslog.emergency = 0
syslog.alert = 1
syslog.critical = 2
syslog.error = 3
syslog.warning = 4
syslog.notice = 5
syslog.info = 6
syslog.debug = 7

setmetatable(syslog,{__call = function(_,msg, level, service)
 level, service = level or syslog.info, service or os.taskInfo(os.pid()).name or "unknown"
 dprint(string.format("syslog: [%s:%d/%d] %s",service,os.pid(),level,msg))
 computer.pushSignal("syslog",msg, level, service)
end})
