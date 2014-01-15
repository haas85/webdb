WebDB.webSQL = do ->
  _db = null

  init     = (name, version, size=5242880, schema, callback) ->
    _db = openDatabase name, version, "", size
    _tables = 0
    for table of schema
      sql = "CREATE TABLE IF NOT EXISTS #{table} ("
      for row of schema[table]
        sql += "#{row} #{schema[table][row]},"
      sql = sql.substring(0, sql.length - 1)
      sql += ")"
      _tables++
      execute sql, ->
        tables--
        callback.call callback if tables is 0


  select   = (options) -> ""
  insert   = (options) -> ""
  update   = (options) -> ""
  remove   = (options) -> ""
  drop     = (options) -> ""
  execute  = (sql, callback) ->
    if not _db
      throw "Database not initializated"
    else
      _db.transaction (tx) -> tx.executeSql(sql, callback)


  init      : init
  select    : select
  insert    : insert
  update    : update
  remove    : remove
  drop      : drop
  execute   : execute