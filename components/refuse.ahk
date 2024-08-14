/**
 * - step 2
 * - 拒绝好意
 */
refuse() {
  activateZZZ()
  debugLog("【step2】拒绝好意")
  RandomSleep()
  ; 开局铭徽(如果有)
  MingHui(true)
  ; 对话
  Press("Space", 8)
  ; 拒绝
  Press('2')
  ; 对话
  Press("Space", 8)
  ; 加载动画
  RandomSleep(5000, 5200)
}