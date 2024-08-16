/************************************************************************
 * @description 绝区零零号空洞零号业绩自动刷取、自动银行存款脚本
 * @file 零号业绩.ahk
 * @author UCPr
 * @date 2024/08/17
 * @version v1.5.2
 * @link https://github.com/UCPr251/zzzAuto
 * @warning 请勿用于任何商业用途，仅供学习交流使用
 ***********************************************************************/
#Requires AutoHotkey v2
SetWorkingDir(A_ScriptDir)
CoordMode("Mouse", "Window")
CoordMode("Pixel", "Window")
SendMode("Input")
#SingleInstance Force
#WinActivateForce
SetControlDelay(1)
SetWinDelay(0)
SetKeyDelay(-1)
SetMouseDelay(-1)
#Include ./components
#Include coordsData.ahk
#Include charOperation.ahk
#Include choose.ahk
#Include common.ahk
#Include enterFuben.ahk
#Include exitFuben.ahk
#Include fight.ahk
#Include getMoney.ahk
#Include isLimited.ahk
#Include reachEnd.ahk
#Include recogLocation.ahk
#Include refuse.ahk
#Include saveBank.ahk

global Version := "v1.5.2"

/** 设置项 */
global setting := {
  /** 快捷手册 */
  handbook: 'F2',
  /** 炸弹使用：长按1，点击2 */
  bombMode: 1,
  /** 休眠系数，加载动画等待时长在原基础上的倍率，可通过修改该值延长/缩短全局等待时长 */
  sleepCoefficient: 1.0,
  /** RGB颜色搜索允许的渐变值 */
  variation: 60,
  /** 异常处理 */
  errHandler: true,
  /** 是否开启步骤信息弹窗 */
  isStepLog: true,
  /** 刷完业绩后是否自动关闭游戏 */
  isAutoClose: false,
  /** 是否开启银行模式 */
  bankMode: false,
  /** 是否存银行 */
  isSaveBank: true,
}

/** 刷取统计数据 */
global statistics := []
/** 结束标志 */
global nextExit := false
global ing := false
global CPGui := 0

init()

/** Alt+P 暂停/恢复线程 */
!p:: {
  MsgBox("已" (A_IsPaused ? "恢复" : "暂停") "脚本，再次Alt+P可切换状态", , "T1")
  Pause(-1)
}

/** Alt+C 控制面板 */
!c:: ControlPanel()

/** 控制面板 */
ControlPanel() {
  static paused
  global CPGui, nextExit, ing, setting
  if (CPGui) {
    CPGui.Destroy()
    CPGui := 0
    if (!paused) {
      Pause(0)
    }
    return
  }
  paused := A_IsPaused
  Pause(1)

  CPGui := Gui('AlwaysOnTop -MinimizeBox', '零号业绩控制面板 Alt+C')
  CPGui.SetFont('s9', '微软雅黑')
  CPGui.MarginX := 15
  CPGui.AddText('X70 w251', '分辨率：' A_ScreenWidth "x" A_ScreenHeight "   模式：" c.mode (c.compatible ? "(兼容)" : ""))
  CPGui.SetFont('s13')
  CPGui.AddText('X30 Y40', '使用炸弹：')
  CPGui.AddDropDownList("X+10 W60 Choose" setting.bombMode, ["长按", "点击"]).OnEvent("Change", (g, *) => setting.bombMode := g.Value)
  CPGui.AddText('X30 Y75', '快捷手册：')
  CPGui.AddEdit('X+10 w60 h25 Limit2', setting.handbook).OnEvent('Change', (g, *) => setting.handbook := Trim(g.Value))
  CPGui.AddText('X30 Y110', '休眠系数：')
  CPGui.AddEdit('X+10 w60 h25 Limit4', setting.sleepCoefficient).OnEvent('Change', changeSleepCoefficient)
  CPGui.AddText('X30 Y145', '颜色搜索允许渐变值：')
  CPGui.AddEdit('X+10 w60 h25 Limit3 Number').OnEvent('Change', changeVariation)
  CPGui.AddUpDown('Range0-255', setting.variation).OnEvent('Change', changeVariation)
  CPGui.AddCheckBox('verrHandler X30 Checked' setting.errHandler, '异常处理').OnEvent('Click', switchSetting)
  CPGui.AddCheckBox('visStepLog Checked' setting.isStepLog, '步骤信息弹窗').OnEvent('Click', switchSetting)
  CPGui.AddCheckBox('visAutoClose Checked' setting.isAutoClose, '刷完业绩自动关闭游戏').OnEvent('Click', switchSetting)
  CPGui.AddCheckBox('vbankMode Checked' setting.bankMode, '银行模式（无限循环刷取）').OnEvent('Click', switchSetting)
  CPGui.AddCheckBox('visSaveBank Checked' setting.isSaveBank, '银行存款（关闭后不再存银行）').OnEvent('Click', switchSetting)
  CPGui.SetFont('s12')
  CPGui.AddButton('X15 Y+15 w75', '退出').OnEvent('Click', (*) => ExitApp())
  CPGui.AddButton('X+5 w75', '重启').OnEvent('Click', (*) => Reload())
  CPGui.AddButton('X+5 w75', paused ? '继续' : '暂停').OnEvent('Click', pauseS)
  CPGui.AddButton('X+5 Default w75', '确定').OnEvent('Click', destroyGui)
  CPGui.AddButton('X15 Y+10 w100', '检查更新').OnEvent('Click', checkUpdate)
  CPGui.AddButton('X+8 w100', '刷取统计').OnEvent('Click', StatisticsPanel)
  CPGui.AddButton('X+8 w100', ing ? (nextExit ? '取消结束' : '结束刷取') : '开始刷取').OnEvent('Click', start)

  CPGui.Show()

  CPGui.OnEvent('Close', destroyGui)
  CPGui.OnEvent('Escape', destroyGui)

  destroyGui(*) {
    SaveSetting()
    setRatio() ; 更新RGB颜色搜索允许的渐变值
    CPGui.Destroy()
    if (!paused)
      Pause(0)
    CPGui := 0
  }

  switchSetting(g, *) {
    global setting
    setting.%g.Name% := !setting.%g.Name%
  }

  changeVariation(g, *) {
    value := g.Value
    if (value >= 0 && value <= 255) {
      setting.variation := value
    } else {
      MsgBox('颜色搜索允许渐变值须介于0~255', '错误', 'Iconx 0x40000')
      g.Value := setting.variation
    }
  }

  changeSleepCoefficient(g, *) {
    value := g.Value
    if (IsNumber(value)) {
      setting.sleepCoefficient := Round(value, 2)
    } else {
      MsgBox('休眠系数必须为数字类型', '错误', 'Iconx 0x40000')
      g.Value := setting.sleepCoefficient
    }
  }

  pauseS(g, *) {
    if (!ing) {
      return MsgBox("当前未处于刷取期间", , "Icon! 0x40000 T3")
    }
    if (paused) {
      Pause(0)
      destroyGui()
    } else {
      Pause(1)
      g.Text := "继续"
    }
    paused := !paused
  }

  start(g, *) {
    global ing, nextExit
    if (ing) {
      nextExit := !nextExit
      if (nextExit) {
        static once := 1
        if (once) {
          MsgBox("将在当前执行的步骤完成后结束本次刷取，结束后可再次启动", , "0x40000")
        }
        once := 0
        g.Text := "取消结束"
      } else {
        g.Text := "结束刷取"
      }
    } else {
      activateZZZ()
      destroyGui()
      main()
    }
  }

  checkUpdate(*) {
    static urls := ["https://gitee.com/UCPr251/zzzAuto/releases/latest", "https://github.com/UCPr251/zzzAuto/releases/latest"]
    err := 0
    for (url in urls) {
      try {
        hObject := ComObject("WinHttp.WinHttpRequest.5.1")
        hObject.SetTimeouts(1000, 1000, 5000, 5000)
        hObject.Open("GET", url)
        hObject.Send()
        hObject.WaitForResponse()
        text := hObject.responseText
        RegExMatch(text, "v\d+\.\d+\.\d+", &OutputVar)
      } catch Error as e {
        err := e
      }
      if (OutputVar.Len) {
        latestVersion := OutputVar[0]
        if (Version = latestVersion) {
          return MsgBox("当前已是最新版本：" latestVersion, , '0x40000 T3')
        } else {
          destroyGui()
          return Run(url)
        }
      }
    }
    if (err) {
      throw err
    }
  }

}

/** 刷取统计 */
StatisticsPanel(*) {
  static g := 0
  if (g) {
    g.Destroy()
    g := 0
    return
  }
  title := "已刷取" statistics.Length "次`n"
  msg := ""
  sum := 0
  for (index, value in statistics) {
    msg .= "`n第" index "次刷取耗时：" (value // 60) "分" Mod(value, 60) "秒"
    sum += value
  }
  title .= "总计耗时：" (sum // 3600) "小时" Round(Mod(sum, 3600) / 60) "分钟`n"
  if (statistics.Length > 0) {
    title .= "平均耗时：" (sum // statistics.Length // 60) "分" Mod(sum // statistics.Length, 60) "秒`n"
  }
  msg := title msg
  g := Gui("AlwaysOnTop -MinimizeBox +Owner" CPGui.Hwnd, "零号业绩刷取统计")
  g.SetFont('s15', '微软雅黑')
  g.Add('Edit', 'w300 r' Min(20, statistics.Length + 4) ' ReadOnly', msg)
  g.Show()
  g.OnEvent("Close", destroyGui)
  g.OnEvent("Escape", destroyGui)
  destroyGui(*) {
    g.Destroy()
    g := 0
  }
}

LoadSetting() {
  static iniFile := A_MyDocuments "\autoZZZ.ini"
  if (FileExist(iniFile)) {
    try {
      for (key, value in setting.OwnProps()) {
        value := IniRead(iniFile, 'Settings', key, value)
        setting.%key% := value
      }
    }
  }
}

SaveSetting(*) {
  static iniFile := A_MyDocuments "\autoZZZ.ini"
  try {
    for (key, value in setting.OwnProps()) {
      IniWrite(value, iniFile, 'Settings', key)
    }
  }
}

/** 初始化 */
init() {
  cmd := DllCall("GetCommandLine", "str")
  if (!A_IsAdmin) {
    if (!RegExMatch(cmd, " /restart(?!\S)")) {
      try {
        if (A_IsCompiled) {
          Run('*RunAs "' A_ScriptFullPath '" /restart')
        } else {
          Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
        }
      } catch {
        MsgBox("自动获取管理员权限失败，请右键脚本选择以管理员身份运行", "错误", "Iconx 0x40000")
      }
    } else {
      MsgBox("自动获取管理员权限失败，请右键脚本选择以管理员身份运行", "错误", "Iconx 0x40000")
    }
    ExitApp()
  }
  LoadSetting()
  OnExit(SaveSetting)
  OnError(errHandler)
  errHandler(err, *) {
    global nextExit, ing
    nextExit := false
    ing := false
    throw err
  }
  setRatio()
  if (c.compatible) {
    MsgBox("警告：`n当前显示器分辨率" A_ScreenWidth "x" A_ScreenHeight "无内置数据`n将使用" c.mode "的分辨率比例数据进行缩放兼容处理`n`n若无法正常运行，请更改分辨率比例为16:9，如1920*1080", "警告", "Icon! 0x40000")
  }
  MsgBox("`t   绝区零零号空洞自动刷取脚本`n`n使用方法：`n`n    Alt+P ：暂停/恢复脚本`n    Alt+C ：打开/关闭控制面板`n`n仓库地址 ：https://github.com/UCPr251/zzzAuto", "UCPr", "0x40000")
  ControlPanel()
}

/** 开始，检测所在页面 */
main() {
  setRatio()
  WinGetClientPos(, , &w, &h, "ahk_exe ZenlessZoneZero.exe")
  if (w != A_ScreenWidth && h != A_ScreenHeight) {
    MsgBox("请全屏运行游戏", "错误", "Iconx 0x40000")
    Exit()
  }
  global ing := true
  global nextExit := false ; 重置结束标志
  mode := recogLocation()
  if (!mode) {
    ing := false
    return MsgBox("请位于 <零号空洞主页> 或 <角色操作界面> 重试", "错误", "Iconx 0x40000")
  } else if (mode = 1) {
    debugLog("【开始】模式：角色操作界面")
  } else {
    debugLog("【开始】模式：零号空洞主页")
  }
  RandomSleep()
  if (mode = 1) {
    if (!charOperation()) {
      return MsgBox("进入零号空洞主页失败，请手动进入后重试", "错误", "Iconx 0x40000")
    }
  }
  runAutoZZZ()
}

/** 出现异常后重试 */
retry(reason) {
  if (!setting.errHandler) {
    throw Error(reason)
  }
  ; 如果连一次都没有刷取成功，直接退出
  if (statistics.Length = 0) {
    return MsgBox("【错误】" reason, "错误", "Iconx 0x40000")
  }
  static errTimes := 0
  static errReasons := []
  errTimes++
  errReasons.Push(reason)
  getErrorMsg() {
    errMsg := ""
    loop (errReasons.Length) {
      errMsg .= "`n异常" A_Index "：" errReasons[A_Index]
    }
    ; 重置异常数据
    errTimes := 0
    errReasons := []
    return errMsg
  }
  if (errTimes > 3) {
    global ing := false
    return MsgBox("【错误】异常次数过多，脚本结束" getErrorMsg(), "错误", "Iconx 0x40000")
  }
  MsgBox("【错误】连续刷取过程中出现异常：`n" reason "`n`n将在6s后重试", "错误", "Iconx T6 0x40000")
  RandomSleep()
  judgeExit()
  ; 如果有确认框或选择框
  loop (3) {
    if (PixelSearchPre(&X, &Y, c.空洞.确定*)) {
      SimulateClick(X, Y)
      Sleep(5000)
    }
    Sleep(200)
  }
  judgeExit()
  ; 先Esc偶数次，避免进入了什么奇怪的界面
  Press("Escape")
  RandomSleep(1000, 1200)
  Press("Escape")
  ; 退出副本
  exitFuben()
  judgeExit()
  ; 点击完成
  pixelSearchAndClick(c.空洞.结算.完成*)
  RandomSleep(4800, 5000)
  judgeExit()
  ; 重新识别所处界面
  mode := recogLocation()
  judgeExit()
  if (mode = 2) {
    return runAutoZZZ()
  } else if (mode = 1) {
    if (charOperation()) {
      return runAutoZZZ()
    }
  }
  return MsgBox("【重试失败】未找到零号空洞关卡选择界面，脚本结束`n重试原因：" reason "`n异常次数：" errTimes "`n历史异常：" getErrorMsg(), "错误", "Iconx 0x40000")
}

/** 运行刷取脚本 */
runAutoZZZ() {
  judgeExit()
  global ing := true
  ; 时长统计
  start := A_Now
  status := 0
  ; 进入副本
  enterFuben()
  judgeExit()
  ; 拒绝好意
  refuse()
  judgeExit()
  ; 前往终点
  status := reachEnd()
  judgeExit()
  if (status = 0) {
    return retry("地图类型识别失败")
  }
  ; 战斗
  status := fight()
  judgeExit()
  if (status = 0) {
    return retry("战斗超时或检测异常")
  }
  ; 选择增益
  status := choose()
  judgeExit()
  if (status = 0) {
    return retry("未找到对应增益选项")
  }
  ; 获得零号业绩
  getMoney()
  judgeExit()
  ; 存银行
  if (setting.isSaveBank) {
    saveBank()
    judgeExit()
  }
  ; 退出副本
  exitFuben()
  judgeExit()
  end := A_Now
  statistics.Push(DateDiff(end, start, "s"))
  if (setting.bankMode) {
    debugLog("银行模式，无限循环。已刷取" statistics.Length "次")
  } else {
    ; 判断是否达到上限
    if (isLimited()) {
      judgeExit()
      if (setting.isAutoClose) {
        WinClose("ahk_exe ZenlessZoneZero.exe")
      }
      global ing := false
      return MsgBox("已达到周上限，脚本结束。共刷取" statistics.Length "次")
    }
    debugLog("未达到周上限，继续刷取。已刷取" statistics.Length "次")
  }
  judgeExit()
  RandomSleep(800, 1000)
  ; 点击完成
  pixelSearchAndClick(c.空洞.结算.完成*)
  judgeExit()
  while (recogLocation() != 2) {
    Sleep(100)
  }
  judgeExit()
  ; 继续循环
  runAutoZZZ()
}

judgeExit() {
  global nextExit, ing
  if (nextExit) {
    nextExit := false
    ing := false
    MsgBox("已结束当前刷取线程", , "0x40000")
    Exit()
  }
}