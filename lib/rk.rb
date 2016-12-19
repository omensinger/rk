# Module for including "rk" to global namespace (class Object)
module Rk

  # Build Redis keys of several elements, for example rk("user", 10) => "user:10"
  class Rk
    attr_accessor :separator, :prefix, :suffix

    # Set defaults, separator to ":", prefix/suffix is empty
    def initialize
      @separator = ":"
      @prefix = ""
      @suffix = ""
    end

    # Build a string including prefix/suffix, joining all elements with the separator
    def rk(*elements)
      ([@prefix] + elements + [@suffix]).reject { |element| element.to_s.empty? }.join(@separator)
    end

    # Add methods dynamically to define/access elements, for example
    # rk.user = "user"; rk(rk.user, 10) => "user:10"
    def method_missing(method, *arg)
      # Raise an error if a method gets accessed which was not defined before
      raise RuntimeError, "'rk.#{method.to_s}' is undefined" unless method.to_s.include?("=")

      # Define a method to return a value as set, for example rk.settings = 'set' defines
      # a method called "settings" which returns the string "set"
      instance_eval(%Q[
        def #{method.to_s.sub(/=/, "")}
          "#{(arg || []).first}"
        end
      ])
    end
  end

  # Create and call a global instance of Rk to either build a key or set/get attributes
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

# We could use "extend Rk" to extend only "main", but we would have to "include Rk" in
# any class, hence we include Rk to the global object.
class Object
  include Rk
end
