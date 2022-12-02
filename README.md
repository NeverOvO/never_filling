# never_filling

macOS下配合命令行，进行文件批量移动操作

功能单一，使用非常简单

# 关于重名文件

1:如果选择不保留，那么重名文件之后剩下最后一个 

2:如果选择保留，则所有文件名后会被添加 _序号，例如 test.txt ==> test_1.txt


# 界面

图为开发Demo，独立发布后有修改，请依据最终应用为准

Demo：https://github.com/NeverOvO/learningfoundation

![IMG_9703](https://user-images.githubusercontent.com/34906510/204123038-6f682497-f8e6-44b1-9faf-707fa16375bc.JPG)


# 注意

请勿在根目录下执行，请确认数据路径正确，移动文件操作不可逆，请对自己的数据负责。



## 更新日志

### 2022/12/02
    -  优化命令行的语句拼接与处理，适应更多的文件、文件夹名称
    -  优化操作逻辑，减少不必要操作