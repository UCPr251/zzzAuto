/**
 * - step 2
 * - 拒绝好意，结束对话
 */
refuse() {
  activateZZZ()
  debugLog("【step2】拒绝好意，结束对话")
  RandomSleep(200, 300)
  ; 开局铭徽(如果有)
  SimulateClick(960, 790, 2)
  ; 对话
  Press("Space", 8)
  ; 拒绝
  pixelSearchAndClick(1401, 668, 1516, 689, 1662, 676, 0xffffff)
  ; 对话
  Press("Space", 8)
  ; 加载动画
  Sleep(5000)
}
