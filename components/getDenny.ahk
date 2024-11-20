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
  Press('Shift')
  Click('Left Down')
  Sleep(200)
  Click('Left Up')
  Press('Space')
  Send('{Shift Down}')
  RandomSleep(2510, 2600)
  Send('{Shift Up}')
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
    if (++depth > 8) {
      throw Error('获取丁尼重试次数过多，请确保：`n1、进入了正确的副本：第二章间章「真·拿命验收」`n2、编队首位必须为「比利」，第二位推荐鲨鱼妹`n3、在控制面板中设置了合适的“视角转动值”')
    }
    pixelSearchAndClick(c.拿命验收.重新开始*)
    pixelSearchAndClick(c.空洞.退出副本.确认*)
    getDenny(step)
  } else {
    loop (2) {
      Press('Space', 3)
      Press('1', 2)
      Press('Space', 3)
    }
    depth := 1
  }
}