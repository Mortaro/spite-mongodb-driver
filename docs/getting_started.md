# Getting started

This page gets a MongoDB server running, loads the driver into a Spite program and connects to it.

## A server

The driver talks to any MongoDB server reachable over TCP without authentication or TLS (both are not built yet). For
a local one:

```
docker run -d --name mongo -p 27017:27017 mongo:7
```

or install MongoDB from your system's packages and start `mongod`. The examples here use `127.0.0.1:27017`.

## Loading the driver

A Spite program is a folder whose entry file is named after it. Put this repository anywhere (beside your program
is simplest) and load its `mongodb` folder from the entry file's constructor, with a path relative to your program's
folder:

```gdscript
func MyGame() {
    load "../spite_mongodb_driver/mongodb"
}
```

`load` takes a literal path only. Everything the driver declares is in the `Mongo` namespace: `Mongo.Client`,
`Mongo.Collection`, `Mongo.TypedCollection<T>`, `Mongo.Document` and the classes they use.

## Connecting

```gdscript
var client = Mongo.Client("127.0.0.1", 27017)
var connected = client.connect()
crash connected
```

`Mongo.Client(host, port)` only remembers where the server is. `connect()` opens one socket and answers whether it
could; when it could not, `client.error` says so (`could not connect to 127.0.0.1:27017`). Calling `connect()` is
optional: every command takes an idle socket if there is one and opens a new one otherwise, so a program that never
calls it still works and finds out at its first command.

Each command in flight has a socket of its own, and the socket goes back to the idle list when the reply has been
read, so two `Concurrent` tasks can use one client at the same time. `client.close()` closes every idle socket; a
client that is dropped closes them too.

## Collections

```gdscript
var players = client.collection("game", "players")
```

`collection(database, name)` gives a `Mongo.Collection`, a handle that remembers its client, database and name. It
sends nothing to the server: MongoDB creates the database and the collection at the first insert.

## Running the example

The [README](../README.md#a-complete-example) has a complete program, and it is in this repository as
`examples/scoreboard`. With the Spite compiler's `bin` folder on your `PATH` and a server running:

```
cd examples
spite scoreboard
```

It prints `Ada, Bo scored 215` and drops the `scoreboard_example` database it wrote. `spite scoreboard --check`
only checks that it compiles, without a server.

Next: [Documents](documents.md), building and reading `Mongo.Document`, and the BSON types.
