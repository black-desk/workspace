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

[en](README.md) | zh_CN

我的工作目录。

## 使用

1. 使用gh克隆库：

   ```bash
   gh repo clone black-desk/workspace
   ```

2. 使用`scripts/setup.sh`拉取某个项目：

   ```bash
   ./scripts/setup.sh -D
   ./scripts/setup.sh repositoires/linux
   ```

## 许可证

如无特殊说明，该项目的代码以GNU通用公共许可协议第三版或任何更新的版本开源，文档、配置文件以及开发维护过程中使用的脚本等以MIT许可证开源。

该项目遵守[REUSE规范]。

你可以使用[reuse-tool](https://github.com/fsfe/reuse-tool)生成这个项目的SPDX列表：

```bash
reuse spdx
```

[REUSE规范]: https://reuse.software/spec-3.3/
