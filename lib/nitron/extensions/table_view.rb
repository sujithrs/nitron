module Nitron
  class TableView < UITableView
    attr_accessor :_keyboardVisible, :_keyboardRect, :_priorInset, :_priorInsetSaved

    def setup
      NSNotificationCenter.defaultCenter.addObserver(self, 
        selector:'keyboardWillShow:', name:UIKeyboardWillShowNotification, 
        object:nil)
      NSNotificationCenter.defaultCenter.addObserver(self, 
        selector:'keyboardWillHide:', name:UIKeyboardWillHideNotification, 
        object:nil)
    end

    def initWithFrame(frame)
      super
      self and self.setup and self
    end

    def initWithFrame(frame, style:style)
      super
      self and self.setup and self
    end

    def initWithCoder(aDecoder)
      super
      self and self.setup and self
    end

    def dealloc
      NSNotificationCenter.defaultCenter.removeObserver(self)
    end

    def setFrame(frame)
      super
      self.contentInset = self.contentInsetForKeyboard if self._keyboardVisible 
    end

    def setContentSize(contentSize)
      super
      self.contentInset = self.contentInsetForKeyboard if self._keyboardVisible
    end

    def touchesEnded(touches, withEvent:event)
      responder = self.findFirstResponderBeneathView(self)
      responder and responder.resignFirstResponder
      super
    end 

    #define _UIKeyboardFrameEndUserInfoKey 
    #(&UIKeyboardFrameEndUserInfoKey != NULL ? 
    #UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")
    #
    def keyboardWillShow(notification)
      self._keyboardRect = notification.userInfo.objectForKey(
                                UIKeyboardFrameEndUserInfoKey).CGRectValue
      self._keyboardVisible = true
      
      firstResponder = self.findFirstResponderBeneathView(self)
      return unless firstResponder # No child view is the first responder 
      
      unless self._priorInsetSaved
        self._priorInset = self.contentInset
        self._priorInsetSaved = true
      end
      
      # Shrink view's inset by the keyboard's height, and 
      # scroll to show the text field/view being edited
      UIView.beginAnimations(nil, context:nil)
      UIView.setAnimationCurve(notification.userInfo.objectForKey(UIKeyboardAnimationCurveUserInfoKey).intValue)
      UIView.setAnimationDuration(notification.userInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey).floatValue)
      
      self.contentInset = self.contentInsetForKeyboard
      space = self.keyboardRect.origin.y - self.bounds.origin.y
      self.setContentOffset([self.contentOffset.x,
        self.idealOffsetForView(firstResponder, withSpace:space)], animated:true)
      self.setScrollIndicatorInsets(self.contentInset)
      
      UIView.commitAnimations
    end

    def keyboardWillHide(notification)
      self._keyboardRect = CGRectZero
      self._keyboardVisible = false
      
      # Restore dimensions to prior size
      UIView.beginAnimations(nil, context:nil)
      UIView.setAnimationCurve(notification.userInfo.objectForKey(UIKeyboardAnimationCurveUserInfoKey).intValue)
      UIView.setAnimationDuration(notification.userInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey).floatValue)
      self.contentInset = self._priorInset
      self.setScrollIndicatorInsets(self.contentInset)
      self._priorInsetSaved = false
      UIView.commitAnimations
    end

    def findFirstResponderBeneathView(view)
      # Search recursively for first responder
      view.subviews.each do |childView|
        return childView if childView.respond_to?(:isFirstResponder) && childView.isFirstResponder 
        result = self.findFirstResponderBeneathView(childView)
        return result if result
      end
      nil
    end

    def contentInsetForKeyboard
      newInset = self.contentInset
      keyboardRect = self.keyboardRect
      newInset.bottom = keyboardRect.size.height - ((keyboardRect.origin.y+keyboardRect.size.height) - (self.bounds.origin.y+self.bounds.size.height))
      newInset
    end

    def idealOffsetForView(view, withSpace:space)
      
      # Convert the rect to get the view's distance from the top of the scrollView.
      rect = view.convertRect(view.bounds, toView:self)
      
      # Set starting offset to that point
      offset = rect.origin.y
      
      if self.contentSize.height - offset < space
        # Scroll to the bottom
          offset = self.contentSize.height - space
      else
        if view.bounds.size.height < space 
          # Center vertically if there's room
          offset -= floor((space-view.bounds.size.height)/2.0)
        end
          if offset + space > self.contentSize.height
            # Clamp to content size
            offset = self.contentSize.height - space
        end
      end
      offset < 0 ? 0 : offset
    end

    def adjustOffsetToIdealIfNeeded
      # Only do this if the keyboard is already visible
      return unless self._keyboardVisible 
      
      visibleSpace = self.bounds.size.height - self.contentInset.top - 
                                self.contentInset.bottom
      
      idealOffset = [0, self.idealOffsetForView(self.findFirstResponderBeneathView(self), withSpace:visibleSpace)]
      
      self.setContentOffset(idealOffset, animated:true)     
    end

    def keyboardRect
      keyboardRect = self.convertRect(self._keyboardRect, fromView:nil)
      if keyboardRect.origin.y == 0
        screenBounds = self.convertRect(UIScreen.mainScreen.bounds, fromView:nil)
        keyboardRect.origin = [0, screenBounds.size.height - keyboardRect.size.height]
      end
      keyboardRect
    end

  end
end
