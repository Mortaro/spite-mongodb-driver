# spite_mongodb_driver

A MongoDB driver for Spite programs, written in pure Spite. It speaks MongoDB's wire protocol (OP_MSG over a TCP
socket) itself: there is no C driver underneath and no external process, so any Spite program on any target the
language supports can `load` it.

It gives you:

- **`Mongo.TypedCollection<T>`**: store and read any Spite class. The mapping between the class and a BSON document
  is generated at compile time from the class's attributes, so there is nothing to register or annotate.
- **`Mongo.Collection`**: the same operations on plain documents (insert, find, update, delete, count).
- **`Mongo.Document`**: a BSON document that keeps its keys in insertion order, as MongoDB commands need.
- **`Mongo.Client`**: the connection, any command you build yourself, and the last error the server reported.

## Loading it

Clone this repository next to your program (or anywhere) and load the `mongodb` folder with a path relative to
your program's folder:

```gdscript
load "../spite_mongodb_driver/mongodb"
```

Everything it declares is in the `Mongo` namespace. A MongoDB server must be reachable when the program runs; for
a local one, `docker run -d -p 27017:27017 mongo:7` is enough.

## A complete example

A program of two files: a class to store, and the program that stores it, changes it and reads it back. It is
[examples/scoreboard](examples/scoreboard), and `check.sh` compiles it.

```gdscript title=scoreboard/score.spite
var id = ""
var player = ""
var points = 0
```

```gdscript title=scoreboard/scoreboard.spite
var console = Console()

func Scoreboard() {
    load "../../mongodb"
    var client = Mongo.Client("127.0.0.1", 27017)
    var connected = client.connect()
    crash connected
    var collection = client.collection("scoreboard_example", "scores")
    var scores = Mongo.TypedCollection<Score>(collection)
    var ada = Score()
    ada.player = "Ada"
    ada.points = 120
    var bo = Score()
    bo.player = "Bo"
    bo.points = 80
    var inserted = scores.insert_one(ada) and scores.insert_one(bo)
    crash inserted
    var filter = Mongo.Document()
    filter.put_text("player", "Bo")
    var changes = Mongo.Document()
    changes.put_integer("points", 95)
    var update = Mongo.Document()
    update.put_document("$set", changes)
    var modified = scores.update_one(filter, update)
    crash modified == 1
    var everyone = Mongo.Document()
    var all_scores = scores.find(everyone)
    var players = all_scores.map_players()
    var total = all_scores.sum_points()
    var names = players.join(", ")
    console.print(names, "scored", total)
    var dropped = client.drop_database("scoreboard_example")
    crash dropped
}
```

```
Ada, Bo scored 215
```

Run it from the `examples` folder with `spite scoreboard`. `insert_one` gives each `Score` a fresh ObjectId in its
`id`, which is stored as the document's `_id`.

## What it covers, and what it does not yet

- BSON double, string, document, array, ObjectId, boolean, UTC datetime, null, int32 and int64. Other types are
  kept as raw bytes, so reading a document that has them still works. Decoding is bounds-checked: a malformed
  reply answers `null` instead of crashing.
- Server errors (`errmsg`, write errors such as a duplicate key) are reported in `client.error`.
- Calls block. Inside a `Concurrent`, Spite turns each socket read into a wait, so a game can run database work
  between frames.
- Not built yet: authentication (SCRAM), TLS, connection pools beyond reusing idle sockets, and replica sets.

## Documentation

Read these in order; each ends with a link to the next.

1. [Getting started](docs/getting_started.md): a server, loading the driver, connecting, running the example.
2. [Documents](docs/documents.md): building and reading `Mongo.Document`, and the BSON types.
3. [Collections](docs/collections.md): inserting, finding, updating, deleting and counting plain documents.
4. [Typed collections](docs/typed_collections.md): storing your own classes, and how attributes map to BSON.
5. [Errors and commands](docs/errors_and_commands.md): what failure looks like, `client.error`, and running any
   command yourself.

Working on the driver itself: see [CLAUDE.md](CLAUDE.md).
