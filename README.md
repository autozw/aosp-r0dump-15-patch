# R0DUMP Fusion patch for AOSP 15 / Pixel 6 Pro

本目录归档了已经编译验证的 R0dump 融合版源码改动，目标为 Android 15 `android-15.0.0_r14`、`AP4A.250205.002`、`aosp_raven-ap4a-userdebug`。**`r0dump-aosp15-raven-fusion.patch` 是从 AOSP 根目录应用的完整补丁，已包含 R0dump 管理器**，以及 ART、Framework、libcore 桥接、SELinux、文件 helper、MCP 桥接和 raven 产品安装配置。

这里归档的是已落实的 DEX 融合版本。后来讨论的 `dumpdp` / 通用 SO 修复尚未并入该源码，因此不包含在此补丁中。

## 文件

- `r0dump-aosp15-raven-fusion.patch`：一次性整体补丁，174 个文件。
- `patches/0001` 至 `0006`：按 AOSP 子仓库拆分的同一改动，方便定位冲突。整体补丁已包含它们，**不要再重复应用拆分补丁**。
- `apply.sh`：先核对本目录的 SHA-256，再执行 `git apply --check`；只有明确使用 `--apply` 才会修改目标源码。
- `metadata/package.json`：补丁顺序、子仓库路径和基线提交。`metadata/source-manifest.json`：本次用户工作树中的原始文件前后哈希。
- `metadata/original-raven-working-tree.patch`：归档原产品文件上的小补丁，仅用于追溯。正式整包使用 `0006` 的可移植插入位置。
- `docs/`：实现验证报告和刷入后使用说明。`validation/`：主机测试 XML、源码契约结果和最后一次构建日志。
- `validation/final-package-validation.json`：两种基线上的整体补丁脚本实测结果，包括重复应用保护。

## 在另一份 AOSP 15 源码上使用

先阅读 `metadata/package.json` 中的基线提交和目标产品设置，并备份目标源码。脚本会在已有 R0dumpManager 时停止，也会在任一补丁片段无法应用时停止；它不会自动解决不同 Android 版本的 API 差异。

```bash
cd /path/to/aosp-r0dump-15-patch
bash apply.sh --check /path/to/aosp-15
bash apply.sh --apply /path/to/aosp-15
```

当前 `/media/zwzw/AOSP/new-15` 已经融合了这些改动，不要再次应用。`--check` 只适用于尚未安装 R0dumpManager 的目标树。

整包在临时树中核验过两种基线：本次保存的用户工作树，以及 `metadata/package.json` 所列的干净子仓库提交。两者的 `git apply --check`、实际应用和反向检查均通过。用户工作树应用后的 173 个非产品文件与已融合源码逐字相同；产品文件仅将同一 `inherit-product` 语句放在更通用的位置。干净基线上已有 4 个文件原本就与用户工作树不同，补丁没有把那些用户原有改动带进去。**干净基线只验证了补丁可应用，未重新编译整机。**

编译方式：

```bash
cd /path/to/aosp-15
source build/envsetup.sh
lunch aosp_raven-ap4a-userdebug
m -j8 droid art_runtime_tests r0dump_file_helper_tests
```

产品配置引用 `packages/apps/R0dumpManager/product.mk`。如果未来用于别的设备，需在该设备的产品 makefile 中引入这个文件，并重新验证 SELinux、ART、Framework 和 libcore 的版本兼容。不要直接把 raven 专用产品补丁套到别的设备。

当前源码的整机构建、ART 主机测试和 helper 主机测试结果见 `docs/融合实现与验证报告.md`。本包不含镜像、签名密钥和厂商专有文件；`metadata/build-artifacts.json` 仅记录本次构建产物的路径和哈希。
