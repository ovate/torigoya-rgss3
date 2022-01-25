# encoding: utf-8
#===============================================================================
# ■ Regeneration in battle log
#-------------------------------------------------------------------------------
# 2019/03/09　Ruたん
# License - Public Domain, allows commercial use and credit is not necessary
#-------------------------------------------------------------------------------
# Conversion of futokoro's FTKR_DisplayRegenerateMessage.js to VX Ace
# https://github.com/futokoro/RPGMaker/blob/master/FTKR_DisplayRegenerateMessage.ja.md
#-------------------------------------------------------------------------------
# Displays amount of HP / MP / TP in the battle log at the end of the turn
#-------------------------------------------------------------------------------
# 【Changelog】
# 2019/03/09 Released
#-------------------------------------------------------------------------------

#===============================================================================
# ● Setting
#===============================================================================
module Torigoya
  module DisplayRegenerateMessage
    module Template
      HP_MESSAGE = {
        # ● Message when HP recovers
        #    %1 … Target's name
        #    %2 … Status name
        #    %3 … Increased amount
        gain: '%1 recovered %3 %2！',

        # ● Message when HP decreases
        #    %1 … Target's name
        #    %2 … Status name
        #    %3 … Increased amount
        lose: '%1 lost %3 %2！',
      }

      MP_MESSAGE = {
        # ● Message when MP recovers
        #    %1 … Target's name
        #    %2 … Status name
        #    %3 … Increased amount
        gain: '%1 recovered %3 %2！',

        # ● Message when MP decreases
        #    %1 … Target's name
        #    %2 … Status name
        #    %3 … Increased amount
        lose: '%1 lost %3 %2！',
      }

      TP_MESSAGE = {
        # ● Message when TP recovers
        #    %1 … Target's name
        #    %2 … Status name
        #    %3 … Increased amount
        gain: '%1 recovered %3 %2！',

        # ● Message when TP decreases
        #    %1 … Target's name
        #    %2 … Status name
        #    %3 … Increased amount
        lose: '%1 lost %3 %2！',
      }
    end
  end
end

#===============================================================================
# ↑ 　 Setting 　 ↑
# ↓ Script part ↓
#===============================================================================

module Torigoya
  module DisplayRegenerateMessage
    class << self
      def in_turn_end_process?
        !!@in_turn_end_process
      end

      def turn_end_process(&block)
        @in_turn_end_process = true
        block.call
        @in_turn_end_process = false
      end

      def generate_message(type, name, value)
        template, status =
          case type
          when :hp
            [Template::HP_MESSAGE, Vocab.hp]
          when :mp
            [Template::MP_MESSAGE, Vocab.mp]
          when :tp
            [Template::TP_MESSAGE, Vocab.tp]
          else
            raise 'must not happen'
          end
        template[value > 0 ? :lose : :gain].gsub('%1', name).gsub('%2', status).gsub('%3', value.abs.to_s)
      end
    end
  end
end

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● Automatic status display (alias)
  #--------------------------------------------------------------------------
  alias torigoya_display_regenerate_message_display_auto_affected_status display_auto_affected_status
  def display_auto_affected_status(target)
    display_regenerate_message(target) if Torigoya::DisplayRegenerateMessage.in_turn_end_process?
    torigoya_display_regenerate_message_display_auto_affected_status(target)
  end
  #--------------------------------------------------------------------------
  # ● Display recovery message
  #--------------------------------------------------------------------------
  def display_regenerate_message(target)
    [:hp_damage, :mp_damage, :tp_damage].each do |name|
      next if target.result.public_send(name) == 0
      add_text(Torigoya::DisplayRegenerateMessage.generate_message(:hp, target.name, target.result.public_send(name)))
      wait
    end
  end
end

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● End of turn (alias)
  #--------------------------------------------------------------------------
  alias torigoya_display_regenerate_message_turn_end turn_end
  def turn_end
    Torigoya::DisplayRegenerateMessage.turn_end_process do
      torigoya_display_regenerate_message_turn_end
    end
  end
end