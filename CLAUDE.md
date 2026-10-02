# Working on spite_mongodb_driver

Maintainer and agent notes. What the driver is and how to use it is in [README.md](README.md) and [docs/](docs);
read those first, since they are the contract this code keeps.

## Layout

- `mongodb/` is the package, and its `mongo/` folder is the namespace `Mongo`. Programs load it with
  `load "<path>/spite_mongodb_driver/mongodb"`.
  - `client.spite`: sockets, OP_MSG framing (`request`, `receive`), `run_command` and `client.error`.
  - `collection.spite`, `typed_collection.spite`: the CRUD commands, plain and typed.
  - `document.spite`, `element.spite`: the ordered document; an element's `kind` is the BSON type number.
  - `bson.spite`, `bytes.spite`, `raw_memory.spite`: encoding and bounds-checked decoding over a growable buffer.
  - `codec.spite`, `mapping.spite`, `list_mapping.spite`: the compile-time class to document mapping, written as
    member templates (`write_attributes`, `read_attributes`) and `$field_type` tests.
  - `object_ids.spite`, `hex.spite`: ObjectId generation and hexadecimal.
- `mongodb_probe/` is the test program, beside the package as Spite's testing guide describes. It needs MongoDB on
  `127.0.0.1:27017`, writes only to the `mongodb_probe` database (it also reads one document from
  `spite_kal.accounts`, if there is one) and drops it at the end. It ends with `passed true` and balanced
  allocations under `--debug-memory`.
- `examples/scoreboard/` is the README's complete example; keep the two identical.

## Checking a change

`bash check.sh` refuses em dashes and spaced double hyphens in every tracked file, then compiles the probe and the
example with `--check`. When a server answers on `127.0.0.1:27017` it also runs both, the probe with
`--debug-memory`, and fails unless the probe prints `passed true` with as many frees as allocations. Without a
server it says the live run was skipped.

It finds the compiler through `SPITE` (the path of `bin/spite`), then `spite` on `PATH`, then
`../spite-language/bin/spite` and `../SpiteLanguage/bin/spite`. The Spite repository is
github.com/Mortaro/spite-language; read its `SPITE.md` before writing Spite.

For a local server: `docker run -d --name mongo -p 27017:27017 mongo:7`.

## Keeping up with Spite

Spite changes often and refuses old forms rather than warning. When the compiler rejects the driver, its error names
the new form; fix the driver and the docs together. Past migrations, for reference:

- One-argument `set_<name>(x)` reads as a setter (D315, D396), so the document's writers are `put_<type>`.
- Member templates that answer every element are plural: `map_keys()`, `map_names()`.
- No `from_` functions (D293): the codec converts with `to_document` and `to_value`.
- A class may not hide another (D374, D387): the memory helper is `Mongo.RawMemory`, since a `Mongo.Raw` hides a
  root `Raw` in any program that has one.

Report compiler bugs to the "Language implementation review" session.

## Writing

No em dashes anywhere (code, comments, docs, commit messages), and no two hyphens between spaces standing in for
one: end the sentence, or use a colon, a comma or parentheses. User pages live in `docs/` in the README's reading
order, and each ends with a `Next:` link; notes for maintainers stay here.

## Commits

The same conventions as the Spite language repository: one gitmoji, then a lowercase imperative summary, ending
with the model that wrote it:

```
Co-authored-by: Claude Opus 5.5 <noreply@anthropic.com>
```

`scripts/hooks/commit-msg` rejects a message without the gitmoji, the lowercase summary or that trailer, or with an
em dash; each clone runs `git config core.hooksPath scripts/hooks` once.
