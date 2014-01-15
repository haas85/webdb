(function() {
  var WebDB;

  WebDB = window.WebDB = {};

  WebDB.init = function(name, version, size, schema, callback) {
    var _indexeddb, _websql;
    if (size == null) {
      size = 5242880;
    }
    _websql = WebDB.webSQL;
    _indexeddb = WebDB.indexedDB;
    if (window.openDatabase) {
      WebDB = _websql;
    } else if (window.indexedDB) {
      WebDB = _indexeddb;
    }
    if (!window.openDatabase && !window.indexedDB) {
      throw "HTML5 Databases not supported";
    }
    WebDB.webSQL = _websql;
    WebDB.indexedDB = _indexeddb;
    return WebDB.init(name, version, size, schema, callback);
  };

}).call(this);

(function() {
  WebDB.indexedDB = (function() {
    var drop, execute, init, insert, remove, select, update, _db;
    _db = null;
    init = function(name, version, size, schema, callback) {
      if (size == null) {
        size = 5242880;
      }
      return "";
    };
    select = function(options) {
      return "";
    };
    insert = function(options) {
      return "";
    };
    update = function(options) {
      return "";
    };
    remove = function(options) {
      return "";
    };
    drop = function(options) {
      return "";
    };
    execute = function(sql, callback) {
      return "";
    };
    return {
      init: init,
      select: select,
      insert: insert,
      update: update,
      remove: remove,
      drop: drop,
      execute: execute
    };
  })();

}).call(this);

(function() {
  WebDB.webSQL = (function() {
    var drop, execute, init, insert, remove, select, update, _db;
    _db = null;
    init = function(name, version, size, schema, callback) {
      var row, sql, table, _results, _tables;
      if (size == null) {
        size = 5242880;
      }
      if (!window.openDatabase) {
        throw "WebSQL not supported";
      }
      _db = openDatabase(name, version, "", size);
      _tables = 0;
      _results = [];
      for (table in schema) {
        sql = "CREATE TABLE IF NOT EXISTS " + table + " (";
        for (row in schema[table]) {
          sql += "" + row + " " + schema[table][row] + ",";
        }
        sql = sql.substring(0, sql.length - 1);
        sql += ")";
        _tables++;
        _results.push(execute(sql, function() {
          tables--;
          if (tables === 0) {
            return callback.call(callback);
          }
        }));
      }
      return _results;
    };
    select = function(options) {
      return "";
    };
    insert = function(options) {
      return "";
    };
    update = function(options) {
      return "";
    };
    remove = function(options) {
      return "";
    };
    drop = function(options) {
      return "";
    };
    execute = function(sql, callback) {
      if (!_db) {
        throw "Database not initializated";
      } else {
        return _db.transaction(function(tx) {
          return tx.executeSql(sql, callback);
        });
      }
    };
    return {
      init: init,
      select: select,
      insert: insert,
      update: update,
      remove: remove,
      drop: drop,
      execute: execute
    };
  })();

}).call(this);
