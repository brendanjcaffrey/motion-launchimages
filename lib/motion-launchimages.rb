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
  ['iPhone 5s', 'iPhone 6', 'iPhone 6 Plus'].each do |device|
    puts "Taking screenshot on #{device}"
    Open3.popen3({'take_launchimages' => 'true', 'device_name' => device}, 'rake') do |i, o, s|
      o.read
    end
  end
end
