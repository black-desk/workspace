<!--
SPDX-FileCopyrightText: 2025 Chen Linxuan <me@black-desk.cn>

SPDX-License-Identifier: MIT
-->

# Workspace

[![checks][badge-shields-io-checks]][actions]
[![commit activity][badge-shields-io-commit-activity]][commits]
[![contributors][badge-shields-io-contributors]][contributors]

[badge-shields-io-checks]:
  https://img.shields.io/github/check-runs/black-desk/workspace/master

[actions]: https://github.com/black-desk/workspace/actions

[badge-shields-io-commit-activity]:
  https://img.shields.io/github/commit-activity/w/black-desk/workspace/master

[commits]: https://github.com/black-desk/workspace/commits/master

[badge-shields-io-contributors]:
  https://img.shields.io/github/contributors/black-desk/workspace

[contributors]: https://github.com/black-desk/workspace/graphs/contributors

en | [zh_CN](README.zh_CN.md)

> [!WARNING]
>
> This English README is translated from the Chinese version using AI and may
> contain errors.

My workspace directory.

## Usage

1. Use gh to clone the repository:

   ```bash
   gh repo clone black-desk/workspace
   ```

2. Use `scripts/setup.sh` to pull a specific project:

   ```bash
   ./scripts/setup.sh -D
   ./scripts/setup.sh repositories/linux
   ```

## License

Unless otherwise specified, the code of this project are open source under the
GNU General Public License version 3 or any later version, while documentation,
configuration files, and scripts used in the development and maintenance process
are open source under the MIT License.

This project complies with the [REUSE specification].

You can use [reuse-tool](https://github.com/fsfe/reuse-tool) to generate the
SPDX list for this project:

```bash
reuse spdx
```

[REUSE specification]: https://reuse.software/spec-3.3/
