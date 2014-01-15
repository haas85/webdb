/* WebDB v0.1.0 - 1/15/2014
   http://
   Copyright (c) 2014  - Licensed  */
(function(){var a,b;b=function(){b.db=null;function b(b,c,d,e,f){this.name=b;this.version=c;this.size=d!=null?d:5242880;this.schema=e;if(window.openDatabase){this.db=new a.webSQL(this.name,this.version,this.size,this.schema,f)}else if(window.indexedDB){this.db=new a.indexedDB(this.name,this.version,this.size,this.schema,f)}if(!window.openDatabase&&!window.indexedDB){throw"HTML5 Databases not supported"}}b.prototype.select=b.db.select;b.prototype.insert=b.db.insert;b.prototype.update=b.db.update;b.prototype.remove=b.db.remove;b.prototype.drop=b.db.drop;b.prototype.execute=b.db.execute;return b}();a=window.WebDB=b}).call(this);(function(){var a;a=function(){a.db=null;function a(a,b,c,d,e){if(c==null){c=5242880}""}a.prototype.select=function(a){return""};a.prototype.insert=function(a){return""};a.prototype.update=function(a){return""};a.prototype.remove=function(a){return""};a.prototype.drop=function(a){return""};a.prototype.execute=function(a,b){return""};return a}();WebDB.indexedDB=a}).call(this);(function(){var a;a=function(){a.db=null;function a(a,b,c,d,e){var f,g,h,i;if(c==null){c=5242880}if(!window.openDatabase){throw"WebSQL not supported"}this.db=openDatabase(a,b,"",c);i=0;for(h in d){g="CREATE TABLE IF NOT EXISTS "+h+" (";for(f in d[h]){g+=""+f+" "+d[h][f]+","}g=g.substring(0,g.length-1);g+=")";i++;execute(g,function(){tables--;if(tables===0){return e.call(e)}})}}a.prototype.select=function(a){return""};a.prototype.insert=function(a){return""};a.prototype.update=function(a){return""};a.prototype.remove=function(a){return""};a.prototype.drop=function(a){return""};a.prototype.execute=function(a,b){if(!this.db){throw"Database not initializated"}else{return this.db.transaction(function(c){return c.executeSql(a,b)})}};return a}();WebDB.webSQL=a}).call(this);