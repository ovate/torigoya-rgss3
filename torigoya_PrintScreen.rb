# coding: utf-8
#===============================================================================
# ■ PrintScreen Screenshot for RGSS3
#-------------------------------------------------------------------------------
#　2012/06/10　Ru/むっくRu (Rutan) | English translation by tale 2017/02/12
# License - Public Domain, allows commercial use and credit is not necessary
#-------------------------------------------------------------------------------
#  Press PrintScreen to save the screenshot inside the project folder "screenshot"
#  Adds a function to save a screenshot of the game screen
#  （Countermeasures against lag, screens are created after several seconds）
#-------------------------------------------------------------------------------
# 【Issues】
#  Game frame rate drops a bit during saving
#-------------------------------------------------------------------------------
# 【Changelogs】
# 2012/06/10 Fixed an issue that causes force quit when pressing F12 during save.
# 2012/01/07 Fixed a bug where it doesn't work well during battle?
# 2011/12/27 Release
#-------------------------------------------------------------------------------
# 【Reference：PNG file processing】
#  http://d.hatena.ne.jp/ku-ma-me/20091003/p1
#-------------------------------------------------------------------------------

#===============================================================================
# ● Item settings
#===============================================================================
module HZM_VXA
  module ScreenShot
    # Name of the folder
    DIRNAME = 'screenshot'
    # File name to be saved．No extension（.png）required
    # 　%Y …… Year
    # 　%m …… Month(01-12)
    # 　%d …… Day(01-31)
    # 　%H …… Hour(00-23)
    # 　%M …… Minute(00-59)
    # 　%S …… Second(00-59)
    FILENAME = "%Y%m%d_%H%M%S"
    
    # Display texts on the screenshot
    #   true  …… On
    #   false …… Off
    USE_COPYRIGHT = false
    # Texts shown in the screen
    COPYRIGHT_TEXT = '(C) birdhouse.txt'
    # Text's color
    COPYRIGHT_COLOR = Color.new(255, 255, 255)
    # Text's size
    COPYRIGHT_SIZE  = 16
    # Text's position (0: Left, 1: Center, 2: Right)
    COPYRIGHT_ALIGN = 2
    
    # Number of times to process 1 frame
    # ※Increasing the value will shorten the process of generating the file，
    #   Amount of load time increases when the processing dramatically drops
    RUN_SPEED = 3
  end
end

#===============================================================================
# ↑    Setup goes here    ↑
# ↓ for less, script there ↓
#===============================================================================

module HZM_VXA
  module ScreenShot
    VK_SNAPSHOT = 0x2c
    GetKeyState = Win32API.new('user32', 'GetKeyState', %w(l), 'i')
    #---------------------------------------------------------------------------
    # ● Startup
    #---------------------------------------------------------------------------
    def self.init
      @pressed = false
      @list = []
    end
    #---------------------------------------------------------------------------
    # ● Update
    #---------------------------------------------------------------------------
    def self.update
      add  if press?
      RUN_SPEED.times { develop }
    end
    #---------------------------------------------------------------------------
    # ● PrintScreen monitor
    #---------------------------------------------------------------------------
    def self.press?
      if @pressed
        @pressed = (GetKeyState.call(VK_SNAPSHOT) < 0)
        false
      else
        @pressed = (GetKeyState.call(VK_SNAPSHOT) < 0)
      end
    end
    #---------------------------------------------------------------------------
    # ● Addition to development waiting
    #---------------------------------------------------------------------------
    def self.add
      bitmap = Graphics.snap_to_bitmap
      if USE_COPYRIGHT
        bitmap.font.size  = COPYRIGHT_SIZE
        bitmap.font.color = COPYRIGHT_COLOR
        bitmap.draw_text(0, bitmap.height - COPYRIGHT_SIZE, bitmap.width, COPYRIGHT_SIZE, COPYRIGHT_TEXT, COPYRIGHT_ALIGN)
      end
      filename = "#{Time.now.getlocal.strftime(FILENAME)}"
      @list.push({
        :bitmap => bitmap,
        :filename => filename
      })
    end
    #---------------------------------------------------------------------------
    # ● Development
    #---------------------------------------------------------------------------
    def self.develop
      return if @list.empty?
      data = @list.first
      if data[:line] == nil  # Unconditional
        data[:line] = 0
        data[:img] = []
      elsif data[:line] < data[:bitmap].height # Analyzing
        data[:img].push 0
        for i in 0...data[:bitmap].width
          c = data[:bitmap].get_pixel(i, data[:line])
          data[:img].push(c.red, c.green, c.blue)
        end
        data[:line] += 1
      else  # Saving
        Dir.mkdir(DIRNAME) unless File.exist?(DIRNAME)
        cnt = Dir.glob("#{DIRNAME}/#{data[:filename]}*.png").size
        footer = cnt > 0 ? "_#{cnt}" : ""
        File.open("#{DIRNAME}/#{data[:filename]}#{footer}.png", 'wb') do |file|
          file.write "\x89PNG\r\n\x1a\n"
          file.write createChunk('IHDR', [data[:bitmap].width, data[:bitmap].height, 8, 2, 0, 0, 0].pack('N2C5'))
          file.write createChunk('IDAT', Zlib::Deflate.deflate(data[:img].pack('C*')))
          file.write createChunk('IEND', '')
        end
        data[:bitmap].dispose
        @list.shift
      end
    end
    #---------------------------------------------------------------------------
    # ● Create PNG chunk data
    #---------------------------------------------------------------------------
    def self.createChunk(type, data)
      [data.bytesize, type, data, Zlib.crc32(type + data)].pack('NA4A*N')
    end
  end
end

class Scene_Base
  #-----------------------------------------------------------------------------
  # ● Screenshot update
  #-----------------------------------------------------------------------------
  alias hzm_vxa_screenshot_update_basic update_basic
  def update_basic
    hzm_vxa_screenshot_update_basic
    HZM_VXA::ScreenShot.update
  end
end

class << SceneManager
  #-----------------------------------------------------------------------------
  # ● Execution
  #-----------------------------------------------------------------------------
  alias hzm_vxa_screenshot_run run
  def run
    HZM_VXA::ScreenShot.init
    hzm_vxa_screenshot_run
  end
end