module Motion
  class LaunchImages
    def self.screenshot_path
      NSBundle.mainBundle.objectForInfoDictionaryKey('screenshot_path')
    end

    def self.taking?
      screenshot_path != nil
    end

    def self.take!(orientation = :portrait)
      return unless taking?

      Dispatch::Queue.main.async do
        if needs_rotation?(orientation)
          rotate(orientation)
          sleep 1.0
        end

        Dispatch::Queue.main.async { capture!(orientation) }
      end
    end

    def self.capture!(orientation)
      screen = UIScreen.mainScreen
      height = screen.bounds.size.height
      scale = begin
        if !screen.respondsToSelector('displayLinkWithTarget:selector:')
          ''
        elsif screen.scale == 1.0
          ''
        elsif screen.scale == 2.0
          '@2x'
        elsif screen.scale == 3.0
          '@3x'
        else
          puts 'Error: Unable to determine screen scale'
          exit
        end
      end
      filename = generate_filename(height, scale, orientation)

      if scale != ''
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, screen.scale)
      else
        UIGraphicsBeginImageContext(window.bounds.size)
      end

      window.layer.renderInContext(UIGraphicsGetCurrentContext())
      image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      data = UIImagePNGRepresentation(image)
      data.writeToFile(filename, atomically:true)
      puts "Wrote to #{filename}"

      if orientation == :portrait && should_rotate_and_take_again?(height)
        take!(:landscape)
      else
        exit
      end
    end

    def self.generate_filename(height, scale, orientation)
      height = height.to_i
      filename = screenshot_path + 'Default'

      if orientation == :portrait
        height_to_filename = {
          568 => '-568h', # iPhone 5s/SE
          667 => '-667h', # iPhone 6/7/8
          736 => '-736h', # iPhone 6/7/8 Plus
          812 => '-812h', # iPhone X

          1024 => '-Portrait', # iPad 9.7
          1112 => '-Portrait-1112h', # iPad 10.5
          1366 => '-Portrait-1366h', # iPad 12.9
        }
      elsif orientation == :landscape
        height_to_filename = {
          768 => '-Landscape', # iPad 9.7
          834 => '-Landscape-834h', # iPad 10.5
          1024 => '-Landscape-1024h', # iPad 12.9
        }
      else
        puts "Error: Invalid orientation #{orientation}"
        exit
      end

      if !height_to_filename.has_key?(height)
        puts "Error: Invalid screen height #{height}"
        exit
      end

      filename << height_to_filename[height] << scale << '.png'
    end

    # ported from BubbleWrap to reduce dependencies
    def self.window
      normal_windows = UIApplication.sharedApplication.windows.select { |w|
        w.windowLevel == UIWindowLevelNormal
      }

      key_window = normal_windows.select { |w|
        w == UIApplication.sharedApplication.keyWindow
      }.first

      key_window || normal_windows.first
    end

    def self.should_rotate_and_take_again?(height)
      # TODO consolidate this and the height_to_filename maps above
      height == 1024 || height == 1112 || height == 1366
    end

    def self.rotate(to)
      if to == :portrait
        value = NSNumber.numberWithInt(UIInterfaceOrientationPortrait)
      else
        value = NSNumber.numberWithInt(UIInterfaceOrientationLandscapeLeft)
      end

      UIDevice.currentDevice.setValue(value, forKey:'orientation')
    end

    def self.needs_rotation?(orientation)
      status = UIApplication.sharedApplication.statusBarOrientation
      if orientation == :portrait && status == UIInterfaceOrientationPortrait
        false
      elsif orientation == :landscape && (status == UIInterfaceOrientationLandscapeLeft ||
                                          status == UIInterfaceOrientationLandscapeRight)
        false
      else
        true
      end
    end
  end
end
