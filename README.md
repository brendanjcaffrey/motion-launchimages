# motion-launchimages

Automate taking your iPhone and/or iPad launch images (i.e. `Default-568h@2x.png`) with `rake launchimages`.

## Installation

Add this line to your application's Gemfile:

    gem 'motion-launchimages'

And then execute:

    bundle

## Usage

After your app has launched, let motion-launchimages know to take the screenshots:

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

If you need to do some processing to get your app ready for the screenshot, you can use `Motion::LaunchImages.taking?` to check whether the app is being screenshoted. For example, if you have a table in your main view, you might want to empty it out like this:

```ruby
class MainViewController
  def tableView(table, numberOfRowsInSection:section)
    return 0 if Motion::LaunchImages.taking?
    # ...
  end
end
```

## Running

Just run `rake launchimages`! The task will launch your app in the simulator several times with different screen sizes and save the screenshots in your resources directory with the correct names. It detects whether it's being run on an iPhone or iPad (or both) app and only takes the screenshots it needs to.

If you want to just take the screenshot at one resolution, you can run `rake take_launchimages=true device_name="iPhone 6 Plus"` (for example). Any of the iPhone or iPad devices should work. You can get a full list of what's available by opening the simulator, going to the `Hardware` menu and looking under `Device`.

## Contact

[Brendan J. Caffrey](http://brendan.jcaffrey.com/)
