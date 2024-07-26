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
  RandomSleep(1000, 1200)
  ; 对话
  Press("Space", 16)
  rgbs := [
    [0xb2eb47, () => 1], ; 恢复身体
    [0x10cbf4, () => pixelSearchAndClick(930, 700, 1000, 760, 960, 730, 0xffffff)], ; 降压准备
    [0xff802c, () => pixelSearchAndClick(930, 700, 1000, 760, 960, 730, 0xffffff)], ; 邦布插件
    [0xc01c00, 1], ; 侵蚀物资
    [0xaa7cff, 2], ; 垃圾物资或催化
  ]
  clickFnc := 0
  loop (10) {
    for (rgb in rgbs) {
      PixelSearchPre(&FoundX, &FoundY, 1360, 490, 1390, 763, rgb[1])
      if (FoundX && FoundY) {
        SimulateClick(FoundX, FoundY)
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
  ; 未找到对应选项
  if (clickFnc = 0) {
    return false
    ; 侵蚀物资
  } else if (clickFnc = 1) {
    ; 领取铭徽
    MingHui()
    ; 加载侵蚀动画
    Sleep(5000)
    loop (10) {
      ; 确认侵蚀 或 集齐四个同类铭徽触发的赠送铭徽确定（特殊）
      if (PixelSearchPre(&X, &Y, 840, 620, 1000, 810, 0x00cc0d)) {
        SimulateClick(X, Y)
        Sleep(5000)
      }
      Sleep(100)
    }
    ; 垃圾物资或催化
  } else if (clickFnc = 2) {
    loop (10) {
      ; 点击确定
      if (PixelSearchPre(&X, &Y, 930, 750, 985, 810, 0xffffff)) {
        SimulateClick(X, Y)
        Sleep(4000)
      }
      Sleep(100)
    }
  } else {
    clickFnc()
  }
  Press("Space", 3)
  return true
}