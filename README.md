# Peng7 TV Kit

雷鸟鹏 7 Pro 的 Aerial 桌面定制与影音配置参考。基于一台 Android 11、32 位 ARM 的电视实测，提供可复现的源码补丁和不含真实节点的分流示例。

这是 Android 电视桌面与应用配置项目，不是刷机 ROM，也不会把电视变成 Apple tvOS。项目不是 Aerial、TCL、Apple 或 Google 的官方产品。

## 包含什么

- **Aerial 定制补丁**：控制中心增加「影音与网络」，可打开已安装的 Apple TV、Clash Meta，以及发送明确的连接／断开命令。使用者自行签名，定制版关闭上游自动更新，避免签名和版本冲突。
- **电视检查脚本**：读取型号、ABI、系统版本及现有设置，报告仅写入忽略的 `local/`。
- **Mihomo 分流示例**：YouTube 相关域名使用日本组，Apple TV 相关域名使用美国组；节点、密码均为占位值。
- **机型记录和安装说明**：区分已经验证的行为与仍待验证的项目，保留原桌面及其他系统应用。

不包含第三方 APK、会员账号、代理订阅、真实服务器、签名私钥、电视地址、日志或登录二维码。YouTube 是普通视频服务，不是美国付费直播套餐 YouTube TV。

## 从这里开始

1. 阅读 [设备与兼容性记录](docs/COMPATIBILITY.md)，确认自己的机型和固件。
2. 已满足需求时，可直接使用 [Aerial 上游](https://github.com/pengchujin/aerial-tv)。需要本项目的快捷控制时，按 [构建说明](docs/BUILD.md) 应用补丁并自行签名。
3. 按 [安装与还原说明](docs/SETUP.md) 逐项配置。不同固件的安装方式可能不同，不提供通刷或批量提权脚本。
4. 按 [分流说明](docs/ROUTING.md) 配置自己的客户端。不要直接上传正在使用的订阅配置。

```powershell
# PowerShell 7；只准备电脑上的源码，不操作电视
pwsh -File scripts/prepare-aerial.ps1
```

源码基线由 `upstream.lock.json` 固定；当前为 Aerial 1.95 的提交 `a0f4b59c5a76a0a549410154d7009399d45b5a22`。本项目没有自动追随上游最新版本，升级需要重新检查补丁和真机行为。

## 实测摘要

2026-11-12，在雷鸟鹏 7 Pro 65 英寸、3GB+64GB、`tcl_mt5879_cn`、Android 11 / API 30、`armeabi-v7a` 上：

| 项目 | 结果 |
| --- | --- |
| Aerial `1.95-peng7.1-guard` | 桌面与新增页面显示正常；HOME 返回已验证 |
| Clash Meta `2.11.37.Meta` | VPN 已连接，实际流量分流已核对 |
| Apple TV `17.0.2` | 实际播放，使用者确认画面和声音正常 |
| 官方 YouTube Fire TV `25.50.r1.v197.0` | 实际播放，使用者确认画面和声音正常 |
| 4K、HDR、杜比、重启／待机后状态 | 未完成验证 |

此处是单台设备、指定日期和版本的结果，不代表所有雷鸟电视或后续版本都兼容。失败的客户端尝试也记录在兼容性文档中。

## 分享与维护

公开文件采用明确清单 `public-files.txt`。本地修改后运行：

```powershell
python scripts/check-public.py
python scripts/package-public.py
```

检查通过后生成的 ZIP 位于忽略的 `dist/`，只包含清单内文件。自动检查不能代替人工审阅；配置只在 `local/` 中填写真实信息，上传 issue 前检查截图和日志。

补丁和脚本遵循 [MIT 许可](LICENSE)，保留 Aerial 原作者声明。外部应用、字体及其他上游资源的许可见 [第三方说明](THIRD_PARTY_NOTICES.md)。
