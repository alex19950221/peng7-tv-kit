# 构建定制桌面

准备 Git、PowerShell 7、JDK 17（或经验证兼容的版本）、Android SDK Platform 36、Build Tools 36 和 Python 3。首次构建需要下载 Gradle 与 Maven 依赖。

## 准备固定版本源码

```powershell
pwsh -File scripts/prepare-aerial.ps1
Set-Location .work/aerial-tv
```

脚本下载锁定提交、核对提交 ID 和补丁摘要，通过 `git apply --check` 后应用补丁。默认目录 `.work/` 被忽略；目标目录非空时直接停止，避免覆盖已有工作。可用 `-SourceRepository` 指定已存在的本地 Aerial Git 仓库，以离线准备源码。

在生成的源码目录设置 `JAVA_HOME`、`ANDROID_HOME`，并将 SDK 路径写入忽略的 `local.properties`。不要将本机路径提交回此项目。

## 使用自己的签名

在生成的 Aerial 源码下创建 `local/`，通过 JDK 的交互提示生成签名密钥：

```powershell
New-Item -ItemType Directory -Force local | Out-Null
keytool -genkeypair -keystore local/release.keystore -alias release -keyalg RSA -keysize 3072 -validity 10000
```

自行创建 `local/signing.properties`，填写本地密钥的真实密码：

```properties
storeFile=release.keystore
storePassword=CHANGE_ME
keyAlias=release
keyPassword=CHANGE_ME
```

签名文件不会随此项目分发。使用者应保管自己的密钥；以后升级需使用同一签名并增加版本号。上游在缺少签名配置时会回落到 debug 签名，所以发布前必须确认使用了自己的 release 密钥。

## 构建与验证

```powershell
.\gradlew.bat :app:testStandardDebugUnitTest --tests 'app.orchard.tv.system.MediaShortcutsTest' --tests 'app.orchard.tv.ui.control.MediaToolsPageTest' --tests 'app.orchard.tv.update.LocalEditionTest'
.\gradlew.bat :app:assembleStandardRelease :app:assembleGuardRelease
```

生成文件在 `app/build/outputs/apk/{standard,guard}/release/`。发布 APK 前用 SDK 的 `apksigner verify --verbose --print-certs` 验证签名，并计算 SHA256。

`standard` 声明 HOME，`guard` 不声明 HOME。本机使用 Guard，但其他电视须按自己的安装限制判断。与已有官方 Aerial 签名不同时不能直接覆盖安装；不要为了安装而自动删除已有桌面数据。

## 本次打包验证范围

本项目保存的是已经测试过的 `1.95-peng7.1` 代码，未在公开整理时新增桌面功能。历史验证包括选取的 32 项单测、Standard/Guard Release 构建和指定真机验证。本轮公开整理检查补丁可应用、文件一致性、PowerShell 语法和示例配置；不把打包检查当作新增真机测试。

YouTube 在桌面上作为普通应用排序，本补丁的「影音与网络」页面目前没有新增 YouTube 专用按钮。
