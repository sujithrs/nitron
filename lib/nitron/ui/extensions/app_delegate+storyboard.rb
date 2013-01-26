class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    if storyboard
      @window.rootViewController = storyboard.instantiateInitialViewController
    end

    @window.rootViewController.wantsFullScreenLayout = true
    @window.makeKeyAndVisible

    true
  end

  def storyboard
    @storyboard ||= 
      UIStoryboard.storyboardWithName("MainStoryboard_#{device_type}", bundle:nil)
  end

  def user_default
    @user_default ||= UserDefault.new
  end

  def device_type
    @device_type ||= 
      UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone ?  "iPhone" : "iPad"
  end

end


