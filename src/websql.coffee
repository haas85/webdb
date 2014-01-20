class webSQL
  db: null
  _this = null

  constructor: (name, schema, version, size=5, callback) ->
    throw "WebSQL not supported" if not window.openDatabase
    size = size * 1024 * 1024
    @db = openDatabase name, version, "", size
    _tables = 0
    for table of schema
      sql = "CREATE TABLE IF NOT EXISTS #{table} ("
      for row of schema[table]
        sql += "#{row} #{schema[table][row]},"
      sql = sql.substring(0, sql.length - 1) + ")"
      _tables++
      _this = @
      @execute sql, ->
        _tables--
        callback.call callback if _tables is 0 and callback?


  select: (table, query=[], callback) ->
    sql = "SELECT * FROM #{table}" + _queryToSQL(query)
    @execute sql, callback

  insert: (table, data, callback) ->
    if _typeOf(data) is "object"
      _insert table, data, callback
    else
      len = data.length
      result = 0
      for row in data
        _insert table, row, (row) ->
          len--
          result++
          callback.call callback, result if len is 0 and callback?


  update: (table, data, query=[], callback) ->
    sql = "UPDATE #{table} SET "
    for key of data
      sql += "#{key} = #{_setValue(data[key])}, "
    sql = sql.substring(0, sql.length - 2) + _queryToSQL(query)
    @execute sql, callback

  delete: (table, query=[], callback) ->
    sql = "DELETE FROM #{table} #{_queryToSQL(query)}"
    @execute sql, callback

  drop: (table, callback) -> @execute "DROP TABLE IF EXISTS #{table}", callback

  execute: (sql, callback) ->
    if not @db
      throw "Database not initializated"
    else
      @db.transaction (tx) ->
        tx.executeSql sql, [], (transaction, resultset) ->
          result = []
          if sql.indexOf("SELECT") isnt -1
            result = (resultset.rows.item(i) for i in [0...resultset.rows.length])
            callback.call callback, result if callback?
          else
            callback.call callback, resultset.rowsAffected if callback?

  _insert = (table, row, callback) ->
    sql = "INSERT INTO #{table} ("
    data = "("
    for key of row
      sql += "#{key}, "
      data += "#{_setValue(row[key])}, "
    sql = sql.substring(0, sql.length - 2) + ") "
    data = data.substring(0, data.length - 2) + ") "
    sql += " VALUES #{data}"
    _this.execute sql, callback

  _queryToSQL = (query) ->
    if query.length > 0
      sql = " WHERE ("
      for elem in query
        for or_stmt of elem
          value = elem[or_stmt]
          sql += "#{or_stmt} = #{_setValue(value)} AND "
        sql = sql.substring(0, sql.length - 5) + ") OR ("
      sql.substring(0, sql.length - 5)
    else
      ""

  _setValue = (value) -> if isNaN(value) then "'#{value}'" else value

WebDB.webSQL = webSQL