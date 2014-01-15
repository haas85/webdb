class _webDB
  @db = null

  constructor: (@name, @version, @size=5242880, @schema, callback) ->
    if window.openDatabase
      @db = new WebDB.webSQL(@name, @version, @size, @schema, callback)
    else if window.indexedDB
      @db = new WebDB.indexedDB(@name, @version, @size, @schema, callback)

    if not window.openDatabase and not window.indexedDB
      throw "HTML5 Databases not supported"

  select   : @db.select
  insert   : @db.insert
  update   : @db.update
  remove   : @db.remove
  drop     : @db.drop
  execute  : @db.execute


WebDB = window.WebDB = _webDB