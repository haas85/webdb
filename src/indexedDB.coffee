class _indexedDB
  db: null

  constructor: (name, schema, version=1, callback) ->
    throw "IndexedDB not supported" if not window.indexedDB
    openRequest = indexedDB.open(name, version)
    openRequest.onsuccess = (e) => @db = e.target.result

    openRequest.onerror = (e) -> throw "Error opening database"

    openRequest.onupgradeneeded = (e) =>
      @db = e.target.result
      for table in schema
        @db.createObjectStore table if not @db.objectStoreNames.contains table

      callback.call callback if callback?

    openRequest.onversionchange = (e) -> console.log e


  select: (table, query=[], callback) ->
    _queryOp db, table, null, query, callback

  insert: (table, data, callback) ->
    if _typeOf(data) is "object"
      _write table, data, callback
    else
      len = data.length
      for row in data
        _write table, data, () ->
          len--
          callback.call callback if len is 0  and callback?

  update: (table, data, query=[], callback) ->
    _queryOp db, table, data, query, callback

  delete: (options) -> ""

  drop: (table, callback) ->
    try
      @db.transaction([table],"readwrite").objectStore(table).delete()
      callback.call callback, null, true if callback?
    catch exception
     callback.call callback, exception, null if callback?

  execute: (options) -> ""

  _write = (table, data, callback) ->
    store = @db.transaction([table],"readwrite").objectStore(table)
    request = store.add data, 1
    request.onerror = (e) ->
      callback.call callback, e, null if callback?

    request.onsuccess = (result) ->
      callback.call callback, null, result if callback?

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
    db.transaction([table],"readonly").objectStore(table).openCursor().onsuccess = (e) ->
      cursor = e.target.result
      if cursor
        element = cursor.value
        if _check element, query
          if data?
            _mix element, data
            _mix cursor.value, data
            cursor.update cursor.value
          result.push element
        cursor.continue()
      else
        callback.call callback, null, result if callback?

  _mix = (receiver, emitter) -> receiver[key] = emitter[key] for key of emitter

  _typeOf = (obj) ->
    Object::.toString.call(obj).match(/[a-zA-Z] ([a-zA-Z]+)/)[1].toLowerCase()

WebDB.indexedDB = _indexedDB