# encoding: utf-8
#===============================================================================
# ■ Hidden Skill Switch
#-------------------------------------------------------------------------------
# 2019/12/15　Ruたん
# License - Public Domain, allows commercial use and credit is not necessary
#-------------------------------------------------------------------------------
# If specified switch is ON, certain skill/ item won't show in the list (unusable)
# Possible to create hidden skill/items with a switch through note tag
#
# ＜Usage＞
# Put the following tag in the Note box for skill or item
#
# <hidskill: 1>
#
# 　Or
#
# <hiditem: 1>
#
# By using this tag,
# When switch ID: 1 is ON, the item won't show in the list.
# (If you want to change the switch ID, change 1)
#-------------------------------------------------------------------------------
# 【Changelog】
# 2019/12/15 Released
#-------------------------------------------------------------------------------

module Torigoya
  module HiddenSkillSwitch
    module Config
      # [Advanced setting] Regular expression in Note box
      # Play here if you want to change the setting method
      NOTE_REGEXP = /<(?:HiddenSkillSwitch|HiddenItemSwitch|hidskill|hiditem):\s*(?<switch_id>\d+)\s*>/
    end
  end
end

class RPG::BaseItem
  #--------------------------------------------------------------------------
  # ● Are item switchable in the list?
  #--------------------------------------------------------------------------
  def torigoya_visible_in_list?
    unless instance_variable_defined?(:@torigoya_visible_in_list_switch)
      match = note.match(Torigoya::HiddenSkillSwitch::Config::NOTE_REGEXP)
      @torigoya_visible_in_list_switch = match ? match[:switch_id].to_i : 0
    end
    @torigoya_visible_in_list_switch ? !$game_switches[@torigoya_visible_in_list_switch] : true
  end
end

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● Skill/Item availability (alias)
  #--------------------------------------------------------------------------
  alias torigoya_hidden_skill_switch_usable? usable?
  def usable?(item)
    return false unless torigoya_hidden_skill_switch_usable?(item)
    item.torigoya_visible_in_list?
  end
end

class Window_ItemList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● Whether to include items in the list (alias)
  #--------------------------------------------------------------------------
  alias torigoya_hidden_skill_switch_include? include?
  def include?(item)
    return false unless torigoya_hidden_skill_switch_include?(item)
    item && item.torigoya_visible_in_list?
  end
end

class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● Whether to include items in the list (alias)
  #--------------------------------------------------------------------------
  alias torigoya_hidden_skill_switch_include? include?
  def include?(item)
    return false unless torigoya_hidden_skill_switch_include?(item)
    item && item.torigoya_visible_in_list?
  end
end