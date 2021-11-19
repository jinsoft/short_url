local DB={}
local mysql = require "resty.mysql"
local ngx_quote_sql_str = ngx.quote_sql_str


function DB:new(conf)
  local instance = {}
  instance.conf = conf
  setmetatable(instance, { __index = self})
  return instance
end

function DB:exec(sql)
  local conf = self.conf
  local db,err = mysql:new()
  if not db then
    ngx.log(ngx.ERR, "failed to instantiate mysql: ", err)
  end

  db:set_timeout(conf.timeout) -- 1000 = 1 sec

  local ok, err, errcode, sqlstate = db:connect(conf.connect_config)

  if not ok then
      ngx.log(ngx.ERR, "failed to connect: ", err, ": ", errcode, " ", sqlstate)
      return
  end

  local times, _ = db:get_reused_times()
  if times == 0 then
    db:query("SET NAMES utf8")
  end

  ngx.log(ngx.INFO, "connected to mysql. reused_times:", times)

  ngx.say("sql", sql)
  local res, _, errcode, sqlstate = db:query(sql)
  if not res then
      ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
      ngx.log(ngx.ERR, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
  end

  local ok, _ = db:set_keepalive(conf.pool_config.max_idle_timeout, conf.pool_config.pool_size)
  if not ok then
    ngx.log(ngx.ERR, "failed to set keepalive: ", err)
  end
  return res, err, errcode, sqlstate
end

function DB:parse_sql(sql, params)
  if not params or #params == 0 then
    return sql
  end
  if type(params) == "string" then
    return string.format(sql, ngx_quote_sql_str(params))
  end
  ngx.log(ngx.ERR, "parse sql error", tostring(params))
  return nil
end

function DB:query(sql, params)
  sql = self:parse_sql(sql, params)
  if sql == nil then
    return nil
  end
  return self:exec(sql)
end

function DB:select(sql, params)
  return self:query(sql, params)
end

return DB