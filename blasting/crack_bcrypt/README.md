## bcrypt 哈希值破解脚本

> 本脚本用于尝试暴力破解 bcrypt 哈希值对应的密码。它支持自定义字符集（包含或不包含特殊字符）和最大密码长度，并实时展示破解进度。

### 用法

```Bash
curl -s https://git.randallanjie.com/Randall/Some-Shell/raw/branch/main/blasting/crack_bcrypt/crack_bcrypt.sh | bash -s -- -b <hash_value> -c <charset_option> -l <max_length>
```

- -b <hash_value>：要破解的 bcrypt 哈希值。
- -c <charset_option>：字符集选项。
    - 1：包含大小写字母、数字和特殊字符
    - 2：仅包含大小写字母和数字
- -l <max_length>：密码最大长度。

### 示例

```Bash
curl -s https://git.randallanjie.com/Randall/Some-Shell/raw/branch/main/blasting/crack_bcrypt/crack_bcrypt.sh | bash -s -- -b '$2b$10$czsMTOTzD/0MRyjDxQJt3eshx3r5aRrVe7owMYb48SbFcd4MbtU8G' -c 1 -l 15
```

此命令将尝试使用包含特殊字符的字符集，最大密码长度为 15，破解给定的 bcrypt 哈希值。

### 输出

脚本运行时会实时显示破解进度，包括：

- 进度百分比
- 已尝试的密码个数
- 已耗时
- 预计剩余时间
- 如果找到匹配的密码，会输出找到的密码、尝试次数和总耗时。如果未找到匹配的密码，会输出尝试次数和总耗时。

### 注意事项

- 暴力破解非常耗时。 Bcrypt 算法设计初衷就是为了抵御暴力破解，因此破解过程可能需要很长时间，特别是当密码较长或字符集较大时。
- 请勿用于非法用途。 请仅在授权的情况下使用此脚本。
- 进度估计可能不准确。 由于破解过程的随机性，预计剩余时间只是一个粗略估计，仅供参考。

### 依赖

- bcrypt 命令行工具