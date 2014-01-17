class _webDB
  db: null
  manager = null
  constructor: (@name, @schema, @version, @size=5242880, callback) ->
    if window.openDatabase
      manager = new WebDB.webSQL(@name, @schema, @version, @size, callback)
    else if window.indexedDB
      @schema = (key for key of @schema)
      manager = new WebDB.indexedDB(@name, @schema, @version, callback)

    if not window.openDatabase and not window.indexedDB
      @select   = -> throw "HTML5 Databases not supported"
      @insert   = -> throw "HTML5 Databases not supported"
      @update   = -> throw "HTML5 Databases not supported"
      @delete   = -> throw "HTML5 Databases not supported"
      @drop     = -> throw "HTML5 Databases not supported"
      @execute  = -> throw "HTML5 Databases not supported"
      throw "HTML5 Databases not supported"

    @db       = manager.db
    @select   = manager.select
    @insert   = manager.insert
    @update   = manager.update
    @delete   = manager.delete
    @drop     = manager.drop
    @execute  = manager.execute


WebDB = window.WebDB = _webDB

_mix = (receiver, emitter) -> receiver[key] = emitter[key] for key of emitter

_typeOf = (obj) ->
  Object::.toString.call(obj).match(/[a-zA-Z] ([a-zA-Z]+)/)[1].toLowerCase()