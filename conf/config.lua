return {
  redis = {
    host = "127.0.0.1",
    port = 6379,
    timeout = 1000,
    db_index = 0,
    password = nil
  },
  mysql = {
    timeout = 5000,
    connect_config = {
      host = "127.0.0.1",
      port = 3306,
      database = "short_url",
      user = "root",
      password = "root",
      charset = "utf8",
      max_packet_size = 1024 * 1024,
    },
    pool_config = {
      max_idle_timeout = 10000,
      pool_size = 3
    },
  }
}