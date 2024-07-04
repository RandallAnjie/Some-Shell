# `pve` 端口转发配置脚本

## 使用说明

这个脚本适配了 `pve` 实现端口转发的功能

## 使用方法

### 列出当前端口转发

```shell
curl -s https://git.randallanjie.com/Randall/Some-Shell/raw/branch/main/pve/port_forward/port_forward.sh | bash -s list
```

### 添加端口转发

1. 添加 `ipv4` 端口转发

```shell
curl -s https://git.randallanjie.com/Randall/Some-Shell/raw/branch/main/pve/port_forward/port_forward.sh | bash -s add ipv4 1822 10.0.18.2 22
```

2. 添加 `ipv6` 端口转发

```shell
curl -s https://git.randallanjie.com/Randall/Some-Shell/raw/branch/main/pve/port_forward/port_forward.sh | bash -s add ipv6 1822 fd00:18::2 22
```
### 删除端口转发

1. 删除 `ipv4` 端口转发

```shell
curl -s https://git.randallanjie.com/Randall/Some-Shell/raw/branch/main/pve/port_forward/port_forward.sh | bash -s delete ipv4 1822 10.0.18.2 22
```

2. 删除 `ipv6` 端口转发

```shell
curl -s https://git.randallanjie.com/Randall/Some-Shell/raw/branch/main/pve/port_forward/port_forward.sh | bash -s delete ipv6 1822 fd00:18::2 22
```

### 修改端口转发

1. 修改 `ipv4` 端口转发

```shell
curl -s https://git.randallanjie.com/Randall/Some-Shell/raw/branch/main/pve/port_forward/port_forward.sh | bash -s modify ipv4 1822 1823 10.0.18.2 22
```

2. 修改 `ipv6` 端口转发

```shell
curl -s https://git.randallanjie.com/Randall/Some-Shell/raw/branch/main/pve/port_forward/port_forward.sh | bash -s modify ipv6 1822 1823 fd00:18::2 22
```

