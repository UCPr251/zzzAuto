/**
 * - step5
 * - 选择增益
 */
choose() {
  activateZZZ()
  debugLog("【step5】选择增益")
  RandomSleep()
  ; 进入对话
  Press("w")
  RandomSleep(1000, 1500)
  ; 对话
  Press("Space", 16)
  rgbs := [
    [0xb2eb47, () => 1], ; 恢复身体
    [0x10cbf4, () => SimulateClick(960, 732)], ; 降压准备
    [0xc01c00, 1], ; 侵蚀物资
    [0xaa7cff, 2], ; 垃圾物资或催化
  ]
  clickFnc := 0
  loop (10) {
    for (rgb in rgbs) {
      PixelSearchPre(&FoundX, &FoundY, 1375, 520, 1393, 763, rgb[1], 30)
      if (FoundX && FoundY) {
        SimulateClick(FoundX, FoundY, 1, false)
        clickFnc := rgb[2]
        break
      }
    }
    if (clickFnc) {
      break
    }
    Sleep(100)
  }
  RandomSleep(2200, 2400)
  if (clickFnc = 1) {
    ; 领取铭徽
    pixelSearchAndClick(935, 739, 994, 861, 960, 790, 0xffffff)
    ; 加载侵蚀动画
    Sleep(5000)
    loop (10) {
      ; 确认侵蚀
      if (PixelSearchPre(&X, &Y, 953, 636, 1002, 660, 0xffffff, 30)) {
        SimulateClick(X, Y)
        Sleep(5000)
      }
      Sleep(100)
    }
  } else if (clickFnc = 2) {
    loop (10) {
      ; 点击确定
      if (PixelSearchPre(&X, &Y, 940, 783, 985, 805, 0xffffff, 30)) {
        SimulateClick(X, Y)
        Sleep(4000)
      }
      Sleep(100)
    }
  } else {
    clickFnc()
  }
  Press("Space", 3)
}