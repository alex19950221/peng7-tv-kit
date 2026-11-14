# 单台雷鸟鹏 7 Pro 的验证记录

验证日期：2026-11-12。型号：雷鸟鹏 7 Pro 65 英寸、3GB+64GB；系统设备名 `tcl_mt5879_cn`，Android 11 / API 30，ABI `armeabi-v7a`。这不是跨机型兼容保证，也不是最新版本推荐清单。

| 组件 | 版本与包名 | 实测 |
| --- | --- | --- |
| Aerial 定制版 | `1.95-peng7.1-guard` / `app.orchard.tv` | 桌面及「影音与网络」页面显示正常；启用守护后 HOME 返回，原有助手服务保留 |
| Clash Meta | `2.11.37.Meta` / `com.github.metacubex.clash.meta` | VPN 与实际联网通过；YouTube 视频域名匹配日本组，Apple TV 服务域名匹配美国组 |
| Apple TV | `17.0.2` / `com.apple.atve.androidtv.appletv` | 实际正片播放，使用者确认画面、声音正常 |
| YouTube Android TV | `8.02.300` / `com.google.android.youtube.tv` | 显示设备不支持，移除 |
| SmartTube | stable `32.71`、beta `32.74` | 列表可加载，试播出现 403 与 WebView renderer crash；网络引擎切换未解决，未将二者直接认定为因果 |
| YouTube Fire TV | `25.50.r1.v197.0` / `com.amazon.firetv.youtube` | 访客模式触发登录验证；使用者自行操作后实际视频播放，确认画面、声音正常 |

YouTube Fire TV 是 Google 针对 Fire TV 的官方发行版本。在这台雷鸟上的成功是实测结果，不表示 Google 官方支持雷鸟机型。普通 YouTube 与美国付费直播服务 YouTube TV 是不同产品。

## 应用来源与原签名

- Clash：[MetaCubeX 官方 Releases](https://github.com/MetaCubeX/ClashMetaForAndroid/releases)。
- Apple TV：[Google Play 应用页](https://play.google.com/store/apps/details?id=com.apple.atve.androidtv.appletv)。历史安装使用 APKMirror 的 17.0.2 原始分包；证书 SHA256 为 `771d8674d3d9837c9edf11b11873443998f19105abcecab425ed9b8e6fefff9b`。本仓库不提供分包或一次性安装助手。
- YouTube Fire TV：[Amazon 官方介绍](https://www.aboutamazon.com/news/devices/can-i-watch-youtube-on-fire-tv)、[历史安装包页面](https://www.apkmirror.com/apk/google-inc/youtube-for-fire-tv/youtube-for-fire-tv-25-50-r1-v197-0-release/youtube-for-fire-tv-25-50-r1-v197-0-android-apk-download/)。该版本 APK SHA256 为 `93f2f9c810a66c30158c02c07a0b78fd0bd2ef6665b2b9c580c76ced1240c1f8`，证书 SHA256 为 `21bd252aa5d6f8fa71792a430f7e9c1bf6b71797b8c5a5033f806036f46f0c49`。这些值只用于识别当时的文件，签名一致不能单独证明兼容或安全。

后续安装须重新核对来源、架构和签名，不能假定旧版本永远可用。

## 尚未验证

4K/HDR/杜比格式、长时间稳定性、晚高峰表现、重启和待机后的桌面与 VPN 状态、HDMI、原厂会员完整回归，以及定制页面连接／断开 Clash 的真机完整循环。没有测量真机帧率、启动耗时或内存优化效果。
