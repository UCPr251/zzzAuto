/** 识别所处界面 1：角色操作界面，2：关卡选择界面 */
recogLocation() {
  /** 通过三个特殊定位点判断所处界面 */
  patterns1 := [
    [1170, 880, 1800, 920, 0xffffff], ; M
    [1770, 1020, 1790, 1050, 0xffffff], ; Q
    [1800, 100, 1850, 130, 0xffffff]  ; Tab
  ]
  patterns2 := [
    [240, 700, 260, 750, 0x78cc00], ; 资质考核
    [580, 780, 600, 850, 0x78cc00], ; 旧都列车
    [680, 410, 700, 450, 0x78cc00] ; 施工废墟
  ]
  judge(patterns) {
    for (pattern in patterns) {
      if (!PixelSearchPre(&FoundX, &FoundY, pattern*)) {
        return false
      }
    }
    return true
  }
  mode := 0
  loop (10) {
    if (judge(patterns1)) {
      mode := 1
      break
    }
    if (judge(patterns2)) {
      mode := 2
      break
    }
    Sleep(100)
  }
  return mode
}