# Typed collections

A `Mongo.TypedCollection<T>` stores instances of a Spite class and reads them back as instances, with no code
written per class: the conversion is generated at compile time from the class's attributes.

```gdscript title=player.spite
var id = ""
var name = ""
var level = 1
var gold: Long = 0
var position = Position()
var tags = List<String>()
```

```gdscript
var collection = client.collection("game", "players")
var players = Mongo.TypedCollection<Player>(collection)
var hero = Player()
hero.name = "Ada"
var inserted = players.insert_one(hero)
var filter = Mongo.Document()
filter.put_text("name", "Ada")
var found = players.find_one(filter)
```

A typed collection has `insert_one(value)`, `find_one(filter)` (answering `T?`), `find(filter)` (answering
`List<T>`), `update_one`, `delete_one`, `delete_many` and `count_matching`. Filters and updates are still
`Mongo.Document`s, written with the attribute names as keys. The plain collection underneath is its `collection`,
for anything else (`update_many`, `batch_size`).

## The id

An attribute named `id` is the document's `_id`. When `insert_one` is given a value whose `id` is an empty
`String`, it generates a new ObjectId and writes its 24 hexadecimal characters into `id` before inserting, so the
value knows its id afterwards. An `id` that is already set is kept. A `String` id holding 24 hexadecimal characters is
stored as an ObjectId, and any other text as a string; reading answers the hexadecimal either way.

## How attributes map to BSON

Every attribute is one key, named after the attribute (only `id` is renamed).

| Attribute type | BSON |
| --- | --- |
| `Integer`, `Short`, `Tiny`, `Byte`, `UnsignedShort` | int32 |
| `Long`, `UnsignedInteger` | int64 |
| `Float`, `Double` | double |
| `Boolean` | boolean |
| `String` | string (or ObjectId, for `id` as above) |
| `T?` | `T`'s type, or null when absent |
| `List<T>` | array, each element mapped as `T` |
| any other class | embedded document, mapped by the same rules |

Reading is forgiving in one direction only: a field the document lacks, or whose type does not fit the attribute,
leaves the attribute at its default, and a field the class does not have is ignored. So a class can gain an
attribute without migrating the documents already stored, and documents written by other programs read as far as
they match. Numbers read into any number attribute, whatever their BSON type.

## Using the mapping directly

`Mongo.Codec<T>` is the conversion on its own: `to_document(value)` and `to_value(document)`. Use it to build a
document from a value for a command the collections do not have.

Next: [Errors and commands](errors_and_commands.md), what failure looks like, `client.error`, and running any
command yourself.
