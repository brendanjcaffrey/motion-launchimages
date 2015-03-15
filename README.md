# motion-launchimages

Automate taking your launch images (i.e. `Default-568h@2x.png`) with `rake launchimages`.

## Installation

Add this line to your application's Gemfile:

    gem 'motion-launchimages'

And then execute:

    bundle

## Usage

After your app has launched, let motion-launchimages know to take the screenshot:

```ruby
class AppDelegate

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    # ...

    Motion::LaunchImages.take!
    true
  end
end
```

This method does nothing if it's not taking screenshots, so it's safe to leave in your code.

If you need to do some processing to get your app in the state it needs to be in for the screenshot, you can use `Motion::LaunchImages.taking?` to check whether the app is being prepared to take a screenshot. For example, if you have a table in your main view, you might want to empty it out like this:

```ruby
class MainViewController
  def tableView(table, numberOfRowsInSection:section)
    return 0 if Motion::LaunchImages.taking?
    # ...
  end
end
```

## Running

Just run `rake launchimages`! The task will launch your app in the simulator at 3 different screen resolutions and save the screenshots in your resources directory with the correct names.

If you want to just take the screenshot at one resolution, you can run `rake take_launchimages=true device_name="iPhone 6 Plus"` for example. Any iPhone device will work.

## Contact

[Brendan J. Caffrey](http://brendan.jcaffrey.com/)
