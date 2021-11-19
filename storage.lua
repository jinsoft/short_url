local mysql = require("mysql_db")
local redis = require("redis_db")
local config = require("config")

local _M = {
  _base_key = "shorturl::"
}


local function select_mysql(key)
  local db = mysql:new(config.mysql)
  -- 查询长网址的sql
  local sql = "SELECT value FROM shorturl where `key`= %s limit 1"
  local res, err ,errcode, sqlstate = db:select(sql, key)
  if not res or err then
    ngx.log(ngx.ERR, "mysql select faild:" .. tostring(err))
    return nil
  elseif res[1] then
    return res[1].value
  end
end

local function set_redis(key, value)
  local rc = redis:new(config.redis)
  local res, _ = rc:set(key, value)
  ngx.log(ngx.DEBUG, 'set redis key:' .. key .. ':' .. tostring(value))
  if not res then
    ngx.log(ngx.ERR, "redis connection error")
    return nil
  end
  return res
end

function _M:_redis_key(key)
  return self._base_key .. key
end

function _M:get(key)
  -- 先从redis里面查
  local redis_key = self:_redis_key(key)
  local rc = redis:new(config.redis)
  local res,err = rc:get(redis_key)
  ngx.log(ngx.DEBUG, 'get redis key :' .. key .. ':' .. tostring(res))
  if res then
    return res
  end

  -- redis没有则从数据库查询
  res = select_mysql(key)
  if not res then
    return nil
  end

  set_redis(redis_key, res)
  return res
end

return _M