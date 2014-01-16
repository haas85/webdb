(function() {
  var WebDB, _webDB;

  _webDB = (function() {
    function _webDB(name, version, size, schema, callback) {
      var db, drop, execute, insert, remove, select, update;
      this.name = name;
      this.version = version;
      this.size = size != null ? size : 5242880;
      this.schema = schema;
      if (window.openDatabase) {
        db = new WebDB.webSQL(this.name, this.version, this.size, this.schema, callback);
      } else if (window.indexedDB) {
        db = new WebDB.indexedDB(this.name, this.version, this.size, this.schema, callback);
      }
      if (!window.openDatabase && !window.indexedDB) {
        select = function() {
          throw "HTML5 Databases not supported";
        };
        insert = function() {
          throw "HTML5 Databases not supported";
        };
        update = function() {
          throw "HTML5 Databases not supported";
        };
        remove = function() {
          throw "HTML5 Databases not supported";
        };
        drop = function() {
          throw "HTML5 Databases not supported";
        };
        execute = function() {
          throw "HTML5 Databases not supported";
        };
        throw "HTML5 Databases not supported";
      }
      this.select = db.select;
      this.insert = db.insert;
      this.update = db.update;
      this.remove = db.remove;
      this.drop = db.drop;
      this.execute = db.execute;
    }

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

    _indexedDB.prototype["delete"] = function(options) {
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
    var _insert, _queryToSQL, _setValue, _typeOf;

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

    _webSQL.prototype.select = function(table, query, callback) {
      var sql;
      if (query == null) {
        query = [];
      }
      sql = "SELECT * FROM " + table;
      sql += _queryToSQL(query);
      return this.execute(sql, callback);
    };

    _webSQL.prototype.insert = function(table, data, callback) {
      var len, row, _i, _len, _results;
      if (_typeOf(data) === "object") {
        return _insert(table, data, callback);
      } else {
        len = data.length;
        _results = [];
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          row = data[_i];
          _results.push(_insert(table, row, function() {
            len--;
            if (len === 0) {
              return callback.call(callback);
            }
          }));
        }
        return _results;
      }
    };

    _webSQL.prototype.update = function(table, data, query, callback) {
      var key, sql;
      if (query == null) {
        query = [];
      }
      sql = "UPDATE TABLE " + table + " SET (";
      for (key in data) {
        sql += "" + key + " = " + (_setValue(data[key])) + ", ";
      }
      sql = sql.substring(0, sql.length - 2) + ") " + _queryToSQL(query);
      return this.execute(sql, callback);
    };

    _webSQL.prototype["delete"] = function(table, query, callback) {
      var sql;
      if (query == null) {
        query = [];
      }
      sql = "DELETE FROM " + table + " " + (_queryToSQL(query));
      return this.execute(sql, callback);
    };

    _webSQL.prototype.drop = function(table, callback) {
      return this.execute("DROP TABLE IF EXISTS " + table, callback);
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

    _insert = function(table, row, callback) {
      var data, key, sql;
      sql = "INSERT INTO " + table + " (";
      data = "(";
      for (key in row) {
        sql += "" + key + ", ";
        data += "" + (_setValue(row[key])) + ", ";
      }
      sql = sql.substring(0, sql.length - 2) + ") ";
      data = data.substring(0, data.length - 2) + ") ";
      sql += " VALUES " + data;
      return this.execute(sql, callback);
    };

    _queryToSQL = function(query) {
      var elem, or_stmt, sql, value, _i, _len;
      if (query.length > 0) {
        sql = " WHERE (";
        for (_i = 0, _len = query.length; _i < _len; _i++) {
          elem = query[_i];
          for (or_stmt in elem) {
            value = elem[or_stmt];
            sql += "" + or_stmt + " = " + (_setValue(value)) + " OR ";
          }
          sql = sql.substring(0, sql.length - 4) + ") AND (";
        }
        return sql.substring(0, sql.length - 6);
      } else {
        return "";
      }
    };

    _setValue = function(value) {
      if (isNaN(value)) {
        return "'" + value + "'";
      } else {
        return value;
      }
    };

    _typeOf = function(obj) {
      return Object.prototype.toString.call(obj).match(/[a-zA-Z] ([a-zA-Z]+)/)[1].toLowerCase();
    };

    return _webSQL;

  })();

  WebDB.webSQL = _webSQL;

}).call(this);
