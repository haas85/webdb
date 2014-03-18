window.indexedDB = window.indexedDB or window.webkitIndexedDB or window.mozIndexedDB

class webDB
  db       : null
  constructor: (@name, @schema, @version, @size=5242880, callback) ->
    if window.indexedDB
      manager = new WebDB.indexedDB(@name, @schema, @version, callback)
    else if window.openDatabase
      manager = new WebDB.webSQL(@name, @schema, @version, @size, callback)

    if not window.openDatabase and not window.indexedDB
      @select = (table, query, callback) ->
        callback.call callback, "HTML5 Databases not supported", null if callback?
      @insert = (table, data, callback) ->
        callback.call callback, "HTML5 Databases not supported", null if callback?
      @update = (table, data, query=[], callback) ->
        callback.call callback, "HTML5 Databases not supported", null if callback?
      @delete = (table, query, callback) ->
        callback.call callback, "HTML5 Databases not supported", null if callback?
      @drop = (table, callback) ->
        callback.call callback, "HTML5 Databases not supported", null if callback?
      @execute = (sql, callback) ->
        callback.call callback, "HTML5 Databases not supported", null if callback?
    else
      @db       = manager.db
      @select   = -> manager.select.apply manager, arguments
      @insert   = -> manager.insert.apply manager, arguments
      @update   = -> manager.update.apply manager, arguments
      @delete   = -> manager.delete.apply manager, arguments
      @drop     = -> manager.drop.apply manager, arguments
      @execute  = -> manager.execute.apply manager, arguments


WebDB = window.WebDB = webDB

_mix = (receiver, emitter) -> receiver[key] = emitter[key] for key of emitter

_typeOf = (obj) ->
  Object::.toString.call(obj).match(/[a-zA-Z] ([a-zA-Z]+)/)[1].toLowerCase()