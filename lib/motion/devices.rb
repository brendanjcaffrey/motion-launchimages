module Motion
  Device = Struct.new(:width, :height, :scale, :landscape, :no_height_label) do
    def filename(orientation)
      if orientation == :portrait
        size_measurement = height/scale
        orientation_label = landscape ? '-Portrait' : ''
      elsif orientation == :landscape
        size_measurement = width/scale
        orientation_label = '-Landscape'
      end
      size_label = no_height_label ? '' : "-#{size_measurement}h"

      "Default#{orientation_label}#{size_label}@#{scale}x.png"
    end

    def filepath(orientation)
      "#{get_screenshot_path}#{filename(orientation)}"
    end

    def check_screenshots_exists
      check_screenshot_exists(:portrait)
      check_screenshot_exists(:landscape) if landscape
    end

    private

    def check_screenshot_exists(orientation)
      if !File.exists?(filepath(orientation))
        puts "Error: Please make sure #{filepath(orientation)} exists before running. The app will not launch with the correct screensize otherwise."
        puts "You should be able to download an example one at https://github.com/brendanjcaffrey/motion-launchimages/tree/master/sample/resources/#{filename(orientation)}"
        exit
      end
    end
  end

  class LaunchImages
    def self.iphones
      {
        'iPhone SE'     => Device.new(640,  1136, 2, false, false), # also iPhone 5s
        'iPhone 8'      => Device.new(750,  1334, 2, false, false), # also iPhone 6/7
        'iPhone 8 Plus' => Device.new(1242, 2208, 3, false, false), # also iPhone 6/7 Plus
        'iPhone X'      => Device.new(1125, 2436, 3, false, false),
      }
    end

    def self.ipads
      {
        'iPad Pro (9.7-inch)'  => Device.new(1536, 2048, 2, true, true),
        'iPad Pro (10.5-inch)' => Device.new(1668, 2224, 2, true, false),
        'iPad Pro (12.9-inch)' => Device.new(2048, 2732, 2, true, false),
      }
    end

    def self.get_device(name)
      if iphones.has_key?(name)
        iphones[name]
      elsif ipads.has_key?(name)
        ipads[name]
      else
        puts "Unable to find device #{name}"
        exit
      end
    end
  end
end

