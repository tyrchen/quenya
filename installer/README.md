# QuenyaInstaller

Creates a new Quenya project.

It expects the path of the project as an argument.

```bash
mix quenya.new SPEC PATH [--module MODULE] [--app APP]
```

A project at the given PATH will be created based on the spec.
The application name and module name will be retrieved
from the path, unless `--module` or `--app` is given.

For more information, see `lib/mix/tasks/quenya.new.ex`.

## Installation

You can build and install the installer yourself:

```bash
mix archive.build
mix archive.install
```

Or you can use the official binary:

```bash
mix archive.install https://github.com/quenya/quenya/installer/quenya_installer.ez
```
