# Module for including +rk+ to global namespace (class Object).
module Rk

  # Build Redis keys of several elements.
  #   rk("user", 10) => "user:10"
  class Rk
    attr_accessor :separator, :prefix, :suffix, :keys

    # Set defaults
    # * <tt>separator</tt> - :
    # * <tt>prefix</tt> - empty
    # * <tt>suffix</tt> - empty
    # * <tt>keys</tt> - empty
    def initialize
      @separator = ":"
      @prefix = ""
      @suffix = ""
      @keys = {}
    end

    # Build a string including prefix/suffix, joining all elements with the separator.
    def rk(*elements)
      ([@prefix] + elements + [@suffix]).reject { |element| element.to_s.empty? }.join(@separator)
    end

    # Add methods dynamically to define/access elements.
    #   rk.user = "user"
    #   rk(rk.user, 10) => "user:10"
    def method_missing(method, *arg)
      # Raise an error if a method gets accessed which was not defined before
      raise RuntimeError, "'rk.#{method.to_s}' is undefined" unless method.to_s.include?("=")

      # Define a method to return a value as set, for example rk.settings = 'set' defines
      # a method called "settings" which returns the string "set"
      key = method.to_s.sub(/=/, "")
      val = (arg || []).first.to_s

      instance_eval(%Q[
        def #{key}
          "#{val}"
        end
      ])

      # Store user-defined key
      @keys[key] = val
    end

    # Define key elements by key/value pairs of a hash, symbols and strings allowed for
    # keys/values.
    #
    #   rk.keys = { user: "user", "statistics" => "stats", "session" => :sess }
    def keys=(h)
      # Allow hash only
      raise TypeError, "invalid type" unless h.is_a?(Hash)

      # Call rk.<key> = <val> for each pair of hash
      h.each_pair do |key, val|
        self.send("#{key}=", val)
      end
    end

  end # class Rk

  # Create and call a global instance of Rk to either build a key or set/get attributes.
  def rk(*elements)
    $_rk = Rk.new unless $_rk

    # Differ between calling "rk" without/with params
    if elements.empty?
      # Return instance of Rk for calling methods like "rk.separator"
      $_rk
    else
      # Return key build by Rk.rk
      $_rk.rk(elements)
    end
  end

end # module Rk

# We could use +extend Rk+ to extend only +main+, but we would have to +include Rk+ in
# any class, hence we include Rk to the global object.
class Object
  include Rk
end
