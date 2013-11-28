module CallMeMaybe
  module Exchange
    class Careful < StandardError; end
    class MethodDoesNotExist < StandardError; end
    class CantCaptureMethod < StandardError; end

    mattr_accessor :methods, instance_accessor: false
    mattr_accessor :listeners, instance_accessor: false

    class << self
      def add_method(args = {})
        id, name = get_id(args)

        # Create the cache
        CallMeMaybe::Exchange.methods ||= {}

        # Create the method if needed
        if CallMeMaybe::Exchange.methods[id] && ! CallMeMaybe::Exchange.methods[id].has_key?(:method_obj)
          CallMeMaybe::Exchange.methods[id].merge!(args)
          true
        elsif ! methods[id]
          CallMeMaybe::Exchange.methods[id] = args.merge(name: name)
          true
        else
          false
        end
      end

      def get_method(args = {})
        # Ensure the cache's presence
        CallMeMaybe::Exchange.methods ||= {}
        raise MethodDoesNotExist unless method_exists?(args)
        CallMeMaybe::Exchange.methods[get_id(args).first][:method_obj]
      end

      def method_exists?(args = {})
        # Ensure the cache's presence
        CallMeMaybe::Exchange.methods ||= {}
        CallMeMaybe::Exchange.methods.has_key?(get_id(args).first)
      end

      def del_method(args = {})
        raise Careful, "Please use `del_method!` if you really want to do this."
      end

      def del_method!(args = {})
        # Ensure the cache's presence
        CallMeMaybe::Exchange.methods ||= {}
        CallMeMaybe::Exchange.methods.delete(get_id(args).first)
        true
      end

      def trigger(event, obj, args = {}, &block)
        id = get_id(args).first

        # Prepare the cache
        CallMeMaybe::Exchange.listeners ||= {}
        CallMeMaybe::Exchange.listeners[event] ||= {}
        CallMeMaybe::Exchange.listeners[event][id] ||= []

        # Run the listening events
        CallMeMaybe::Exchange.listeners[event][id].map do |callback|
          if callback[:block] && callback[:block].is_a?(Proc)
            callback[:block].call(obj, args[:meta], &block)
          else
            callback[:klass].constantize.__send__(callback[:method], obj, args[:meta], &block)
          end
        end

        CallMeMaybe::Exchange.listeners[event][id].count
      end

      def add_listener(args = {}, &block)

        # Prepare the listeners data
        args[:me]         ||= {}
        args[:me][:when]  ||= args.delete(:when)  if args.has_key?(:when)
        args[:me][:when]  ||= args.delete(:event) if args.has_key?(:event)
        args[:me][:block] ||= args.delete(:block) if args.has_key?(:block)
        args[:me][:block] ||= block               if block_given?

        # Ensure that our event name we are capturing is in the right format
        args[:me][:when] = "#{args[:me][:when]}".underscore.to_sym if args[:me].has_key?(:when)

        # Get id
        id = get_id(args).first

        # Prepare the cache
        CallMeMaybe::Exchange.listeners ||= {}
        CallMeMaybe::Exchange.listeners[args[:me][:when]] ||= {}
        CallMeMaybe::Exchange.listeners[args[:me][:when]][id] ||= []

        # Add the details to the cache
        if args[:block].is_a?(Proc)
          CallMeMaybe::Exchange.listeners[args[:me][:when]][id] << args[:me][:block]
        else
          CallMeMaybe::Exchange.listeners[args[:me][:when]][id] << args[:me]
        end

        # Unique on the callbacks
        a = CallMeMaybe::Exchange.listeners[args[:me][:when]][id].uniq
        CallMeMaybe::Exchange.listeners[args[:me][:when]][id] = a
        true
      end

      private

      # Return the cache id.
      def get_id(args = {})
        if args.has_key?(:type) && args.has_key?(:klass) && args.has_key?(:method)
          name = "#{args[:type]}: #{args[:klass]}.#{args[:method]}".to_sym
          [name.object_id, name]
        elsif args.has_key?(:name)
          ["#{args[:name]}".downcase.to_sym]
        else
          raise CantCaptureMethod, "We need name; or type, klass and method passed in order to generate an id properly."
        end
      end
    end
  end
end
