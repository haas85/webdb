/* WebDB v0.1.0 - 1/16/2014
   http://
   Copyright (c) 2014  - Licensed  */
(function(){var a,b;b=function(){function b(b,c,d,e,f){var g,h;this.name=b;this.schema=c;this.version=d;this.size=e!=null?e:5242880;if(window.openDatabase){g=new a.webSQL(this.name,this.schema,this.version,this.size,f)}else if(window.indexedDB){this.schema=function(){var a;a=[];for(h in this.schema){a.push(h)}return a}.call(this);g=new a.indexedDB(this.name,this.schema,this.version,f)}if(!window.openDatabase&&!window.indexedDB){this.select=function(){throw"HTML5 Databases not supported"};this.insert=function(){throw"HTML5 Databases not supported"};this.update=function(){throw"HTML5 Databases not supported"};this["delete"]=function(){throw"HTML5 Databases not supported"};this.drop=function(){throw"HTML5 Databases not supported"};this.execute=function(){throw"HTML5 Databases not supported"};throw"HTML5 Databases not supported"}this.select=g.select;this.insert=g.insert;this.update=g.update;this["delete"]=g["delete"];this.drop=g.drop;this.execute=g.execute}return b}();a=window.WebDB=b}).call(this);(function(){var a;a=function(){var a,b,c;d.prototype.db=null;function d(a,b,c,d){var e,f=this;if(c==null){c=1}if(!window.indexedDB){throw"IndexedDB not supported"}e=indexedDB.open(dbName,c);e.onsuccess=function(a){var c,e,g;f.db=a.target.result;for(e=0,g=b.length;e<g;e++){c=b[e];if(!f.db.objectStoreNames.contains(c)){f.db.createObjectStore(c)}}return d.call(d)};e.onerror=function(a){throw"Error opening database"}}d.prototype.select=function(b,c,d){var e;if(c==null){c=[]}e=[];return this.db.transaction([b],"readonly").objectStore(b).openCursor().onsuccess=function(b){var f,g,h;f=b.target.result;if(f){g={};for(h in f.value){g[h]=f.value[h]}if(a(g,c)){e.push(g)}return f["continue"]()}else{return d.call(d,null,e)}}};d.prototype.insert=function(a,d,e){if(b(d)==="object"){return c(a,d,"add",e)}};d.prototype.update=function(a){return""};d.prototype["delete"]=function(a){return""};d.prototype.drop=function(a){return""};d.prototype.execute=function(a){return""};c=function(a,b,c,d){var e,f;f=this.db.transaction([a],"readwrite").objectStore(a);e=f[c](b,1);e.onerror=function(a){return d.call(d,a,null)};return e.onsuccess=function(a){return d.call(d,null,a)}};a=function(a,b){var c,d,e,f,g;if(b==null){b=[]}for(f=0,g=b.length;f<g;f++){e=b[f];d=false;for(c in e){if(a[c]===e[c]){d=true;break}}if(d===false){return false}}return true};b=function(a){return Object.prototype.toString.call(a).match(/[a-zA-Z] ([a-zA-Z]+)/)[1].toLowerCase()};return d}();WebDB.indexedDB=a}).call(this);(function(){var a;a=function(){var a,b,c,d;e.prototype.db=null;function e(a,b,c,d,e){var f,g,h,i;if(d==null){d=5242880}if(!window.openDatabase){throw"WebSQL not supported"}this.db=openDatabase(a,c,"",d);i=0;for(h in b){g="CREATE TABLE IF NOT EXISTS "+h+" (";for(f in b[h]){g+=""+f+" "+b[h][f]+","}g=g.substring(0,g.length-1);g+=")";i++;execute(g,function(){tables--;if(tables===0){return e.call(e)}})}}e.prototype.select=function(a,c,d){var e;if(c==null){c=[]}e="SELECT * FROM "+a;e+=b(c);return this.execute(e,d)};e.prototype.insert=function(b,c,e){var f,g,h,i,j;if(d(c)==="object"){return a(b,c,e)}else{f=c.length;j=[];for(h=0,i=c.length;h<i;h++){g=c[h];j.push(a(b,g,function(){f--;if(f===0){return e.call(e)}}))}return j}};e.prototype.update=function(a,d,e,f){var g,h;if(e==null){e=[]}h="UPDATE TABLE "+a+" SET (";for(g in d){h+=""+g+" = "+c(d[g])+", "}h=h.substring(0,h.length-2)+") "+b(e);return this.execute(h,f)};e.prototype["delete"]=function(a,c,d){var e;if(c==null){c=[]}e="DELETE FROM "+a+" "+b(c);return this.execute(e,d)};e.prototype.drop=function(a,b){return this.execute("DROP TABLE IF EXISTS "+a,b)};e.prototype.execute=function(a,b){if(!this.db){throw"Database not initializated"}else{return this.db.transaction(function(c){return c.executeSql(a,b)})}};a=function(a,b,d){var e,f,g;g="INSERT INTO "+a+" (";e="(";for(f in b){g+=""+f+", ";e+=""+c(b[f])+", "}g=g.substring(0,g.length-2)+") ";e=e.substring(0,e.length-2)+") ";g+=" VALUES "+e;return this.execute(g,d)};b=function(a){var b,d,e,f,g,h;if(a.length>0){e=" WHERE (";for(g=0,h=a.length;g<h;g++){b=a[g];for(d in b){f=b[d];e+=""+d+" = "+c(f)+" AND "}e=e.substring(0,e.length-5)+") OR ("}return e.substring(0,e.length-5)}else{return""}};c=function(a){if(isNaN(a)){return"'"+a+"'"}else{return a}};d=function(a){return Object.prototype.toString.call(a).match(/[a-zA-Z] ([a-zA-Z]+)/)[1].toLowerCase()};return e}();WebDB.webSQL=a}).call(this);