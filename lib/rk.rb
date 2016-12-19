# Build Redis keys of several elements, for example rk("user", 10) => "user:10"
class Rk
  attr_accessor :separator, :prefix, :suffix

  # Default separator is ":" (colon), prefix/suffix are empty
  def initialize
    @separator = ":"
    @prefix = ""
    @suffix = ""
  end

  # Build a string including prefix/suffix, joining all elements with the separator
  def rk(*elements)
    ([@prefix] + elements + [@suffix]).reject { |element| element.empty? }.join(@separator)
  end

  # Add methods dynamically to define/access elements
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

# Add method "rk" to the global namespace for using class "Rk"
class << self
  # Use rk.key = "value" to define key elements, rk.key to access key elements, and
  # rk(rk.key, 10) to build a key like "value:10".
  def rk(*elements)
    # Differ between calling "rk" without/with params
    if elements.empty?
      # Return "rk" object (of class Rk) for calling methods like "rk.separator"
      @_rk
    else
      # Call method "rk" (of class Rk) with params
      @_rk.rk(elements)
    end
  end
end

# Pollutes global namespace with variable "@_rk" used by method "rk", suggestions for
# improvements are welcome!
@_rk = Rk.new