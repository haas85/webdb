class _webSQL
  db: null

  constructor: (name, version, size=5242880, schema, callback) ->
    throw "WebSQL not supported" if not window.openDatabase
    @db = openDatabase name, version, "", size
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


  select: (table, query=[], callback) ->
    sql = "SELECT * FROM #{table}"
    sql += _queryToSQL query
    @execute sql, callback

  insert: (table, data, callback) ->
    if _typeOf(data) is "object"
      _insert table, data, callback
    else
      len = data.length
      for row in data
        _insert table, row, () ->
          len--
          callback.call callback if len is 0


  update: (table, data, query=[], callback) ->
    sql = "UPDATE TABLE #{table} SET ("
    for key of data
      sql += "#{key} = #{_setValue(data[key])}, "
    sql = sql.substring(0, sql.length - 2) + ") " + _queryToSQL(query)
    @execute sql, callback

  remove: (options) -> ""

  drop: (table, callback) -> @execute "DROP TABLE IF EXISTS #{table}", callback

  execute: (sql, callback) ->
    if not @db
      throw "Database not initializated"
    else
      @db.transaction (tx) -> tx.executeSql(sql, callback)

  _insert = (table, row, callback) ->
    sql = "INSERT INTO #{table} ("
    data = "("
    for key of row
      sql += "#{key}, "
      data += "#{_setValue(row[key])}, "
    sql = sql.substring(0, sql.length - 2) + ") "
    data = data.substring(0, data.length - 2) + ") "
    sql += " VALUES #{data}"
    @execute sql, callback

  _queryToSQL = (query) ->
    if query.length > 0
      sql = " WHERE ("
      for elem in query
        for or_stmt of elem
          value = elem[or_stmt]
          sql += "#{or_stmt} = #{_setValue(value)} OR "
        sql = sql.substring(0, sql.length - 4) + ") AND ("
      sql.substring(0, sql.length - 6)
    else
      ""

  _setValue = (value) -> if isNaN(value) then "'#{value}'" else value

  _typeOf = (obj) ->
    Object::.toString.call(obj).match(/[a-zA-Z] ([a-zA-Z]+)/)[1].toLowerCase()

WebDB.webSQL = _webSQL