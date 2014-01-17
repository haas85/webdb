class _webDB
  constructor: (@name, @schema, @version, @size=5242880, callback) ->
    if window.openDatabase
      db = new WebDB.webSQL(@name, @schema, @version, @size, callback)
    else if window.indexedDB
      @schema = (key for key of @schema)
      db = new WebDB.indexedDB(@name, @schema, @version, callback)

    if not window.openDatabase and not window.indexedDB
      @select   = -> throw "HTML5 Databases not supported"
      @insert   = -> throw "HTML5 Databases not supported"
      @update   = -> throw "HTML5 Databases not supported"
      @delete   = -> throw "HTML5 Databases not supported"
      @drop     = -> throw "HTML5 Databases not supported"
      @execute  = -> throw "HTML5 Databases not supported"
      throw "HTML5 Databases not supported"

    @select   = db.select
    @insert   = db.insert
    @update   = db.update
    @delete   = db.delete
    @drop     = db.drop
    @execute  = db.execute


WebDB = window.WebDB = _webDB

_mix = (receiver, emitter) -> receiver[key] = emitter[key] for key of emitter

_typeOf = (obj) ->
  console.log "TYPEOF"
  Object::.toString.call(obj).match(/[a-zA-Z] ([a-zA-Z]+)/)[1].toLowerCase()
class _indexedDB
  db: null

  constructor: (name, schema, version=1, callback) ->
    throw "IndexedDB not supported" if not window.indexedDB
    openRequest = indexedDB.open(name, version)
    openRequest.onsuccess = (e) =>
      @db = e.target.result
      callback.call callback if callback?

    openRequest.onerror = (e) -> throw "Error opening database"

    openRequest.onupgradeneeded = (e) =>
      @db = e.target.result
      options = keyPath: "key", autoIncrement: true
      for table in schema
        @db.createObjectStore table, options if not @db.objectStoreNames.contains table

    openRequest.onversionchange = (e) -> console.log e

  select: (table, query=[], callback) -> _queryOp @db, table, null, query, callback

  insert: (table, data, callback) ->
    if _typeOf(data) is "object"
      _write @, table, data, callback
    else
      len = data.length
      for row in data
        _write @, table, row, () ->
          len--
          callback.call callback, data.length if len is 0  and callback?

  update: (table, data, query=[], callback) ->
    _queryOp @db, table, data, query, (result) ->
      callback.call callback, result.length if callback?

  delete: (table, query=[], callback) ->
    try
      result = 0
      store = @db.transaction([table],"readwrite").objectStore(table)
      store.openCursor().onsuccess = (e) ->
        cursor = e.target.result
        if cursor
          element = cursor.value
          if _check element, query
            result++
            store.delete cursor.primaryKey
            do cursor.continue
      callback.call callback, result if callback?
    catch exception
     callback.call callback if callback?

  drop: (table, callback) ->
    try
      store = @db.transaction([table],"readwrite").objectStore(table)
      store.openCursor().onsuccess = (e) ->
        cursor = e.target.result
        if cursor
          store.delete cursor.primaryKey
          do cursor.continue
      # to drop completely, a version change must be executed
      callback.call callback if callback?
    catch exception
     callback.call callback if callback?

  execute: (options) -> ""

  _write = (_this, table, data, callback) ->
    store = _this.db.transaction([table],"readwrite").objectStore(table)
    request = store.add data
    request.onerror = (e) ->
      callback.call callback, null if callback?

    request.onsuccess = (result) ->
      callback.call callback, 1 if callback?

  _check = (element, query=[]) ->
    return true if query.length is 0
    for stmt in query
      result = true
      for key of stmt
        if element[key] isnt stmt[key]
          result = false
          break
      if result is true
        return true
    return false

  _queryOp = (db, table, data, query=[], callback) ->
    result = []
    op = if data? then "readwrite" else "readonly"
    db.transaction([table], op).objectStore(table).openCursor().onsuccess = (e) ->
      cursor = e.target.result
      if cursor
        element = cursor.value
        if _check element, query
          if data?
            _mix element, data
            _mix cursor.value, data
            cursor.update cursor.value
          result.push element
        do cursor.continue
      else
        callback.call callback, result if callback?

WebDB.indexedDB = _indexedDB
class _webSQL
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

WebDB.webSQL = _webSQL