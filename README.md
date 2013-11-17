# Call Me Maybe

Call Me Maybe is a simple event engine for Ruby. This event engine was modeled a little after the event engine from EvolutionSDK 3.0 and then taking it a step further. The idea here is that you can capture the call of any method as well as bind any method to listen for an event trigger and fire events. It's simply awesome!

## Dependencies

    * activesupport

## Installation

Add this line to your application's Gemfile:

    gem 'call_me_maybe'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install call_me_maybe

## Usage - Catching Method Calls

So this is really awesome. When it comes to use. So the real logic for awesome callbacks is this `call_me_maybe` method. This method is actually attached to the Module object so it's extremely versitile and is not instance or class specific.

The arguments for `call_me_maybe` are:

    - klass: Klass is the object that owns the method you are planning to track. If the method is on the same object as where you are executing `call_me_maybe`, then you do not need to pass this argument. Klass also accepts methods on the klass name if klass is provided as a string (i.e. "New.other"; where New is the class and other is the method).
    - method: Method is the method that you would like to call. Just the name of the method it does not matter whether or not the method is a singelton method or a instance method.
    - type: Type tells `call_me_maybe` which method to watch; the instance method or the singleton method. The acceptable options are either :class or :instance, :instance is set by default.
    - event: The method you would like to capture. The only supported events that the `call_me_maybe` method supports are :before and :after.
    - me: Me is hash arguments that refer to what should be run when the method you are tracking is called and the event is fired.
        * when: When is the event you want your task to run on. It is synonymous with the event: option
        * event: When is the event you want your task to run on. It is synonymous with the when: option
        * block: Block a Proc object that will be called when the event is fired. You can also pass a block to `call_me_maybe` and it will be used here instead. If you pass a block then the klass-method pairing for the callbacks will not be fired.
        * klass: So this klass is the reference to the object that you want to run the method on when the event fires. This accepts a klass object, klass string name or a klass string name with a method attached (see example above).
        * method: Method is the method you wish to run on the klass provided to to be used when the event fires.

```ruby
class New
  def apple
    puts "Apples are tasty ^_^"
  end

  def self.orange
    puts "Oranges are too sweet for me ^.^'"
  end

  call_me_maybe klass: "#{self}", method: :apple, event: :before do
    puts "Before Callback: Instance Level"
  end

  call_me_maybe klass: "#{self}", method: :orange, type: :class, event: :before do
    puts "Before Callback: Class Method"
  end

  call_me_maybe method: :apple, event: :after do
    puts "After Callback: Instance Level"
  end

  call_me_maybe klass: "New.orange", type: :class, event: :after do
    puts "After Callback: Class Method"
  end
end
```

## Usage - Registering Events and Triggers

Coming Soon

```ruby
CallMeMaybe::Exchange.add_listener

CallMeMaybe::Exchange.trigger
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
