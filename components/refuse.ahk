/**
 * - 拒绝好意
 */
refuse(step := 2) {
  activateZZZ()
  stepLog("【step" step "】拒绝好意")

  ; 开局铭徽(如果有)
  MingHui(true, 15)
  ; 对话
  Press("Space", 10)
  ; 拒绝
  Press('2', 2)
  ; 对话
  Press("Space", 10)
  ; 加载动画
  RandomSleep(2000, 2200)
}