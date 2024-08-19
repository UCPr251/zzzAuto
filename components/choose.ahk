/**
 * - step5
 * - 选择增益
 */
choose() {
  activateZZZ()
  debugLog("【step5】选择增益")
  ; 进入对话
  Press("w", 3)
  RandomSleep(1000, 1200)
  ; 对话
  Press("Space", 16)
  rgbs := [
    [0xb2eb47, () => 1], ; 恢复身体
    [0x10cbf4, () => pixelSearchAndClick(c.空洞.2.降压准备*)], ; 降压准备
    [0xc01c00, 1], ; 侵蚀物资
    [0xaa7cff, 2], ; 垃圾物资或催化
    [0xff802c, () => pixelSearchAndClick(c.空洞.2.降压准备*)], ; 邦布插件
  ]
  clickFnc := 0
  loop (10) {
    for (rgb in rgbs) {
      clone := c.空洞.2.选项框.Clone()
      clone.Push(rgb[1])
      PixelSearchPre(&FoundX, &FoundY, clone*)
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
  RandomSleep(2200, 2300)
  ; 未找到对应选项
  if (clickFnc = 0) {
    return false
  } else if (clickFnc = 1) { ; 侵蚀物资
    ; 领取铭徽
    MingHui()
    ; 加载侵蚀动画
    RandomSleep(1800, 2000)
    loop (10) {
      ; 确认侵蚀 或 集齐四个同类铭徽触发的赠送铭徽确认（特殊）
      if (PixelSearchPre(&X, &Y, c.空洞.确认*)) {
        SimulateClick(X, Y)
        RandomSleep(1800, 2000)
      }
      Sleep(100)
    }
  } else if (clickFnc = 2) { ; 垃圾物资或催化
    loop (10) {
      ; 点击确定
      if (PixelSearchPre(&X, &Y, c.空洞.确定*)) {
        SimulateClick(X, Y)
        RandomSleep(4000, 4200)
      }
      Sleep(100)
    }
  } else {
    clickFnc()
  }
  Press("Space", 10)
  return true
}