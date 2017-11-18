module Motion
  class LaunchImages
    def self.screenshot_path
      NSBundle.mainBundle.objectForInfoDictionaryKey('screenshot_path')
    end

    def self.device_name
      NSBundle.mainBundle.objectForInfoDictionaryKey('device_name')
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
      # sanity check the device values
      screen = UIScreen.mainScreen
      height = screen.bounds.size.height.to_i
      scale = screen.respondsToSelector('displayLinkWithTarget:selector:') ? screen.scale.to_i : 1
      device = get_device(device_name)
      expected_height = (orientation == :portrait ? device.height : device.width) / device.scale

      if expected_height != height || device.scale != scale
        puts "In #{orientation.to_s}, height was expected to be #{expected_height} but was #{height} and/or scale was expected to be #{device.scale} but was #{scale}"
        exit
      end

      if scale > 1
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, screen.scale)
      else # TODO not sure if this is necessary anymore?
        UIGraphicsBeginImageContext(window.bounds.size)
      end

      filename = screenshot_path + device.filename(orientation)
      window.layer.renderInContext(UIGraphicsGetCurrentContext())
      image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      data = UIImagePNGRepresentation(image)
      data.writeToFile(filename, atomically:true)
      puts "Wrote to #{filename}"

      if orientation == :portrait && device.landscape
        take!(:landscape)
      else
        exit
      end
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
