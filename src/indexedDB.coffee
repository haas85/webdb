class indexedDB
  db       : null

  constructor: (name, schema, version=1, callback) ->
    throw "IndexedDB not supported" if not window.indexedDB
    openRequest = window.indexedDB.open(name, version)
    openRequest.onsuccess = (e) =>
      @db = e.target.result
      callback.call callback if callback?

    openRequest.onerror = (e) -> throw "Error opening database"

    openRequest.onupgradeneeded = (e) =>
      @db = e.target.result
      options = keyPath: "key", autoIncrement: true
      for table in schema
        @db.createObjectStore table, options if not @db.objectStoreNames.contains table

    openRequest.onversionchange = (e) ->
      console.log e

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
        else
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

  execute: (sql, callbacl) -> ""

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

WebDB.indexedDB = indexedDB