# Working on spite_mongodb_driver

A MongoDB driver written in Spite, with no dependency on any engine: any Spite program can `load` it.

- The package is `mongodb/`, whose `mongo/` folder is the namespace `Mongo`. Load it with
  `load "<path>/spite_mongodb_driver/mongodb"`.
- `mongodb_probe/` is its test program, beside the package as Spite's testing guide describes. It needs MongoDB on
  `127.0.0.1:27017`, writes only to the `mongodb_probe` database and drops it at the end. Run it with
  `D:/Projects/SpiteLanguage/bin/spite mongodb_probe --debug-memory`; it ends with `passed true` and balanced
  allocations.
- Report compiler bugs to the "Language implementation review" session.

## Commits

The same conventions as the Spite language repository: one gitmoji, then a lowercase imperative summary, ending
with the model that wrote it:

```
Co-authored-by: Claude Opus 5.5 <noreply@anthropic.com>
```

`scripts/hooks/commit-msg` rejects a message without that trailer; each clone runs
`git config core.hooksPath scripts/hooks` once.
