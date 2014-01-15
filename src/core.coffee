WebDB = window.WebDB = {}

WebDB.init = (name, version, size=5242880, schema, callback) ->
  _websql     = WebDB.webSQL
  _indexeddb  = WebDB.indexedDB

  if window.openDatabase
    WebDB = _websql
  else if window.indexedDB
    WebDB = _indexeddb

  if not window.openDatabase and not window.indexedDB
    throw "HTML5 Databases not supported"

  WebDB.webSQL = _websql
  WebDB.indexedDB = _indexeddb
  WebDB.init name, version, size, schema, callback