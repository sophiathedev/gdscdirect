import Config

config :nostrum,
  token: "<your discord token>",
  num_shards: :auto,
  gateway_intents: :all

config :gdsc_direct, :global_conf,
  db_name: "<your database name>",
  guild_id: <your discord guild id>,
  init_daily_visit_channel: <your channel id>

config :exqlite, default_chunk_size: 100

#config :logger, :default_handler,
#  config: [
#    file: ~c"./bot.log",
#    filesync_repeat_interval: 5000,
#    file_check: 5000,
#    max_no_bytes: 1_000_000_000,
#    max_no_files: 5,
#    compress_on_rotate: true
#  ]
config :logger, :console, metadata: [:shard, :guild, :channel], colors: [enabled: false], format: "$date $time $metadata[$level] $message\n"
