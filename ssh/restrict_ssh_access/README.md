# SSH 访问限制脚本

该脚本限制SSH访问（端口22）到指定的IPv4和/或IPv6地址。它会删除现有的22端口规则，并添加新规则以仅允许来自指定IP地址的访问。该脚本支持`ufw`和`iptables`。如果两者都没有安装，它将安装`iptables`并配置必要的规则。

## 用法

使用`curl`运行脚本，并将所需的IPv4和IPv6地址作为参数传入：

```bash
curl -s https://git.randallanjie.com/Randall/Some-Shell/raw/branch/main/ssh/restrict_ssh_access/restrict_ssh_access.sh | bash -s -4 <IPv4地址> -6 <IPv6地址>
```

## 参数

- `-4`: 允许SSH访问的IPv4地址。
- `-6`: 允许SSH访问的IPv6地址。

## 脚本流程

- 脚本检查是否安装了ufw或iptables。
- 如果安装了ufw，则调用configure_ufw()。
- 如果安装了iptables，则调用configure_iptables()。
- 如果都没有安装，则安装iptables并配置规则。

## 注意事项
- 修改防火墙规则需要根权限。
- 确保您指定了有效的IPv4和/或IPv6地址作为参数。
- 脚本不会修改其他现有的防火墙规则，仅修改与22端口相关的规则。