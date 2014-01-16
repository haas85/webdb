(function() {
  var WebDB, _webDB;

  _webDB = (function() {
    function _webDB(name, schema, version, size, callback) {
      var db, key;
      this.name = name;
      this.schema = schema;
      this.version = version;
      this.size = size != null ? size : 5242880;
      if (window.openDatabase) {
        db = new WebDB.webSQL(this.name, this.schema, this.version, this.size, callback);
      } else if (window.indexedDB) {
        this.schema = (function() {
          var _results;
          _results = [];
          for (key in this.schema) {
            _results.push(key);
          }
          return _results;
        }).call(this);
        db = new WebDB.indexedDB(this.name, this.schema, this.version, callback);
      }
      if (!window.openDatabase && !window.indexedDB) {
        this.select = function() {
          throw "HTML5 Databases not supported";
        };
        this.insert = function() {
          throw "HTML5 Databases not supported";
        };
        this.update = function() {
          throw "HTML5 Databases not supported";
        };
        this["delete"] = function() {
          throw "HTML5 Databases not supported";
        };
        this.drop = function() {
          throw "HTML5 Databases not supported";
        };
        this.execute = function() {
          throw "HTML5 Databases not supported";
        };
        throw "HTML5 Databases not supported";
      }
      this.select = db.select;
      this.insert = db.insert;
      this.update = db.update;
      this["delete"] = db["delete"];
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
    var _check, _typeOf, _write;

    _indexedDB.prototype.db = null;

    function _indexedDB(name, schema, version, callback) {
      var openRequest,
        _this = this;
      if (version == null) {
        version = 1;
      }
      if (!window.indexedDB) {
        throw "IndexedDB not supported";
      }
      openRequest = indexedDB.open(dbName, version);
      openRequest.onsuccess = function(e) {
        var table, _i, _len;
        _this.db = e.target.result;
        for (_i = 0, _len = schema.length; _i < _len; _i++) {
          table = schema[_i];
          if (!_this.db.objectStoreNames.contains(table)) {
            _this.db.createObjectStore(table);
          }
        }
        return callback.call(callback);
      };
      openRequest.onerror = function(e) {
        throw "Error opening database";
      };
    }

    _indexedDB.prototype.select = function(table, query, callback) {
      var result;
      if (query == null) {
        query = [];
      }
      result = [];
      return this.db.transaction([table], "readonly").objectStore(table).openCursor().onsuccess = function(e) {
        var cursor, element, key;
        cursor = e.target.result;
        if (cursor) {
          element = {};
          for (key in cursor.value) {
            element[key] = cursor.value[key];
          }
          if (_check(element, query)) {
            result.push(element);
          }
          return cursor["continue"]();
        } else {
          return callback.call(callback, null, result);
        }
      };
    };

    _indexedDB.prototype.insert = function(table, data, callback) {
      if (_typeOf(data) === "object") {
        return _write(table, data, "add", callback);
      }
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

    _indexedDB.prototype.execute = function(options) {
      return "";
    };

    _write = function(table, data, operation, callback) {
      var request, store;
      store = this.db.transaction([table], "readwrite").objectStore(table);
      request = store[operation](data, 1);
      request.onerror = function(e) {
        return callback.call(callback, e, null);
      };
      return request.onsuccess = function(result) {
        return callback.call(callback, null, result);
      };
    };

    _check = function(element, query) {
      var key, result, stmt, _i, _len;
      if (query == null) {
        query = [];
      }
      if (query.length === 0) {
        return true;
      }
      for (_i = 0, _len = query.length; _i < _len; _i++) {
        stmt = query[_i];
        result = true;
        for (key in stmt) {
          if (element[key] !== stmt[key]) {
            result = false;
            break;
          }
        }
        if (result === true) {
          return true;
        }
      }
      return false;
    };

    _typeOf = function(obj) {
      return Object.prototype.toString.call(obj).match(/[a-zA-Z] ([a-zA-Z]+)/)[1].toLowerCase();
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

    function _webSQL(name, schema, version, size, callback) {
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
            sql += "" + or_stmt + " = " + (_setValue(value)) + " AND ";
          }
          sql = sql.substring(0, sql.length - 5) + ") OR (";
        }
        return sql.substring(0, sql.length - 5);
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
