require 'open3'
require_relative 'motion/devices.rb'

unless defined?(Motion::Project::Config)
  raise 'This file must be required within a RubyMotion project Rakefile.'
end

def get_screenshot_path
  Dir.pwd + '/resources/'
end

Motion::Project::App.setup do |app|
  Dir.glob(File.join(File.dirname(__FILE__), 'motion/*.rb')).each do |file|
    app.files.unshift(file)

    if ENV.has_key?('take_launchimages')
      app.info_plist['screenshot_path'] = get_screenshot_path

      if !ENV.has_key?('device_name')
        puts "The device_name environment key must be specified to motion-launchimages to run"
        exit
      end
      app.info_plist['device_name'] = ENV['device_name']

      # this is done both in the `rake launchimages` process and the `rake` process because this can be ran directly
      # and errors don't propogate up to the parent process (which is something that should probably be fixed)
      Motion::LaunchImages.get_device(ENV['device_name']).check_screenshots_exists
    end
  end
end

class Device
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

desc 'Take launch images of your app at all display resolutions'
task :launchimages do
  family = Motion::Project::App.config.device_family
  family = [family] if family.is_a?(Symbol)

  family -= [:iphone] if ENV['type'].to_s.downcase == 'ipad'
  family -= [:ipad]   if ENV['type'].to_s.downcase == 'iphone'

  devices = {}
  devices.merge!(Motion::LaunchImages.iphones) if family.index(:iphone) != nil
  devices.merge!(Motion::LaunchImages.ipads)   if family.index(:ipad)   != nil

  devices.each do |device_name, device_specs|
    device_specs.check_screenshots_exists

    puts "Taking screenshot on #{device_name}"
    Open3.popen3({'take_launchimages' => 'true', 'device_name' => device_name}, 'rake') do |i, o, e, s|
      o.read
    end
  end
end
