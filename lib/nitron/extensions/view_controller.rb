module Nitron
  class ViewController < UIViewController
    #include UI::DataBindingSupport
    #include UI::OutletSupport
    #include UI::ActionSupport

    def close
      dismissModalViewControllerAnimated(true)
    end

    def user_default
      UIApplication.sharedApplication.delegate.user_default
    end

    def app_delegate
      UIApplication.sharedApplication.delegate
    end

    def resign_responder_on_touch(touches)
      if touches.anyObject.phase == UITouchPhaseBegan
        self.view.subviews.each do |view|
          view.resignFirstResponder if view.isFirstResponder
        end
      end
    end

    def settings_data
      @settings_data ||= SettingsData.new
    end


    def button_with_color(button, color)
      buttonImage = UIImage.imageNamed("#{color}Button.png").resizableImageWithCapInsets([18, 18, 18, 18])
      buttonImageHighlight = UIImage.imageNamed("#{color}ButtonHighlight.png").resizableImageWithCapInsets([18, 18, 18, 18])
      button.setBackgroundImage(buttonImage, forState:UIControlStateNormal)
      button.setBackgroundImage(buttonImageHighlight, forState:UIControlStateHighlighted)
    end
  end
end

