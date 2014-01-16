class _webDB
  constructor: (@name, @version, @size=5242880, @schema, callback) ->
    if window.openDatabase
      db = new WebDB.webSQL(@name, @version, @size, @schema, callback)
    else if window.indexedDB
      db = new WebDB.indexedDB(@name, @version, @size, @schema, callback)

    if not window.openDatabase and not window.indexedDB
      select   = -> throw "HTML5 Databases not supported"
      insert   = -> throw "HTML5 Databases not supported"
      update   = -> throw "HTML5 Databases not supported"
      delete   = -> throw "HTML5 Databases not supported"
      drop     = -> throw "HTML5 Databases not supported"
      execute  = -> throw "HTML5 Databases not supported"
      throw "HTML5 Databases not supported"

    @select   = db.select
    @insert   = db.insert
    @update   = db.update
    @delete   = db.delete
    @drop     = db.drop
    @execute  = db.execute


WebDB = window.WebDB = _webDB