# spite_mongodb_driver

MongoDB for Spite programs, over MongoDB's wire protocol in pure Spite: no C driver, no external process.

```gdscript
func MyProgram() {
    load "../spite_mongodb_driver/mongodb"
    var client = Mongo.Client("127.0.0.1", 27017)
    var players = client.collection("game", "players")
    var typed = Mongo.TypedCollection<Player>(players)
    typed.insert_one(hero)
    var found = typed.find_one(filter)
}
```

- **BSON** encode and decode. The types covered are double, string, document, array, ObjectId, boolean, UTC
  datetime, null, int32 and int64; other types are kept as raw bytes. Decoding is bounds-checked, and malformed
  input answers `null` instead of crashing.
- **OP_MSG** commands, with the server's `errmsg` and write errors reported in `client.error`.
- **`Mongo.Document`**, a document that keeps its keys in insertion order, as commands need.
- **`Mongo.Codec<T>`**, a mapping between any Spite class and a document, generated at compile time from its
  attributes.
  - An attribute named `id` is `_id`, stored as an ObjectId when it holds 24 hex characters.
  - Missing fields keep their defaults, and unknown fields are ignored.
- **`Mongo.Collection`** and **`Mongo.TypedCollection<T>`**: insert, find (following the cursor with `getMore`),
  update, delete and count.

Calls block; inside a `Concurrent`, Spite turns each socket read into a wait, so a game engine can run database work
between frames. Not built yet: authentication (SCRAM), TLS, connection pools and replica sets.
