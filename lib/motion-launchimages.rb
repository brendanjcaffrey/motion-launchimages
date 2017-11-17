require 'open3'

unless defined?(Motion::Project::Config)
  raise 'This file must be required within a RubyMotion project Rakefile.'
end

Motion::Project::App.setup do |app|
  Dir.glob(File.join(File.dirname(__FILE__), 'motion/*.rb')).each do |file|
    app.files.unshift(file)

    if ENV.has_key?('take_launchimages')
      app.info_plist['screenshot_path'] = Dir.pwd + '/resources/'
    end
  end
end

desc 'Take launch images of your app at all display resolutions'
task :launchimages do
  devices = []
  family = Motion::Project::App.config.device_family
  family = [family] if family.is_a?(Symbol)

  if family.index(:iphone) != nil
    devices << 'iPhone SE' << 'iPhone 8' << 'iPhone 8 Plus' << 'iPhone X'
  end

  if family.index(:ipad) != nil
    devices << 'iPad Pro (9.7-inch)' << 'iPad Pro (10.5-inch)' << 'iPad Pro (12.9-inch)'
  end

  devices.each do |device|
    puts "Taking screenshot on #{device}"
    Open3.popen3({'take_launchimages' => 'true', 'device_name' => device}, 'rake') do |i, o, e, s|
      o.read
    end
  end
end
