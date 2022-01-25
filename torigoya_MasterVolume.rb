# coding: utf-8
#===============================================================================
# ■ Master Volume Control for RGSS3
#-------------------------------------------------------------------------------
#　2016/04/23　By Ru/むっくRu (Rutan) | English translation by tale 2017/02/10
# License - Public Domain, allows commercial use and credit is not necessary
#-------------------------------------------------------------------------------
#　Add functions related to volume adjustment
#
#　● Volume adjustment - items are added to the title screen and main menu
#
#　● Audio - The following items are added to the module
#　Audio.bgm_vol …… BGM
#　Audio.bgs_vol …… BGS
#　Audio.se_vol  …… SE
#　Audio.me_vol  …… ME
#　Audio.bgm_vol=Numerical variable …… BGM（0～100）
#　Audio.bgs_vol=Numerical variable …… BGS（0～100）
#　Audio.se_vol=Numerical variable  …… SE（0～100）
#　Audio.me_vol=Numerical variable  …… ME（0～100）
#
#-------------------------------------------------------------------------------
# 【Changelogs】
# 2021/10/22 BGS volume control fix
# 2016/04/23 Code reorganized
# 2013/05/25 Fixed error drop when changing type of volume change item
# 2012/12/17 Allows the volume to be saved without the base script. (Script organization)
# 2012/06/13 Redesign layout. Added setting item. (Organizing scripts)
# 2012/01/02 Ini changed reading HZM_VXA base script for RGSS3 (Change to dependent)
# 2011/12/29 BGS Fixed a bug that causes error during playback
# 2011/12/26 BGM Fixed a bug that causes the volume to be adjusted when mute
# 2011/12/13 ini Allows cooperation with reading
# 2011/12/01 Released
#-------------------------------------------------------------------------------

#===============================================================================
# ● Item settings
#===============================================================================
module HZM_VXA
  module AudioVol
    # ● Do you want to display the volume adjustment on the title screen?
    #    ※To redefine the menu items on the title screen,
    #      If you introduce another script that tamper with the menu titles
    #      There's a possibility of conflict.
    # 　true  …… Display
    # 　false …… Don't display
    TITLE_FLAG = true
    # Item name to be displayed on title screen
    TITLE_NAME        = "Volume Control"

    # ● Do you want the volume adjustment displayed on the menu screen?
    # 　true  …… Display
    # 　false …… Don't display
    MENU_FLAG = true
    # Name of the setting in Main Menu.
    MENU_NAME        = "Volume Control"

    # ● Types of Volume arrangement
    # 　0 …… BGM/BGS/SE/ME Set all at once
    #   1 …… BGM＋BGS と SE＋ME Set with 2 kinds of
    #   2 …… BGM/BGS/SE/ME Set by each of 4 types
    TYPE = 2

    # ● Volume Control Settings Name.
    CONFIG_ALL_NAME  = "Volume"        # Used when type "0" is selected
    CONFIG_BGM_NAME  = "BGM"         # Used when type "1" "2" is selected
    CONFIG_BGS_NAME  = "BGS"         # Used when type "2" is selected
    CONFIG_SE_NAME   = "SE"          # Used when type "1" "2" is selected
    CONFIG_ME_NAME   = "ME"          # Used when type "2" is selected
    CONFIG_EXIT_NAME = "Exit"

    # ● Volume adjustment by Increments
    ADD_VOL_NORMAL =  5              # Amount of increment of left and right keys
    ADD_VOL_HIGH   = 25              # LR Variation amount of key

    # ● Window width of volume setting screen
    WINDOW_WIDTH   = 200

    # ● Volume gauge color from the menu interface
    COLOR1 = Color.new(255, 255, 255)
    COLOR2 = Color.new( 64,  64, 255)

    # ● Save function of volume setting
    #    Game.ini, By storing volume information in
    #    You can also adjust the volume when you start up
    #    true  …… Save
    #    false …… Don't save
    USE_INI = true
  end
end

#===============================================================================
# ↑ Set up here ↑
# ↓ or less, script part ↓
#===============================================================================

module Audio
  #-----------------------------------------------------------------------------
  # ● Volume setting: BGM
  #-----------------------------------------------------------------------------
  def self.bgm_vol=(vol)
    @hzm_vxa_audioVol_bgm = self.vol_range(vol)
  end
  #-----------------------------------------------------------------------------
  # ● Volume setting: BGS
  #-----------------------------------------------------------------------------
  def self.bgs_vol=(vol)
    @hzm_vxa_audioVol_bgs = self.vol_range(vol)
  end
  #-----------------------------------------------------------------------------
  # ● Volume setting: SE
  #-----------------------------------------------------------------------------
  def self.se_vol=(vol)
    @hzm_vxa_audioVol_se = self.vol_range(vol)
  end
  #-----------------------------------------------------------------------------
  # ● Volume setting: ME
  #-----------------------------------------------------------------------------
  def self.me_vol=(vol)
    @hzm_vxa_audioVol_me = self.vol_range(vol)
  end
  #-----------------------------------------------------------------------------
  # ● Volume range specification
  #-----------------------------------------------------------------------------
  def self.vol_range(vol)
    vol = vol.to_i
    vol < 0 ? 0 : vol < 100 ? vol : 100
  end
  #-----------------------------------------------------------------------------
  # ● Volume acquisition: BGM
  #-----------------------------------------------------------------------------
  def self.bgm_vol
    @hzm_vxa_audioVol_bgm ||= 100
  end
  #-----------------------------------------------------------------------------
  # ● Volume acquisition: BGS
  #-----------------------------------------------------------------------------
  def self.bgs_vol
    @hzm_vxa_audioVol_bgs ||= 100
  end
  #-----------------------------------------------------------------------------
  # ● Volume acquisition: SE
  #-----------------------------------------------------------------------------
  def self.se_vol
    @hzm_vxa_audioVol_se ||= 100
  end
  #-----------------------------------------------------------------------------
  # ● Volume acquisition: ME
  #-----------------------------------------------------------------------------
  def self.me_vol
    @hzm_vxa_audioVol_me ||= 100
  end
end

class << Audio
  #-----------------------------------------------------------------------------
  # ● Playback: BGM
  #-----------------------------------------------------------------------------
  alias hzm_vxa_audioVol_bgm_play bgm_play
  def bgm_play(filename, volume = 100, pitch = 100, pos = 0)
    hzm_vxa_audioVol_bgm_play(filename, self.bgm_vol * volume / 100, pitch, pos)
  end
  #-----------------------------------------------------------------------------
  # ● Playback: BGS
  #-----------------------------------------------------------------------------
  alias hzm_vxa_audioVol_bgs_play bgs_play
  def bgs_play(filename, volume = 100, pitch = 100, pos = 0)
    hzm_vxa_audioVol_bgs_play(filename, self.bgs_vol * volume / 100, pitch, pos)
  end
  #-----------------------------------------------------------------------------
  # ● Playback: SE
  #-----------------------------------------------------------------------------
  alias hzm_vxa_audioVol_se_play se_play
  def se_play(filename, volume = 100, pitch = 100)
    hzm_vxa_audioVol_se_play(filename, self.se_vol * volume / 100, pitch)
  end
  #-----------------------------------------------------------------------------
  # ● Playback: ME
  #-----------------------------------------------------------------------------
  alias hzm_vxa_audioVol_me_play me_play
  def me_play(filename, volume = 100, pitch = 100)
    hzm_vxa_audioVol_me_play(filename, self.me_vol * volume / 100, pitch)
  end
  #-----------------------------------------------------------------------------
  # ● Old Version Compatibility
  #-----------------------------------------------------------------------------
  if true
    alias volBGM bgm_vol
    alias volBGS bgs_vol
    alias volSE se_vol
    alias volME me_vol
    alias volBGM= bgm_vol=
    alias volBGS= bgs_vol=
    alias volSE= se_vol=
    alias volME= me_vol=
  end
end

# For the title screen
if HZM_VXA::AudioVol::TITLE_FLAG
  class Window_TitleCommand < Window_Command
    if true
      # ↑ If you change true to false,
      #    This makes the menu items on title screen aliased instead of redefining
      #    It will be implemented.
      #    Conflicting with other menu titles extended scripts would be unlikely to happen,
      #    As a side effect, the volume setting item is added under shutdown.
      #    According to your needs……(・ｘ・)
      #---------------------------------------------------------------------------
      # ● Create command list (redefinition)
      #---------------------------------------------------------------------------
      def make_command_list
        add_command(Vocab::new_game, :new_game)
        add_command(Vocab::continue, :continue, continue_enabled)
        add_command(HZM_VXA::AudioVol::TITLE_NAME, :hzm_vxa_audioVol)
        add_command(Vocab::shutdown, :shutdown)
      end
    else
      #---------------------------------------------------------------------------
      # ● Creating command list
      #---------------------------------------------------------------------------
      alias hzm_vxa_audioVol_make_command_list make_command_list
      def make_command_list
        hzm_vxa_audioVol_make_command_list
        add_command(HZM_VXA::AudioVol::TITLE_NAME, :hzm_vxa_audioVol)
      end
    end
  end
  class Scene_Title < Scene_Base
    #---------------------------------------------------------------------------
    # ● Creating Command Window
    #---------------------------------------------------------------------------
    alias hzm_vxa_audioVol_create_command_window create_command_window
    def create_command_window
      hzm_vxa_audioVol_create_command_window
      @command_window.set_handler(:hzm_vxa_audioVol, method(:hzm_vxa_audioVol_command_config))
    end
    #---------------------------------------------------------------------------
    # ● Command [Volume adjustment]
    #---------------------------------------------------------------------------
    def hzm_vxa_audioVol_command_config
      close_command_window
      SceneManager.call(HZM_VXA::AudioVol::Scene_VolConfig)
    end
  end
end

# メニューに追加
if HZM_VXA::AudioVol::MENU_FLAG
  class Window_MenuCommand
    #---------------------------------------------------------------------------
    # ● For adding a custom command
    #---------------------------------------------------------------------------
    alias hzm_vxa_audioVol_add_original_commands add_original_commands
    def add_original_commands
      hzm_vxa_audioVol_add_original_commands
      add_command(HZM_VXA::AudioVol::MENU_NAME, :hzm_vxa_audioVol)
    end
  end
  class Scene_Menu
    #---------------------------------------------------------------------------
    # ● Creating Command Window
    #---------------------------------------------------------------------------
    alias hzm_vxa_audioVol_create_command_window create_command_window
    def create_command_window
      hzm_vxa_audioVol_create_command_window
      @command_window.set_handler(:hzm_vxa_audioVol, method(:hzm_vxa_audioVol_command_config))
    end
    #---------------------------------------------------------------------------
    # ● Call volume from the setting screen
    #---------------------------------------------------------------------------
    def hzm_vxa_audioVol_command_config
      SceneManager.call(HZM_VXA::AudioVol::Scene_VolConfig)
    end
  end
end

# Volume Configuration Window
module HZM_VXA
  module AudioVol
    class Window_VolConfig < Window_Command
      #-------------------------------------------------------------------------
      # ● Generate
      #-------------------------------------------------------------------------
      def initialize
        @mode = HZM_VXA::AudioVol::TYPE.to_i
        super(0, 0)
        self.x = (Graphics.width  - self.window_width ) / 2
        self.y = (Graphics.height - self.window_height) / 2
      end
      #-------------------------------------------------------------------------
      # ● Acquire command symbol
      #-------------------------------------------------------------------------
      def command_symbol(index)
        @list[index][:symbol]
      end
      #-------------------------------------------------------------------------
      # ● Command extend data
      #-------------------------------------------------------------------------
      def command_ext(index)
        @list[index][:ext]
      end
      #-------------------------------------------------------------------------
      # ● Window width
      #-------------------------------------------------------------------------
      def window_width
        HZM_VXA::AudioVol::WINDOW_WIDTH
      end
      #--------------------------------------------------------------------------
      # ● Acquire alignment
      #--------------------------------------------------------------------------
      def alignment
        command_symbol(@now_drawing_index) == :cancel ? 1 : 0
      end
      #-------------------------------------------------------------------------
      # ● Command generate
      #-------------------------------------------------------------------------
      def make_command_list
        make_command_list_actions
        make_command_list_exit
      end
      #-------------------------------------------------------------------------
      # ● Command： action
      #-------------------------------------------------------------------------
      def make_command_list_actions
        case @mode
        when 0
          add_command(HZM_VXA::AudioVol::CONFIG_ALL_NAME,  :all)
        when 1
          add_command(HZM_VXA::AudioVol::CONFIG_BGM_NAME,  :bgm)
          add_command(HZM_VXA::AudioVol::CONFIG_SE_NAME,   :se)
        else
          add_command(HZM_VXA::AudioVol::CONFIG_BGM_NAME,  :bgm)
          add_command(HZM_VXA::AudioVol::CONFIG_BGS_NAME,  :bgs)
          add_command(HZM_VXA::AudioVol::CONFIG_SE_NAME,   :se)
          add_command(HZM_VXA::AudioVol::CONFIG_ME_NAME,   :me)
        end
      end
      #-------------------------------------------------------------------------
      # ● Command： cancel
      #-------------------------------------------------------------------------
      def make_command_list_exit
        add_command(HZM_VXA::AudioVol::CONFIG_EXIT_NAME, :cancel)
      end
      #-------------------------------------------------------------------------
      # ● Drawing items
      #-------------------------------------------------------------------------
      def draw_item(index)
        @now_drawing_index = index
        super
        case command_symbol(index)
        when :all, :bgm, :bgs, :se, :me
          draw_item_volume_guage(index)
        end
      end
      #-------------------------------------------------------------------------
      # ● Drawing items: volume gauge
      #-------------------------------------------------------------------------
      def draw_item_volume_guage(index)
        vol =
          case command_symbol(index)
          when :all, :bgm
            Audio.bgm_vol
          when :bgs
            Audio.bgs_vol
          when :se
            Audio.se_vol
          when :me
            Audio.me_vol
          end
        draw_gauge(item_rect_for_text(index).x + 96 - 8, item_rect_for_text(index).y, contents_width - 96, vol/100.0, HZM_VXA::AudioVol::COLOR1, HZM_VXA::AudioVol::COLOR2)
        draw_text(item_rect_for_text(index), vol, 2)
      end
      #-------------------------------------------------------------------------
      # ● Increase volume
      #-------------------------------------------------------------------------
      def vol_add(index, val)
        call_flag = false

        case command_symbol(index)
        when :all
          call_flag = add_vol_bgm(val)
          Audio.bgs_vol = Audio.bgm_vol
          Audio.se_vol = Audio.bgm_vol
          Audio.me_vol = Audio.bgm_vol
        when :bgm
          call_flag = add_vol_bgm(val)
          Audio.bgs_vol = Audio.bgm_vol if @mode == 1
        when :bgs
          call_flag = add_vol_bgs(val)
        when :se
          call_flag = add_vol_se(val)
          Audio.me_vol = Audio.se_vol if @mode == 1
        when :me
          call_flag = add_vol_me(val)
        end

        if call_flag
          Sound.play_cursor
          redraw_item(index)
        end
      end
      def add_vol_bgm(val)
        old = Audio.bgm_vol
        Audio.bgm_vol += val
        if music = RPG::BGM.last and music.name.size > 0
          Audio.bgm_play("Audio/BGM/#{music.name}", music.volume, music.pitch, music.pos)
        end
        Audio.bgm_vol != old
      end
      def add_vol_bgs(val)
        old = Audio.bgs_vol
        Audio.bgs_vol += val
        if music = RPG::BGS.last and music.name.size > 0
          Audio.bgs_play("Audio/BGS/#{music.name}", music.volume, music.pitch, music.pos)
        end
        Audio.bgs_vol != old
      end
      # def add_vol_bgs(val)
        # old = Audio.bgs_vol
        # Audio.bgs_vol += val
        # Audio.bgs_vol != old
      # end
      def add_vol_se(val)
        old = Audio.se_vol
        Audio.se_vol += val
        Audio.se_vol != old
      end
      def add_vol_me(val)
        old = Audio.me_vol
        Audio.me_vol += val
        Audio.me_vol != old
      end
      #--------------------------------------------------------------------------
      # ● Process when the button is pressed
      #    ※Ignore if it's on the volume setting
      #--------------------------------------------------------------------------
      def process_ok
        case current_symbol
        when :bgm, :bgs, :se, :me
          return
        else
          super
        end
      end
      #-------------------------------------------------------------------------
      # ● Key operation
      #-------------------------------------------------------------------------
      def cursor_left(wrap = false)
        vol_add(@index, -HZM_VXA::AudioVol::ADD_VOL_NORMAL)
      end
      def cursor_right(wrap = false)
        vol_add(@index,  HZM_VXA::AudioVol::ADD_VOL_NORMAL)
      end
      def cursor_pageup
        vol_add(@index, -HZM_VXA::AudioVol::ADD_VOL_HIGH)
      end
      def cursor_pagedown
        vol_add(@index,  HZM_VXA::AudioVol::ADD_VOL_HIGH)
      end
    end
    class Scene_VolConfig < Scene_MenuBase
      #-------------------------------------------------------------------------
      # ● Start processing
      #-------------------------------------------------------------------------
      def start
        super
        create_help_window
        @command_window = Window_VolConfig.new
        @command_window.viewport = @viewport
        @command_window.set_handler(:cancel,   method(:return_scene))
        @help_window.set_text("You can adjust the volume（0：Mute～100:Max）\n←　Decrease　／　Increase　→")
      end
      #-------------------------------------------------------------------------
      # ● End processing
      #-------------------------------------------------------------------------
      def terminate
        super
        @command_window.dispose
        if HZM_VXA::AudioVol::USE_INI
          HZM_VXA::Ini.save('AudioVol', 'BGM', Audio.bgm_vol)
          HZM_VXA::Ini.save('AudioVol', 'BGS', Audio.bgs_vol)
          HZM_VXA::Ini.save('AudioVol', 'SE', Audio.se_vol)
          HZM_VXA::Ini.save('AudioVol', 'ME', Audio.me_vol)
        end
      end
    end
  end
end

if HZM_VXA::AudioVol::USE_INI
  # If the base script is not installed, it will work with the simplified version
  unless defined?(HZM_VXA::Ini)
    module HZM_VXA
      module Base
        GetPrivateProfileInt = Win32API.new('kernel32', 'GetPrivateProfileInt', %w(p p i p), 'i')
        WritePrivateProfileString = Win32API.new('kernel32', 'WritePrivateProfileString', %w(p p p p), 'i')
      end
      class Ini
        INI_FILENAME = './Game.ini'
        def self.load(section, key)
          HZM_VXA::Base::GetPrivateProfileInt.call(section, key, 100, INI_FILENAME).to_i
        end
        def self.save(section, key, value)
          HZM_VXA::Base::WritePrivateProfileString.call(section, key, value.to_i.to_s, INI_FILENAME) != 0
        end
      end
    end
  end
  # Read volume initial value
  Audio.bgm_vol = (HZM_VXA::Ini.load('AudioVol', 'BGM') or 100)
  Audio.bgs_vol = (HZM_VXA::Ini.load('AudioVol', 'BGS') or 100)
  Audio.se_vol  = (HZM_VXA::Ini.load('AudioVol', 'SE') or 100)
  Audio.me_vol  = (HZM_VXA::Ini.load('AudioVol', 'ME') or 100)
end