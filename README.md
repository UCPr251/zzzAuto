# 绝区零零号业绩刷取脚本

## 简介

- 针对 **旧都列车·前线**、 **拿命验收** 关卡设计
- 基于 [**AutoHotKey v2**](https://www.autohotkey.com) 实现的 **零号业绩** 、 **零号空洞银行存款** 、 **丁尼** 自动刷取
    > 业绩约2分钟一把，可获得30业绩+银行存款，1小时+就能刷满一周900业绩上限并拿满周任务奖励
    > 丁尼约30秒一把，可获得80丁尼，每小时可刷取80+次约7k丁尼；每个服务器日刷取上限为625次（5w丁尼整，约需8h）
- 支持多比例 **全屏** 或 **窗口** 运行
- 简单轻量易用，对于不同 **分辨率、帧率、缩放、HDR、字体等** 具有良好的适应性

## 使用前提

### 零号空洞

- 1. 默认 **3位及以上** 战斗角色
- 2. 已激活作战攻略的 **开局炸弹补给**

### 拿命验收

- 1. HDD关卡选择界面需提前切换至 **间章第二章**
- 2. 默认编队首位必须为 **比利**，第二位推荐鲨鱼妹
- 3. 请在副本内调整 **视角转动值** 以确保对齐NPC

## 下载方法

> PS: 程序报毒系正常现象，担心的话可以跑源码或者自行编译，怕别用用别怕

选择其一即可：

- 方法一（下载即用，懒人最爱）：

    [<<<点击进入>>>](https://gitee.com/UCPr251/zzzAuto/releases/latest)release最新版本，下载并运行该exe文件

- 方法二（适合想要diy的用户）：

    克隆/下载源码（需已安装好[autohotkey](https://www.autohotkey.com) v2版解释器），运行[零号业绩.ahk](./零号业绩.ahk)文件

## 使用方法

- Alt+P ：暂停/恢复刷取，快捷指令，也可通过控制面板修改
- Alt+C ：打开/关闭[控制面板](./控制面板.jpg)，相关信息：
    > **休眠系数**：调整脚本在加载动画时的等待时长倍率
    > <br>**异常重试次数**：允许异常后尝试重试/重启的总次数，发生异常后值减一，双击可查看历史异常
    > <br>**颜色搜索允许RGB容差**：过大可能误点，过小可能匹配失败，按需调整
    > <br>**视角转动值**：丁尼模式下进入副本后的视角转动值，首次运行时请调整该值以确保对齐NPC：转动幅度过大则需减小，反之则需增大。游戏内转动效果有浮动系正常现象
    > <br>**使用炸弹**：修改走格子邦布插件快捷使用方式，请保持和游戏内一致：长按/点击
    > <br>**快捷手册**：修改打开快捷手册的快捷键，默认F2
    > <br>**战斗模式**：通用·普通攻击（一直A） / 艾莲
    > <br>**刷取模式**：业绩+银行 / 只要业绩 / 只存银行
    > <br>**循环模式**：选择 刷至达上限 / 无限循环 / 指定次数
    > <br>**异常处理**：关闭后，任何意料之外的情况都将直接结束刷取并抛出错误，用于排查错误
    > <br>**步骤信息弹窗**：是否输出刷取过程中每个步骤的信息弹窗，用于排查错误
    > <br>**刷完关闭游戏**：业绩/丁尼达上限/达指定刷取次数 时关闭游戏；开启无限循环后此项无效
    > <br>**战斗红光自动闪避**：开启此模式后：业绩模式战斗期间会识别红光进行闪避；战斗期间CPU占用会略微提高；代理人事件会选择取消接应。效果受RGB容差影响，推荐在战斗时长>30s（游戏内计时，不含动画）的情况下开启，自行测试按需开关
    > <br>**退出**：退出脚本
    > <br>**重启**：重启脚本，修改缩放、分辨率后建议重启脚本
    > <br>**暂停**：暂停当前刷取线程，可使用Alt+P快捷暂停/恢复
    > <br>**刷取统计**：刷取次数、总计耗时、平均战斗耗时、平均刷取耗时、每次刷取详情
    > <br>**开始刷取**：开始循环刷取，默认情况下会一直刷取直至零号业绩达到周上限
    > <br>**本轮结束**：在当前执行的刷取任务完成后结束循环刷取

<details>
<summary>控制面板</summary>

<p align="center">
    <img width="400" src="控制面板.jpg" title="控制面板">
</p>

</details>

## 后台刷取教程

使用Windows多用户远程桌面连接，可实现后台独立刷取而不影响前台操作（即刷取的同时正常使用电脑）。建议有后台刷取需求且 **有一定电脑基础** 的用户尝试，具体可参考[此教程](https://github.com/sMythicalBird/ZenlessZoneZero-Auto/wiki/Windows%E5%A4%9A%E7%94%A8%E6%88%B7%E5%90%8C%E6%97%B6%E8%BF%9C%E7%A8%8B%E6%9C%AC%E5%9C%B0%E6%A1%8C%E9%9D%A2)

远程连接进入游戏后：

- 由于不同电脑用户的脚本数据独立，启动脚本后请注意重新设置参数

- 建议修改游戏显示模式为 **1280*720窗口** ，画面质量等调整至最低，以减少资源占用

> 网络上相关教程众多，如遇问题请先使用搜索引擎搜索，若搜索无果可issue提问

<details>
<summary>后台刷取示例</summary>

<p align="center">
    <img src="后台刷取示例.jpg" title="后台刷取示例">
</p>

</details>

## 注意事项

1. 本脚本基于固定坐标和像素点颜色查找实现，设计分辨率比例：**21:9、16:9、16:10、4:3、5:4**，应已满足大部分情况。
<br>如果脚本无法正常运行，建议 **显示器和游戏** 的画面分辨率设置为 **长宽比16:9** 且 **关闭HDR等** 重新运行脚本

2. 若脚本仍无法正常运行，请提出[issue](https://gitee.com/UCPr251/zzzAuto/issues/new?template=bug.yml)并按照要求描述提供所需信息

3. 数据文件路径： **C:/Users/用户名/Documents/autoZZZ.ini**，启动脚本后自动生成

4. 由于电脑配置的差异，实际动画加载时长可能与预设数据不符，可微调 **休眠系数** 延长全局的等待时长
    > 不建议减小该值，压缩不了多少时间反而容易引发问题

5. 业绩模式下战斗模式可选通用或鲨鱼妹，只要哪怕一直a都能S评价即可
    > 战斗时长一般在15~50s以内（游戏内计时，不含动画），超过30s建议开启战斗红光自动闪避试试看

6. 丁尼模式下建议提前取消任务追踪，减少传送时识别地图耗时

7. 为避免消息弹窗等的影响，建议在脚本运行期间开启 **免打扰模式**

8. 请勿在脚本运行期间操作键鼠，若需操作请先暂停脚本： **Alt+P**

9. 本脚本完全免费公开， **严禁用于任何商业用途** ，仅供学习交流使用
