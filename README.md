## 数据库表结构

> 自定义 storage.lua 中的查询语句

## openresty 配置

```
worker_processes  1;
events {
    worker_connections 1024;
}
http {
    # $prefix 指 nginx 启动的 -p 路径, 也可以换成绝对路径
    lua_package_path '$prefix/?.lua;$prefix/conf/?.lua;$prefix/lib/?.lua;;';

    lua_code_cache on;

    server {
        listen 80;

        location ~ ^/([a-zA-Z0-9]+) {
            content_by_lua_file /path/redirect.lua;
        }
    }
}
```