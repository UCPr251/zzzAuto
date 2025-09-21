/**
 * 完成丁尼副本
 */
getDenny(step := 3) {
  activateZZZ()
  stepLog("【step" step "】完成丁尼副本")

  static depth := 1
  static isFighting() {
    return PixelSearchPre(&FoundX, &FoundY, c.空洞.1.战斗.开始*)
  }

  Sleep(10000)
  while (!isFighting()) {
    if (A_Index > 251) {
      if (!setting.errHandler) {
        throw Error('识别战斗开始画面失败')
      }
      break
    }
    Sleep(100)
  }
  Sleep(100)
  DllCall("mouse_event", "UInt", 1, "UInt", setting.rotateCoords, "UInt", 0)
  Send("{w Down}")
  ; 比利闪避长按攻击
  Press('Shift')
  Click('Left Down')
  Sleep(200)
  Click('Left Up')
  ; 切人
  Press('Space')
  if (setting.fightModeDenny = 1) {
    ; 通用连续闪避
    loop (6) {
      Press('Shift')
      Sleep(Random(300, 320))
    }
  } else if (setting.fightModeDenny = 2) {
    ; 艾莲长按闪避
    Send('{Shift Down}')
    RandomSleep(2510, 2600)
    Send('{Shift Up}')
  } else if (setting.fightModeDenny = 3) {
    ; 雅连续长按闪避
    loop (2) {
      Send("{Shift Down}")
      Sleep(Random(300, 320))
      Send("{Shift Up}")
      RandomSleep(180, 200)
    }
  }

  while (isFighting()) {
    if (A_Index > 12) {
      break
    }
    Press('f')
  }
  Send("{w Up}")

  RandomSleep(251, 300)
  if (isFighting()) {
    ; if (!setting.errHandler) {
    ;   throw Error('丁尼刷取交互失败')
    ; }
    Press('Escape')
    if (++depth > 3) {
      ; 若存在刷取成功的数据，证明非配置问题，尝试重进副本刷取
      if (setting.statisticsDenny.length) {
        return false
      }
      throw Error('获取丁尼重试次数过多，请确保：`n1、进入了正确的副本：第二章间章「真·拿命验收」`n2、编队首位必须为「比利」`n3、在控制面板中设置了合适的“视角转动值”')
    }
    pixelSearchAndClick(c.拿命验收.重新开始*)
    pixelSearchAndClick(c.空洞.退出副本.确认*)
    return getDenny(step)
  } else {
    loop (2) {
      Press('Space', 3)
      Press('1', 2)
      Press('Space', 3)
    }
    depth := 1
    return true
  }
}