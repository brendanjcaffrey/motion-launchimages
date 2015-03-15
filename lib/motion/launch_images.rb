module Motion
  class LaunchImages
    def self.screenshot_path
      NSBundle.mainBundle.objectForInfoDictionaryKey('screenshot_path')
    end

    def self.taking?
      screenshot_path != nil
    end

    def self.take!
      return unless taking?

      screen = UIScreen.mainScreen
      height = screen.bounds.size.height
      scale = begin
        if !screen.respondsToSelector('displayLinkWithTarget:selector:')
          ''
        elsif screen.scale == 2.0
          '@2x'
        elsif screen.scale == 3.0
          '@3x'
        else
          exit 'Error: Unable to determine screen scale'
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
      exit
    end

    def self.generate_filename(height, scale)
      filename = screenshot_path + 'Default'

      case height
      when 480
      when 568
        filename << '-568h'
      when 667
        filename << '-667h'
      when 736
        filename << '-736h'
      else
        exit "Error: Invalid screen height #{height}"
      end

      filename << scale << '.png'
    end

    # ported from BubbleWrap to reduce dependencies
    def self.window
      normal_windows = UIApplication.sharedApplication.windows.select { |w|
        w.windowLevel == UIWindowLevelNormal
      }

      key_window = normal_windows.select {|w|
        w == UIApplication.sharedApplication.keyWindow
      }.first

      key_window || normal_windows.first
    end
  end
end
