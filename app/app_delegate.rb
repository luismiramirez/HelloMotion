class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    #Application's window. It looks like a thing you have to do in every APP
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.applicationFrame)
    @window.makeKeyAndVisible

    #View <- Application's window
    @box_color = UIColor.blueColor
    @blue_view = UIView.alloc.initWithFrame(CGRect.new([10, 10], [100, 100]))
    @blue_view.backgroundColor = @box_color
    #Window <- we add the @blue_view as a subview to display in window frame
    @window.addSubview(@blue_view)
    add_labels_to_boxes

    #Button Object
    @add_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @add_button.setTitle("Add", forState: UIControlStateNormal)
    @add_button.sizeToFit
    #CGRect ([x, y], [width, height])
    @add_button.frame = CGRect.new(
        [10, @window.frame.size.height - 10 - @add_button.frame.size.height],
        @add_button.frame.size)
    #Window <- Button as a subview to display in window frame
    @window.addSubview(@add_button)

    #We add an action to a UIButton on the touchUp event (mouseup cousin)
    @add_button.addTarget(
        self, action: "add_tapped", forControlEvents: UIControlEventTouchUpInside
    )

    #Create a new button to remove the squares we create with @add_button
    @remove_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @remove_button.setTitle("Remove", forState: UIControlStateNormal)
    @remove_button.sizeToFit
    @remove_button.frame = CGRect.new(
        [@add_button.frame.origin.x + @add_button.frame.size.width + 10,
         @add_button.frame.origin.y],
         @remove_button.frame.size
    )

    @window.addSubview(@remove_button)

    @remove_button.addTarget(
        self, action: "remove_tapped", forControlEvents: UIControlEventTouchUpInside
    )

    #Adding a text field to receive colors as an input to change boxes bg
    @color_field = UITextField.alloc.initWithFrame(CGRectZero)
    @color_field.borderStyle = UITextBorderStyleRoundedRect
    @color_field.text = "Blue"
    @color_field.enablesReturnKeyAutomatically = true
    @color_field.returnKeyType = UIReturnKeyDone
    @color_field.autocapitalizationType = UITextAutocapitalizationTypeNone
    @color_field.sizeToFit
    @color_field.frame = CGRect.new(
        [@blue_view.frame.origin.x + @blue_view.frame.size.width + 10,
         @blue_view.frame.origin.y + @color_field.frame.size.height],
        @color_field.frame.size)
    @window.addSubview(@color_field)

    #This sets the colorfield delegate as itself to respond to events with callbacks
    #http://developer.apple.com/library/ios/#Documentation/UIKit/Reference/UITextFieldDelegate_Protocol/UITextFieldDelegate/UITextFieldDelegate.html.
    @color_field.delegate = self

    true
  end

  # This method creates a new view like @blue_view taking the reference from the
  # last blue_view on screen adding 10 pixels more of separation between
  # the previous. Adding the new_view as 0 index of the subviews[] of window
  def add_tapped
    new_view = UIView.alloc.initWithFrame(CGRect.new([0,0],[100,100]))
    new_view.backgroundColor = @box_color
    last_view = @window.subviews[0]
    new_view.frame = CGRect.new(
        [last_view.frame.origin.x,
         last_view.frame.origin.y + last_view.frame.size.height + 10],
         last_view.frame.size)

    @window.insertSubview(new_view, atIndex: 0)
    add_labels_to_boxes
  end

  #Removes the last Square in the subviews array with an animation
  def remove_tapped
    other_views = self.boxes
    @last_view = other_views.last

    if @last_view and other_views.size > 1
      UIView.animateWithDuration(1,
        animations: lambda{
          @last_view.alpha = 0
          @last_view.backgroundColor = UIColor.redColor
          other_views.each do |view|
            next if view == @last_view
            view.frame = CGRect.new(
                [view.frame.origin.x,
                 view.frame.origin.y - (@last_view.frame.size.height + 10)],
                 view.frame.size
            )
            end
        },

        completion: lambda{ |finished|
          @last_view.removeFromSuperview
          add_labels_to_boxes
        }
      )
    end
  end

  #We add a label as a subview of the box to display the index they take on window subviews
  def add_label_to_box(box)
    box.subviews.each do |subview|
      subview.removeFromSuperview
    end

    index_of_box = @window.subviews.index(box)
    label = UILabel.alloc.initWithFrame(CGRectZero)
    label.text = "#{index_of_box}"
    label.textColor = UIColor.whiteColor
    label.backgroundColor = UIColor.clearColor
    label.sizeToFit
    label.center = [box.frame.size.width / 2, box.frame.size.height / 2]
    box.addSubview(label)
  end

  def boxes
    @window.subviews.select do |view|
      not (view.is_a? UIButton or view.is_a? UILabel or view.is_a? UITextField)
    end
  end

  def add_labels_to_boxes
    self.boxes.each do |box|
      add_label_to_box(box)
    end
  end

  #Delegate method for @color_field (UITextField) reaction at 'done'
  def textFieldShouldReturn(textField)
    color_tapped
    textField.resignFirstResponder
    false #This avoids the normal behavior of textFieldShouldReturn, hiding de keyboard on 'done'
  end

  def color_tapped
    color_prefix = @color_field.text
    color_method = "#{color_prefix.downcase}Color"

    if UIColor.respond_to?(color_method)
      @box_color = UIColor.send(color_method)
      self.boxes.each do |box|
        box.backgroundColor = @box_color
      end
    else
      UIAlertView.alloc.initWithTitle("Invalid Color",
          message: "#{color_prefix} is not a valid color",
          delegate: nil,
          cancelButtonTitle: "Ok",
          otherButtonTitles: nil).show
    end
  end
end