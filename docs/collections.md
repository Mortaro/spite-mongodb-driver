# Collections

A `Mongo.Collection` sends MongoDB's CRUD commands for plain documents. Every function blocks until the server
answers.

```gdscript
var players = client.collection("game", "players")
```

## Inserting

```gdscript
var inserted = players.insert_one(hero)
```

`insert_one(document)` answers whether the server stored it. A document without an `_id` gets one from the server,
which the driver does not read back; to know the id, put it yourself with `put_object_id`, or use a
[typed collection](typed_collections.md), which generates it.

## Finding

```gdscript
var filter = Mongo.Document()
filter.put_text("name", "Ada")
var found = players.find_one(filter)
if found {
    console.print(found.integer_of("level"))
}
var everyone = Mongo.Document()
var all_players = players.find(everyone)
```

`find_one(filter)` answers the first matching document, or `null` when nothing matches or the command failed.
`find(filter)` answers every matching document as a `List<Mongo.Document>`, following the server's cursor with
`getMore` until it is exhausted. An empty filter matches everything. Filters are MongoDB's own query documents, so
operators are nested documents: `{level: {$gt: 5}}` is

```gdscript
var above = Mongo.Document()
above.put_integer("$gt", 5)
var filter = Mongo.Document()
filter.put_document("level", above)
```

`players.batch_size` asks the server for that many documents per reply (0, the default, leaves it to the server).
It changes how many round trips `find` makes, never what it answers.

## Updating

```gdscript
var changes = Mongo.Document()
changes.put_integer("level", 7)
var update = Mongo.Document()
update.put_document("$set", changes)
var modified = players.update_one(filter, update)
```

`update_one(filter, update)` changes the first matching document and `update_many` every one. Both answer how many
documents the server modified (`nModified`): a document that already had the new values is not counted.

## Deleting and counting

```gdscript
var deleted = players.delete_one(filter)
var cleared = players.delete_many(everyone)
var left = players.count_matching(everyone)
```

`delete_one` and `delete_many` answer how many documents were deleted, and `count_matching(filter)` how many match.

## When a command fails

A failed command answers `false`, `0` or `null` (whichever the function answers), and `client.error` says why.
The [last page](errors_and_commands.md) covers it.

Next: [Typed collections](typed_collections.md), storing your own classes, and how attributes map to BSON.
