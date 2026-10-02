# Errors and commands

## What failure looks like

Nothing the server or the network does crashes your program. A function that could not do its work answers its
type's empty value (`false`, `0` or `null`) and leaves the reason in `client.error`, which every command clears when
it starts:

```gdscript
var inserted = players.insert_one(twin)
if not inserted {
    console.print("not stored:", client.error)
}
```

The reasons are the server's own words where it gave some (`E11000 duplicate key error ...`,
`no such command: 'noSuchCommand'`) and the driver's otherwise:

| `client.error` | Meaning |
| --- | --- |
| `could not connect to <host>:<port>` | no socket could be opened |
| `could not send the command to <host>:<port>` | the socket broke while writing |
| `the server closed the connection` | the socket closed before the whole reply arrived |
| `the server sent an unexpected reply` | the reply's header was not an answer to this command (or claimed more than 48 MB) |
| `the reply has no body section`, `the reply is not valid BSON` | the reply could not be read |
| `the command failed` | the server answered `ok: 0` without a message |

A socket that failed in any of these ways is closed rather than reused. The driver reads everything the server
sends as untrusted: every length is checked against the bytes actually received, so a malformed or hostile reply is
an error, never a crash or a read past the buffer.

A mistake in your own program is different: Spite crashes on it with the line that made it, as everywhere else.

## Running any command

`client.run_command(database, command)` sends any command document and answers the server's reply, or `null` with
`client.error` set when the reply is `ok: 0` or carries write errors:

```gdscript
var command = Mongo.Document()
command.put_text("create", "players")
var reply = client.run_command("game", command)
```

The command's name must be the first key, as MongoDB requires; the driver adds `$db` itself. `drop_database(name)`
is one such command, answering whether it worked.

That is the whole driver. To work on it, see [CLAUDE.md](../CLAUDE.md).

Next: back to the [README](../README.md).
