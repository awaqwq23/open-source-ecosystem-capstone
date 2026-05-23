# Luotopia App

## 本地配置

Flutter 应用启动时必须读取项目根目录下的 `.env`。首次运行先复制 `.env.example` 为 `.env`，再按运行环境修改后端地址。

Android 模拟器访问宿主机服务端时可使用：

```env
LUOTOPIA_API_BASE_URL=http://10.0.2.2:8080
```

实体机调试时改为电脑在同一局域网内的地址，例如：

```env
LUOTOPIA_API_BASE_URL=http://192.168.1.23:8080
```
