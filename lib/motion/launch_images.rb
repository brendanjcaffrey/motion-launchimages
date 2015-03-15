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

        Dispatch::Queue.main.async { capture! }
      end
    end

    def self.capture!
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
      filename = generate_filename(height, scale)

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

      if should_rotate_and_take_again?(height)
        take!(:landscape)
      else
        exit
      end
    end

    def self.generate_filename(height, scale)
      filename = screenshot_path + 'Default'

      case height
      when 480 # iPhone 4s
      when 568 # iPhone 5s
        filename << '-568h'
      when 667 # iPhone 6
        filename << '-667h'
      when 736 # iPhone 6 Plus
        filename << '-736h'
      when 768 # iPad (Landscape)
        filename << '-Landscape'
      when 1024 # iPad (Portrait)
        filename << '-Portrait'
      else
        puts "Error: Invalid screen height #{height}"
        exit
      end

      filename << scale << '.png'
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
      height == 1024 # iPad (Portrait)
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
