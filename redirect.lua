local storage = require("storage")

local method = ngx.req.get_method()

if method ~= 'GET' then
  return ngx.exit(ngx.HTTP_NOT_ALLOWED)
end

local key = string.gsub(ngx.var.uri, "/", "",1)

local url = storage:get(key)

if url then
  ngx.log(ngx.INFO, "redirect url:", url)
  ngx.redirect(url, ngx.HTTP_MOVED_PERMANENTLY)
else
  ngx.exit(ngx.HTTP_NOT_FOUND)
end