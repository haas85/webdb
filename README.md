WebDB
=====

Javascript library to use HTML5 database engines IndexedDB and WebSql in an agnostic way.
What is WebDB?
--------------
WebDB is a javascript framework to ease the use of HTML5 database engines (webSQL and indexedDB). It also includes an agnostic mode to allow the engine to use the database engine if it is supported by the browser.
How it works
------------
WebDB has an agnostic mode to work with HTML5 databases using the browser's supported database engine priorizing indexedDB over webSQL, but if you prefer you can use webSQL or indexedDB separately.

In both three modes the api is the same, but what changes is the constructor.
###Agnostic mode###
-------------------
This mode has a generic api to allow developers to work with the browser's supported database engine without the need of knowing what database is supported.

####Creating a Database and schema####
To create a database and its table schemas you just have to create a new instance of **WebDB**.
#####Parameters#####
* **name:** the name of the database
* **schema:** The schema, its structure is explained in the next code
* **version:** version of the database
* **size:** The ammount of space in Mb to allocate
* **callback:** The method to call after creating the database


		//The first level of the schema defines the table, and its content the atributes and types:
		var schema = {
			users:{
				name: "TEXT",
				email: "TEXT",
				age: "NUMBER"
			},
			posts: {
				title: "TEXT",
				content: "TEXT"
			}
		};

		var onCreated = function(){
			alert("Database Created");
		};

		var myDB = new WebDB("MyDB", schema, 1, 5, onCreated);

####Inserting Data####
The instance that previously has been created has several methods the first one is **insert**. Data can be inserted one by one or in an array.
#####Parameters#####
* **table:** The name of the table
* **data:** Data in object or array to insert
* **callback:** The callback that will receive the number of insertions

		var single_data = {
			name: "haas85",
			email: "inigo@ingonza.com",
			age: 29
		};

		var multiple_data = [
			{
				name: "user2",
				email: "user2@gmail.com",
				age: 32
			},
			{
				name: "user3",
				email: "user3@gmail.com",
				age: 24
			},

		];

		var onInserted = function(inserts){
			alert("The amount of rows inserted is: " + inserts);
		};

		myDB.insert("users", single_data, onInserted);
		myDB.insert("users", multiple_data, onInserted);

####Getting the data####
You can get the stored data using the **select** method.
#####Parameters#####
* **name:** The name of the database
* **query:** The search query, its format is an array that contains objects, each attribute of the object is linked to the others with an AND and each position of the array whith an OR.
* **callback:** The callback that will receive the result of the query.

		var query = [
			{
				name: "haas85",
				age: 29
			},
			{
				age: 24
			}
		];
		// This is like: WHERE (name = 'haas85' AND age = 29) OR (age = 24)

		var onUsers = function(users){
			console.log("This is an array of objects from the DB");
			console.log(users);
		};

		myDB.select("users", query, onUsers)

####Updating entries####
The data can be updated, to do this the method **update** must be used.
#####Parameters#####
* **name:** The name of the database
* **data:** The fields to update
* **query:** The query to search entries, the same format as in select.
* **callback:** The callback that will receive the number of entries modified

		var query = [
			{
				name: "user2",
				age: 32
			}
		];

		var data ={
			name: "user_2"
		};

		var onUpdate = function(affected){
			console.log("The number of rows updated is: " + affected);
		};

		myDB.update("users", data, query, onUpdate);

####Deleting entries####
Using the **delete** method entries can be deleted.
#####Parameters#####
* **name:** The name of the database
* **query:** The query to search entries, the same format as in select.
* **callback:** The callback that will receive the number of entries deleted

		var query = [
			{
				name: "user_2",
				age: 32
			}
		];

		var onDelete = function(affected){
			console.log("The number of rows deleted is: " + affected);
		};

		myDB.delete("users", query, onDelete);

####Deleting a table####
A table can be deleted usnig the **drop** method.
#####Parameters#####
* **name:** The name of the database
* **callback:** The callback to execute after droping the table

		var onDropped = function(){
			console.log("Table deleted");
		};
		myDB.drop("posts", onDropped);


###WebSql###
------------

It is the most common HTML5 database engine, supported by Chrome, Safari, Opera, IOS, Android and BlackBerry [As you can see here](http://caniuse.com/#search=websql).

####Creating a Database and schema####
To create a database and its table schemas you just have to create a new instance of **WebDB.webSQL**.
#####Parameters#####
* **name:** the name of the database
* **schema:** The schema, its structure is explained in the next code
* **version:** version of the database
* **size:** The ammount of space in Mb to allocate
* **callback:** The method to call after creating the database


		//The first level of the schema defines the table, and its content the atributes and types:
		var schema = {
			users:{
				name: "TEXT",
				email: "TEXT",
				age: "NUMBER"
			},
			posts: {
				title: "TEXT",
				content: "TEXT"
			}
		};

		var onCreated = function(){
			alert("Database Created");
		};

		var myDB = new WebDB.webSQL("MyDB", schema, 1, 5, onCreated);

####Inserting Data####
The instance that previously has been created has several methods the first one is **insert**. Data can be inserted one by one or in an array.
#####Parameters#####
* **table:** The name of the table
* **data:** Data in object or array to insert
* **callback:** The callback that will receive the number of insertions

		var single_data = {
			name: "haas85",
			email: "inigo@ingonza.com",
			age: 29
		};

		var multiple_data = [
			{
				name: "user2",
				email: "user2@gmail.com",
				age: 32
			},
			{
				name: "user3",
				email: "user3@gmail.com",
				age: 24
			},

		];

		var onInserted = function(inserts){
			alert("The amount of rows inserted is: " + inserts);
		};

		myDB.insert("users", single_data, onInserted);
		myDB.insert("users", multiple_data, onInserted);

####Getting the data####
You can get the stored data using the **select** method.
#####Parameters#####
* **name:** The name of the database
* **query:** The search query, its format is an array that contains objects, each attribute of the object is linked to the others with an AND and each position of the array whith an OR.
* **callback:** The callback that will receive the result of the query.

		var query = [
			{
				name: "haas85",
				age: 29
			},
			{
				age: 24
			}
		];
		// This is like: WHERE (name = 'haas85' AND age = 29) OR (age = 24)

		var onUsers = function(users){
			console.log("This is an array of objects from the DB");
			console.log(users);
		};

		myDB.select("users", query, onUsers)

####Updating entries####
The data can be updated, to do this the method **update** must be used.
#####Parameters#####
* **name:** The name of the database
* **data:** The fields to update
* **query:** The query to search entries, the same format as in select.
* **callback:** The callback that will receive the number of entries modified

		var query = [
			{
				name: "user2",
				age: 32
			}
		];

		var data ={
			name: "user_2"
		};

		var onUpdate = function(affected){
			console.log("The number of rows updated is: " + affected);
		};

		myDB.update("users", data, query, onUpdate);

####Deleting entries####
Using the **delete** method entries can be deleted.
#####Parameters#####
* **name:** The name of the database
* **query:** The query to search entries, the same format as in select.
* **callback:** The callback that will receive the number of entries deleted

		var query = [
			{
				name: "user_2",
				age: 32
			}
		];

		var onDelete = function(affected){
			console.log("The number of rows deleted is: " + affected);
		};

		myDB.delete("users", query, onDelete);

####Deleting a table####
A table can be deleted usnig the **drop** method.
#####Parameters#####
* **name:** The name of the database
* **callback:** The callback to execute after droping the table

		var onDropped = function(){
			console.log("Table deleted");
		};
		myDB.drop("posts", onDropped);

####Pure SQL####
Maybe this methods aren't enough for you, so you can execute your own SQL with the **execute** method.
#####Parameters#####
* **sql:** The SQL to execute
* **callback**: A callback that will receive the result (entries or number of entries modified)

		var onSQL = function(result){
			console.log("If is a select result has the rows, else it has the number of rows affected");
		};

		myDB.execute("SELECT * FROM users WHERE age > 22", onSQL);

###IndexedDB###
---------------

It is the HTML5 database engine which W3C is working on, supported by Chrome, IE, Firefox, Opera, Android 4.4 and partially by BlackBerry [As you can see here](http://caniuse.com/#search=indexedDB).

####Creating a Database and schema####
To create a database and its table schemas you just have to create a new instance of **WebDB.indexedDB**.
#####Parameters#####
* **name:** the name of the database
* **schema:** The schema, its structure is an array with names
* **version:** version of the database
* **callback:** The method to call after creating the database

		var schema = ["users", "posts"];

		var onCreated = function(){
			alert("Database Created");
		};

		var myDB = new WebDB.indexedDB("MyDB", schema, 1, onCreated);

####Inserting Data####
The instance that previously has been created has several methods the first one is **insert**. Data can be inserted one by one or in an array.
#####Parameters#####
* **table:** The name of the table
* **data:** Data in object or array to insert
* **callback:** The callback that will receive the number of insertions

		var single_data = {
			name: "haas85",
			email: "inigo@ingonza.com",
			age: 29
		};

		var multiple_data = [
			{
				name: "user2",
				email: "user2@gmail.com",
				age: 32
			},
			{
				name: "user3",
				email: "user3@gmail.com",
				age: 24
			},

		];

		var onInserted = function(inserts){
			alert("The amount of rows inserted is: " + inserts);
		};

		myDB.insert("users", single_data, onInserted);
		myDB.insert("users", multiple_data, onInserted);

####Getting the data####
You can get the stored data using the **select** method.
#####Parameters#####
* **name:** The name of the database
* **query:** The search query, its format is an array that contains objects, each attribute of the object is linked to the others with an AND and each position of the array whith an OR.
* **callback:** The callback that will receive the result of the query.

		var query = [
			{
				name: "haas85",
				age: 29
			},
			{
				age: 24
			}
		];
		// This is like: WHERE (name = 'haas85' AND age = 29) OR (age = 24)

		var onUsers = function(users){
			console.log("This is an array of objects from the DB");
			console.log(users);
		};

		myDB.select("users", query, onUsers)

####Updating entries####
The data can be updated, to do this the method **update** must be used.
#####Parameters#####
* **name:** The name of the database
* **data:** The fields to update
* **query:** The query to search entries, the same format as in select.
* **callback:** The callback that will receive the number of entries modified

		var query = [
			{
				name: "user2",
				age: 32
			}
		];

		var data ={
			name: "user_2"
		};

		var onUpdate = function(affected){
			console.log("The number of rows updated is: " + affected);
		};

		myDB.update("users", data, query, onUpdate);

####Deleting entries####
Using the **delete** method entries can be deleted.
#####Parameters#####
* **name:** The name of the database
* **query:** The query to search entries, the same format as in select.
* **callback:** The callback that will receive the number of entries deleted

		var query = [
			{
				name: "user_2",
				age: 32
			}
		];

		var onDelete = function(affected){
			console.log("The number of rows deleted is: " + affected);
		};

		myDB.delete("users", query, onDelete);

####Deleting a table####
A table can be deleted usnig the **drop** method.
#####Parameters#####
* **name:** The name of the database
* **callback:** The callback to execute after droping the table

		var onDropped = function(){
			console.log("Table deleted");
		};
		myDB.drop("posts", onDropped);
		
		
What is next?
-------------
The next improvements that are coming are:

* Auto versioning
* Query modificators such as bigger, smaller and like
* Group by, order by
* Count, distinct
