# Documents

Every filter, update and command is a `Mongo.Document`, and every plain document the server sends back is one.
This page builds them and reads them.

## Building a document

```gdscript
var hero = Mongo.Document()
hero.put_text("name", "Ada")
hero.put_integer("level", 3)
hero.put_double("score", 12.5)
hero.put_boolean("alive", true)
hero.put_null("guild")
```

A document keeps its keys in the order they were first put, which MongoDB needs for commands (the command's name
must be the first key). Putting a key that is already there replaces its value in place, keeping its position.

| Function | BSON type |
| --- | --- |
| `put_text(key, value: String)` | string |
| `put_integer(key, value: Integer)` | int32 |
| `put_long(key, value: Long)` | int64 |
| `put_double(key, value: Double)` | double |
| `put_boolean(key, value: Boolean)` | boolean |
| `put_null(key)` | null |
| `put_object_id(key, hexadecimal: String)` | ObjectId, from its 24 hexadecimal characters |
| `put_date_time(key, milliseconds_since_1970: Long)` | UTC datetime |
| `put_document(key, value: Mongo.Document)` | embedded document |
| `put_array(key, value: Mongo.Document)` | array (the document's elements, in order) |

The functions are named `put_` rather than `set_` because Spite reads a call such as `set_null(key)` as writing
the attribute `null`.

## Nested documents and arrays

An embedded document is a `Mongo.Document` put under a key. An array is a `Mongo.Document` too, built with the
`append_` functions, which use the element's position as its key, as BSON arrays do:

```gdscript
var tags = Mongo.Document()
tags.append_text("knight")
tags.append_text("brave")
hero.put_array("tags", tags)
var changes = Mongo.Document()
changes.put_integer("level", 7)
var update = Mongo.Document()
update.put_document("$set", changes)
```

There are `append_text`, `append_integer`, `append_long`, `append_double`, `append_boolean` and `append_document`.

## Reading a document

| Function | Answers | When the key is missing |
| --- | --- | --- |
| `text_of(key)` | `String` (a string, or an ObjectId's hexadecimal) | `""` |
| `integer_of(key)` | `Integer` (any number, or a boolean as 0 or 1) | `0` |
| `long_of(key)` | `Long` | `0` |
| `double_of(key)` | `Double` | `0.0` |
| `boolean_of(key)` | `Boolean` | `false` |
| `document_of(key)` | `Mongo.Document?` (an embedded document or an array) | `null` |
| `has(key)` | whether the key is there | |
| `find(key)` | the `Mongo.Element?` itself | `null` |
| `keys()` | every key, in order | |
| `count()` | how many keys | |

The number readers convert between number types, so a value the server stored as a double reads with
`integer_of`. A document prints as MongoDB's shell shows it, `{name: "Ada", level: 3, guild: null}`, wherever a
`String` is wanted.

## Elements

A document is a `List<Mongo.Element>` in `elements`. An element has a `key`, a `kind` (the BSON type number: 1
double, 2 string, 3 document, 4 array, 7 ObjectId, 8 boolean, 9 datetime, 10 null, 16 int32, 18 int64) and the
value in the attribute that kind uses: `text` for strings and ObjectIds, `whole` for integers and datetimes,
`decimal` for doubles, `boolean`, or `document` for documents and arrays. Reach for elements only for what the
readers above do not cover, such as telling an ObjectId from a string.

Next: [Collections](collections.md), inserting, finding, updating, deleting and counting plain documents.
