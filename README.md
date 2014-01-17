WebDB
=====

Javascript IndexedDB and WebSql agnostic framework.
What is WebDB?
--------------
WebDB is a javascript framework to ease the use of HTML5 database engines (webSQL and indexedDB). It also includes an agnostic mode to allow the engine to use the database engine if it is supported by the browser.

How it works
------------


###WebSql###

It is the most common HTML5 database engine, supported by Chrome, Safari, Opera, IOS, Android and BlackBerry [As you can see here](http://caniuse.com/#search=websql).

####Creating a Database and schema####
To create a database and its table schemas you just have to create a new instance of **WebDB.webSQL**, using as arguments the name, the schema, version, size, and a callback:

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
	
	var myDB = new WebDB.webSQL("MyDB", schema, 1, 5242880, onCreated);
	
####Inserting Data####
The instance that previously has been created has several methods the first one is **insert**. Data can be inserted one by one or in an array, to do this, the parameters needed are table, data and callback

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
You can get the stored data using the **select** method. This method requires as parameters the table, the query, and the callback that will receive the result. The format of the query is an array that contains objects, each attribute of the object is linked to the others with an AND and each position of the array whith an OR:

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
The data can be updated, to do this the method **update** must be used. The parameters that it receives are table, data, query and callback. The query is in the same format as the select method. The callback will receive the number of rows affected by the update query.

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

####Deleting an entries####
Using the **delete** method entries can be deleted. The parameters it uses is the table, the query (same format that select and update), and a callback that receives the number of entries deleted.

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
A table can be deleted usnig the **drop** method. This receives as arguments the table and a callback.

	var onDropped = function(){
		console.log("Table deleted");
	};
	myDB.drop("posts", onDropped);
	
####Pure SQL####
Maybe this methods aren't enough for you, so you can execute your own SQL with the **execute** method.

	var onSQL = function(result){
		console.log("If is a select result has the rows, else it has the number of rows affected");
	};
	
	myDB.execute("SELECT * FROM users WHERE age > 22", onSQL);