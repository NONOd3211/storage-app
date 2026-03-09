# Android 上架最小闭环（Google Play）

## 1. 准备签名文件（只做一次）

在项目根目录执行：

```bash
cd android
keytool -genkeypair -v \
  -keystore app/upload-keystore.jks \
  -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000
```

## 2. 配置 key.properties

```bash
cp android/key.properties.example android/key.properties
```

填写以下字段：

- `storePassword`
- `keyPassword`
- `keyAlias`
- `storeFile`

## 3. 版本号（每次发布递增）

在 `pubspec.yaml` 使用：

- `x.y.z+n`（例如 `1.2.2+2`）
- `x.y.z` 显示给用户
- `n` 对应 Android `versionCode`，必须递增

## 4. 构建 AAB（上架包）

```bash
flutter pub get
flutter build appbundle --release
```

产物路径：

- `build/app/outputs/bundle/release/app-release.aab`

## 5. Play Console 必填项

- App content（内容分级、广告声明、目标受众）
- Data safety（数据安全）
- 隐私政策 URL
- 商店文案、截图、应用图标、Feature Graphic

## 6. 上架前检查

- 安装内测包验证核心流程
- 通知权限流程可用
- 首次启动与升级迁移正常
- `versionCode` 已递增
