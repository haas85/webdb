(function() {
  var WebDB, _webDB;

  _webDB = (function() {
    _webDB.prototype.db = null;

    function _webDB(name, version, size, schema, callback) {
      this.name = name;
      this.version = version;
      this.size = size != null ? size : 5242880;
      this.schema = schema;
      if (window.openDatabase) {
        this.db = new WebDB.webSQL(this.name, this.version, this.size, this.schema, callback);
      } else if (window.indexedDB) {
        this.db = new WebDB.indexedDB(this.name, this.version, this.size, this.schema, callback);
      }
      if (!window.openDatabase && !window.indexedDB) {
        throw "HTML5 Databases not supported";
      }
    }

    _webDB.prototype.select = _webDB.db.select;

    _webDB.prototype.insert = _webDB.db.insert;

    _webDB.prototype.update = _webDB.db.update;

    _webDB.prototype.remove = _webDB.db.remove;

    _webDB.prototype.drop = _webDB.db.drop;

    _webDB.prototype.execute = _webDB.db.execute;

    return _webDB;

  })();

  WebDB = window.WebDB = _webDB;

}).call(this);

(function() {
  var _indexedDB;

  _indexedDB = (function() {
    _indexedDB.prototype.db = null;

    function _indexedDB(name, version, size, schema, callback) {
      if (size == null) {
        size = 5242880;
      }
      "";
    }

    _indexedDB.prototype.select = function(options) {
      return "";
    };

    _indexedDB.prototype.insert = function(options) {
      return "";
    };

    _indexedDB.prototype.update = function(options) {
      return "";
    };

    _indexedDB.prototype.remove = function(options) {
      return "";
    };

    _indexedDB.prototype.drop = function(options) {
      return "";
    };

    _indexedDB.prototype.execute = function(sql, callback) {
      return "";
    };

    return _indexedDB;

  })();

  WebDB.indexedDB = _indexedDB;

}).call(this);

(function() {
  var _webSQL;

  _webSQL = (function() {
    _webSQL.prototype.db = null;

    function _webSQL(name, version, size, schema, callback) {
      var row, sql, table, _tables;
      if (size == null) {
        size = 5242880;
      }
      if (!window.openDatabase) {
        throw "WebSQL not supported";
      }
      this.db = openDatabase(name, version, "", size);
      _tables = 0;
      for (table in schema) {
        sql = "CREATE TABLE IF NOT EXISTS " + table + " (";
        for (row in schema[table]) {
          sql += "" + row + " " + schema[table][row] + ",";
        }
        sql = sql.substring(0, sql.length - 1);
        sql += ")";
        _tables++;
        execute(sql, function() {
          tables--;
          if (tables === 0) {
            return callback.call(callback);
          }
        });
      }
    }

    _webSQL.prototype.select = function(options) {
      return "";
    };

    _webSQL.prototype.insert = function(options) {
      return "";
    };

    _webSQL.prototype.update = function(options) {
      return "";
    };

    _webSQL.prototype.remove = function(options) {
      return "";
    };

    _webSQL.prototype.drop = function(options) {
      return "";
    };

    _webSQL.prototype.execute = function(sql, callback) {
      if (!this.db) {
        throw "Database not initializated";
      } else {
        return this.db.transaction(function(tx) {
          return tx.executeSql(sql, callback);
        });
      }
    };

    return _webSQL;

  })();

  WebDB.webSQL = _webSQL;

}).call(this);
