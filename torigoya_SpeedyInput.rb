# coding: utf-8
#===============================================================================
# ■ Speedy Input.repeat for Menu for RGSS3
#-------------------------------------------------------------------------------
#　2012/01/02　Ru/むっくRu | English translation by tale 2017/02/16
# License - Public Domain, allows commercial use and credit is not necessary
#-------------------------------------------------------------------------------
#  Input.repeat? Speeds up the intervals.
#  （※Depends on the setting, you can slow down!）
#
#  ● Following features added
#  Input.repeatEx?(key) …… Faster Input.repeat?
#
#  ● Following features changed
#  Input.repeat?(key)   …… Faster than usual
#
#-------------------------------------------------------------------------------
# 【Issues】
#  Awful item setting description...
#-------------------------------------------------------------------------------
# 【Changelogs】
# 2012/01/02 Function extended where it can be reflected on the base script upon usage.
# 2011/12/25 Fixed an error that occurred after startup
# 2011/12/21 Released
#-------------------------------------------------------------------------------

#===============================================================================
# ● Item settings
#==============================================================================
module HZM_VXA
  module InputRepeatEx
    # First waiting time to second then repeat
    # （Time: Start to finish.）
    WAIT1 = 20
    # Second waiting time after repeat
    # （Time: Inbetween）
    WAIT2 = 1
    
    # Do you want to replace the default Input.repeat with a faster repeat?
    REPLACE_REPEAT_FLAG = true
  end
end

#===============================================================================
# ↑ 　 Setup goes here 　 ↑
# ↓  Script down there  ↓
#===============================================================================

module HZM_VXA
  module InputRepeatEx
    LIST = [:DOWN, :LEFT, :RIGHT, :UP, :A, :B, :C, :X, :Y, :Z, :L, :R, :SHIFT, :CTRL, :ALT, :F5, :F6, :F7, :F8, :F9]
  end
end
module Input
  @hzm_vxa_inputrepeatex_repeatex_cnt  = {}
  @hzm_vxa_inputrepeatex_repeatex_flag = {}
  HZM_VXA::InputRepeatEx::LIST.each do |key|
    @hzm_vxa_inputrepeatex_repeatex_cnt[key] = 0
    @hzm_vxa_inputrepeatex_repeatex_flag[key] = false
  end
end

class << Input
  #-----------------------------------------------------------------------------
  # ● Update
  #-----------------------------------------------------------------------------
  alias hzm_vxa_inputrepeatex_update update
  def update
    hzm_vxa_inputrepeatex_update
    HZM_VXA::InputRepeatEx::LIST.each do |key|
      if trigger?(key)
        @hzm_vxa_inputrepeatex_repeatex_cnt[key] = HZM_VXA::InputRepeatEx::WAIT1
        @hzm_vxa_inputrepeatex_repeatex_flag[key] = true
      elsif press?(key)
        if @hzm_vxa_inputrepeatex_repeatex_cnt[key] <= 0
          @hzm_vxa_inputrepeatex_repeatex_cnt[key] = HZM_VXA::InputRepeatEx::WAIT2
          @hzm_vxa_inputrepeatex_repeatex_flag[key] = true
        else
          @hzm_vxa_inputrepeatex_repeatex_cnt[key] -= 1
          @hzm_vxa_inputrepeatex_repeatex_flag[key] = false
        end
      else
        @hzm_vxa_inputrepeatex_repeatex_cnt[key] = 0
        @hzm_vxa_inputrepeatex_repeatex_flag[key] = false
      end
    end
  end
  #-----------------------------------------------------------------------------
  # ● Speed repeat
  #-----------------------------------------------------------------------------
  def repeatEx?(key)
    @hzm_vxa_inputrepeatex_repeatex_flag[key]
  end
  #-----------------------------------------------------------------------------
  # ● repeat?（Redefined）
  #-----------------------------------------------------------------------------
  if HZM_VXA::InputRepeatEx::REPLACE_REPEAT_FLAG
    def repeat?(key)
      repeatEx?(key)
    end
  end
end

# When the base script is present, repeatEX is supported
if defined?(HZM_VXA::Input)
  module HZM_VXA
    module Input
      def self.wait1
        HZM_VXA::InputRepeatEx::WAIT1
      end
      def self.wait2
        HZM_VXA::InputRepeatEx::WAIT2
      end
    end
  end
end