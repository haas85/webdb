class indexedDB
  db       : null
  version  : 0
  schema   : ""
  name     : ""

  VERSION_KEY: "indexedDB_version"
  SCHEMA_KEY : "indexedDB_schema"

  constructor: (name, schema, version=1, callback) ->
    if not window.indexedDB and callback?
      return callback.call callback, "IndexedDB not supported", null
    @VERSION_KEY += "_#{name}"
    @SCHEMA_KEY  += "_#{name}"
    @version = parseInt localStorage[@VERSION_KEY]
    if not @version? or @version < version or isNaN(@version)
      localStorage[@VERSION_KEY] = @version = parseInt version
    @schema = localStorage[@SCHEMA_KEY]
    _schema = JSON.stringify(schema)
    if @schema? and @schema isnt _schema
      localStorage[@SCHEMA_KEY] = @schema = _schema
      localStorage[@VERSION_KEY] = @version += 1
    else
      localStorage[@SCHEMA_KEY] = @schema = _schema
    @name = name
    openRequest = window.indexedDB.open(name, @version)
    openRequest.onsuccess = (e) =>
      @db = e.target.result
      callback.call callback, null, @db if callback?

    openRequest.onerror = (error) ->
      callback.call callback, error, null if callback?

    openRequest.onupgradeneeded = (e) =>
      @db = e.target.result
      for table of schema
        options = {}
        for column of schema[table]
          if _typeOf(schema[table][column]) is "object"
            options["keyPath"] = column if schema[table][column]["primary"]
            if schema[table][column]["autoincrement"]
              options["autoIncrement"] = true
        if not options.keyPath?
          options = keyPath: "__key", autoIncrement: true
        @db.createObjectStore table, options if not @db.objectStoreNames.contains table

    openRequest.onversionchange = (e) ->
      console.log e

  select: (table, query=[], callback) -> _queryOp @db, table, null, query, callback

  insert: (table, data, callback) ->
    if _typeOf(data) is "object"
      _write @, table, data, callback
    else
      len = data.length
      _result = 0
      _error = []
      for row in data
        _write @, table, row, (error, result) ->
          _result++ if not error?
          _error.push error if error?
          len--
          if len is 0  and callback?
            _error = null if _error.length is 0
            callback.call callback, _error, _result

  update: (table, data, query=[], callback) ->
    _queryOp @db, table, data, query, (error, result) ->
      callback.call callback, error, result.length if callback?

  delete: (table, query=[], callback) ->
    try
      result = 0
      store = @db.transaction([table],"readwrite").objectStore(table)
      transaction = store.openCursor()
      transaction.onsuccess = (e) ->
        cursor = e.target.result
        if cursor
          element = cursor.value
          if _check element, query
            result++
            store.delete cursor.primaryKey
          do cursor.continue
        else
          callback.call callback, null, result if callback?
      transaction.onerror = (error) ->
        callback.call callback, error, null if callback?
    catch exception
      callback.call callback, exception, null if callback?

  drop: (table, callback) ->
    try
      @db.close()
      @version += 1
      localStorage[@VERSION_KEY] = @version
      openRequest = window.indexedDB.open(@name, @version)
      openRequest.onsuccess = (e) =>
        @db = e.target.result
      openRequest.onupgradeneeded = (e) =>
        @db = e.target.result
        @db.deleteObjectStore table
        _schema = JSON.parse @schema
        `delete _schema[table]`
        @schema = localStorage[@SCHEMA_KEY] = JSON.stringify _schema
        callback.call callback, null if callback?
      openRequest.onerror = (error) ->
        callback.call callback, error if callback?
    catch exception
     callback.call callback, exception if callback?

  execute: (sql, callback) ->
    callback.call callback, "Execute not supported" if callback?

  _write = (_this, table, data, callback) ->
    store = _this.db.transaction([table],"readwrite").objectStore(table)
    request = store.add data
    request.onerror = (error) ->
      callback.call callback, error, null if callback?

    request.onsuccess = (result) ->
      callback.call callback, null, 1 if callback?

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
    transaction = db.transaction([table], op).objectStore(table).openCursor()
    transaction.onsuccess = (e) ->
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
        callback.call callback, null, result if callback?
    transaction.onerror = (error) ->
      callback.call callback, error, null if callback?

WebDB.indexedDB = indexedDB