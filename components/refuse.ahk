/**
 * - step 2
 * - 拒绝好意
 */
refuse() {
  activateZZZ()
  debugLog("【step2】拒绝好意")
  ; 开局铭徽(如果有)
  MingHui(true)
  ; 对话
  Press("Space", 10)
  ; 拒绝
  Press('2', 2)
  ; 对话
  Press("Space", 10)
  ; 加载动画
  RandomSleep(4000, 4200)
}