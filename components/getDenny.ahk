/**
 * 完成丁尼副本
 */
getDenny(step := 3) {
  activateZZZ()
  stepLog("【step" step "】完成丁尼副本")

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
    pixelSearchAndClick(c.拿命验收.重新开始*)
    pixelSearchAndClick(c.空洞.退出副本.确认*)
    getDenny(step)
  } else {
    loop (2) {
      Press('Space', 3)
      Press('1', 2)
      Press('Space', 3)
    }
  }
}