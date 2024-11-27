## Change Source Script
这个脚本用于在不同的 Linux 发行版（Ubuntu、Debian、CentOS）上更换软件源。您可以选择清华大学、阿里云、科大或官方源，默认使用官方源。

## 功能
自动检测系统发行版：适用于 Ubuntu、Debian 和 CentOS。
选择源：提供四种源选择：官方，清华大学，阿里云和科大。
源替换：根据选择自动更新系统源配置文件。

## 使用方法

- 运行脚本：
方式1 (wget):
```bash
wget -qO- https://git.randallanjie.com/Randall/Some-Shell/raw/branch/main/changeSource/changeSource.sh | sudo bash
```

方式2 (curl):
```bash
curl -s https://git.randallanjie.com/Randall/Some-Shell/raw/branch/main/changeSource/changeSource.sh | sudo bash
```

需要超级用户权限（sudo）来修改系统配置文件。

- 选择源：
脚本会提示您选择源，输入相应的数字选择（1-官方，2-清华，3-阿里云，4-科大），默认是1（官方）。

**警告**
- 备份：在运行此脚本前，强烈建议备份现有的源配置文件。脚本会自动备份，但备份额外一份以防万一。
- 兼容性：脚本适用于主流版本，但特殊或较旧的版本可能需要手动调整。
- 更新：更换源后，确保运行 apt-get update 或 yum clean all && yum makecache 来刷新软件包缓存。

## 源列表
- Ubuntu：
1. 官方：archive.ubuntu.com/ubuntu/
2. 清华：mirrors.tuna.tsinghua.edu.cn/ubuntu/
3. 阿里云：mirrors.aliyun.com/ubuntu/
4. 科大：mirrors.ustc.edu.cn/ubuntu/
- Debian：
1. 官方：deb.debian.org/debian
2. 清华：mirrors.tuna.tsinghua.edu.cn/debian/
3. 阿里云：mirrors.aliyun.com/debian/
4. 科大：mirrors.ustc.edu.cn/debian/
- CentOS：
1. 官方：mirror.centos.org/centos
2. 清华：mirrors.tuna.tsinghua.edu.cn/centos/
3. 阿里云：mirrors.aliyun.com/centos/
4. 科大：mirrors.ustc.edu.cn/centos/
