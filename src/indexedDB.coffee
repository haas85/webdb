class _indexedDB
  db: null

  constructor: (name, schema, version=1, callback) ->
    throw "IndexedDB not supported" if not window.indexedDB
    openRequest = indexedDB.open(dbName, version)
    openRequest.onsuccess = (e) =>
      @db = e.target.result
      for table in schema
        @db.createObjectStore table if not @db.objectStoreNames.contains table

      callback.call callback

    openRequest.onerror = (e) ->
      throw "Error opening database"


  select: (table, query=[], callback) ->
    result = []
    @db.transaction([table],"readonly").objectStore(table).openCursor().onsuccess = (e) ->
      cursor = e.target.result
      if cursor
        element = {}
        for key of cursor.value
          element[key] = cursor.value[key]
        result.push element if _check element, query
        cursor.continue()
      else
        callback.call callback, null, result

  insert: (table, data, callback) ->
    if _typeOf(data) is "object"
      _write table, data, "add", callback

  update: (options) -> ""
  delete: (options) -> ""
  drop: (options) -> ""
  execute: (options) -> ""

  _write = (table, data, operation, callback) ->
    store = @db.transaction([table],"readwrite").objectStore(table)
    request = store[operation] data, 1
    request.onerror = (e) ->
      callback.call callback, e, null

    request.onsuccess = (result) ->
      callback.call callback, null, result

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



  _typeOf = (obj) ->
    Object::.toString.call(obj).match(/[a-zA-Z] ([a-zA-Z]+)/)[1].toLowerCase()

WebDB.indexedDB = _indexedDB