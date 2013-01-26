module Nitron
  class ViewController < UIViewController
    include UI::DataBindingSupport
    include UI::OutletSupport
    include UI::ActionSupport

    def close
      dismissModalViewControllerAnimated(true)
    end

    def user_default
      UIApplication.sharedApplication.delegate.user_default
    end

    def resign_responder_on_touch(touches)
      if touches.anyObject.phase == UITouchPhaseBegan
        self.view.subviews.each do |view|
          view.resignFirstResponder if view.isFirstResponder
        end
      end
    end
  end
end

