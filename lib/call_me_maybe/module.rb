module CallMeMaybe
  class MissingArgs < StandardError; end

  module Module
    def call_me_maybe(args = {}, &block)

      ###################
      #= Listener Data =#
      ###################

      # Prepare the listeners data
      args[:me]         ||= {}
      args[:me][:when]  ||= args.delete(:when)  if args.has_key?(:when)
      args[:me][:when]  ||= args.delete(:event) if args.has_key?(:event)
      args[:me][:block] ||= args.delete(:block) if args.has_key?(:block)
      args[:me][:block] ||= block               if block_given?

      # Ensure that our event name we are capturing is in the right format
      args[:me][:when] = "#{args[:me][:when]}".underscore.to_sym if args[:me].has_key?(:when)

      #####################
      #= Capture Wrapper =#
      #####################

      # Default to catching instance methods
      # and ensure klass is present and a string
      args[:type]  ||= :instance
      args[:klass] ||= self
      args[:klass]   = "#{args[:klass]}"

      # If the method was attached to the klass name
      # then go ahead and parse it out
      if args[:klass].include?('.')
        klass, method = args[:klass].split('.')

        args[:klass]  = klass
        args[:method] = method
      end

      # Ensure we have the klass and method we are capturing
      raise MissingArgs, "We need the klass we are capturing" unless args[:klass]
      raise MissingArgs, "We need the method we are capturing" unless args[:method]

      # Prepare the format for the klass, method, type and event firing time
      args[:klass]  = "#{args[:klass]}".camelize
      args[:method] = "#{args[:method]}".underscore.to_sym
      args[:type]   = "#{args[:type]}".downcase.to_sym

      # Don't bother re-adding the method if it is already added
      unless CallMeMaybe::Exchange.method_exists?(args)

        # Constantize the klass
        klass = args[:klass].constantize

        # Add method args
        margs = args.dup
        margs.delete(:me)

        # Proc for setting up the capturing of the method in question
        capture_proc = Proc.new do
          gmethod = args[:type] == :instance ? :instance_method : :method
          cmethod = args[:type] == :instance ? :define_method : :define_singleton_method
          CallMeMaybe::Exchange.add_method(margs.merge(method_obj: klass.__send__(gmethod, args[:method])))

          klass.__send__(cmethod, args[:method]) do |*a, &b|

            # Trigger before method is called callback
            CallMeMaybe::Exchange.trigger(:before, self, args.merge(meta: {args: a, block: b}))

            # Run the actual method using the CallMeMaybe cache
            result = CallMeMaybe::Exchange.get_method(args)
            result = (result.is_a?(UnboundMethod) ? result.bind(self) : result).call(*a, &b)

            # Trigger after method is called callback
            CallMeMaybe::Exchange.trigger(:after, self, args.merge(meta: {args: a, block: b, result: result}))

            # Return the result
            result
          end
        end

        # Apply capture_proc to the klasses that we need to use
        if args[:type] == :class && klass.singleton_methods.include?(args[:method])
          klass.class.__send__(:class_exec, &capture_proc)
        elsif args[:type] == :instance && klass.instance_methods.include?(args[:method])
          klass.__send__(:class_exec, &capture_proc)
        end
      end

      ####################
      #= Listener Stuff =#
      ####################

      # If we need to add a listener as well go ahead and start that implementation
      if args.has_key?(:me) && ! args[:me].empty?

        # We need an event to listen to.
        raise MissingArgs, "We need the event that we are capturing." unless args[:me][:when] || args[:me][:event]

        # We need information on who to call when the event occurs
        unless args[:me][:block] || (args[:me][:klass] && args[:me][:method])
          raise MissingArgs, "We need the a proc, block or information on what to run when the event occurs."
        end

        # Faking some arguments
        args[:me][:klass] ||= args[:klass]
        if args[:me][:block] && ( ! args[:me][:klass] || ! args[:me][:method])
          args[:me][:klass]  = 'Proc'
          args[:me][:method] = 'call'
        end

        # Add a listener for the method declared here
        CallMeMaybe::Exchange.add_listener(args)
      end
    end
  end
end
