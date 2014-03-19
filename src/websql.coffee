class webSQL
  db       : null
  _schema  = {}
  _this    = null

  constructor: (name, schema, version, size=5, callback) ->
    if callback? and not window.openDatabase
      return callback.call callback, "WebSQL not supported", null
    size = size * 1024 * 1024
    @db = window.openDatabase name, version, "", size
    _tables = 0
    for table of schema
      _schema[table] = {}
      sql = "CREATE TABLE IF NOT EXISTS #{table} ("
      for column of schema[table]
        if _typeOf(schema[table][column]) is "object"
          if schema[table][column]["autoincrement"]
            sql += "'#{column}' INTEGER"
          else
            sql += "'#{column}' #{schema[table][column]['type']}"
          sql += " PRIMARY KEY" if schema[table][column]["primary"]
          sql += " AUTOINCREMENT" if schema[table][column]["autoincrement"]
          sql += ","
          _schema[table][column] = schema[table][column]["type"]
        else
          sql += "'#{column}' #{schema[table][column]},"
          _schema[table][column] = schema[table][column]
      sql = sql.substring(0, sql.length - 1) + ")"
      _tables++
      _this = @
      @execute sql, (error, result) =>
        _tables--
        callback.call callback, error, @db if _tables is 0 and callback?


  select: (table, query=[], callback) ->
    try
      sql = "SELECT * FROM #{table}" + _queryToSQL(table, query)
      @execute sql, callback
    catch exception
      callback.call callback, exception, null if callback?

  insert: (table, data, callback) ->
    if _typeOf(data) is "object"
      _insert table, data, callback
    else
      len = data.length
      result = 0
      _error = []
      for row in data
        _insert table, row, (error, row) ->
          _error.push error if error?
          len--
          result++ if not error?
          if len is 0 and callback?
            _error = null if _error.length is 0
            callback.call callback, _error, result


  update: (table, data, query=[], callback) ->
    try
      sql = "UPDATE #{table} SET "
      for key of data
        sql += "#{key} = #{_setValue(table, key, data[key])}, "
      sql = sql.substring(0, sql.length - 2) + _queryToSQL(table, query)
      @execute sql, callback
    catch exception
      callback.call callback, exception, null if callback?

  delete: (table, query=[], callback) ->
    try
      sql = "DELETE FROM #{table} #{_queryToSQL(table, query)}"
      @execute sql, callback
    catch exception
      callback.call callback, exception, null if callback?

  drop: (table, callback) ->
    @execute "DROP TABLE IF EXISTS #{table}", (error, result) ->
      callback.call callback, error if callback?

  execute: (sql, callback) ->
    if not @db and callback?
      callback.call callback, "Database not initializated", null
    else
      @db.transaction (tx) ->
        tx.executeSql sql, [],
          ((transaction, resultset) ->
            result = []
            if sql.indexOf("SELECT") isnt -1
              result = (resultset.rows.item(i) for i in [0...resultset.rows.length])
              callback.call callback, null, result if callback?
            else
              callback.call callback, null, resultset.rowsAffected if callback?),
          (->
            callback.call callback, arguments[1], null if callback?)

  _insert = (table, row, callback) ->
    try
      sql = "INSERT INTO #{table} ("
      data = "("
      for key of row
        sql += "#{key}, "
        data += "#{_setValue(table, key, row[key])}, "
      sql = sql.substring(0, sql.length - 2) + ") "
      data = data.substring(0, data.length - 2) + ") "
      sql += " VALUES #{data}"
      _this.execute sql, callback
    catch exception
      callback.call callback, exception, null if callback?

  _queryToSQL = (table, query) ->
    if query.length > 0
      sql = " WHERE ("
      for elem in query
        for or_stmt of elem
          value = elem[or_stmt]
          sql += "#{or_stmt} = #{_setValue(table, or_stmt, value)} AND "
        sql = sql.substring(0, sql.length - 5) + ") OR ("
      sql.substring(0, sql.length - 5)
    else
      ""

  _setValue = (table, column, value) ->
    if _schema[table][column] is "NUMBER" then value else "'#{value}'"

WebDB.webSQL = webSQL