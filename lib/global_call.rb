# frozen_string_literal: true

module Rk
  # Anonymous module for including +rk+ to global namespace (class Object).
  class GlobalCall < Module
    def initialize(rk_instance)
      rk_name = if rk_instance.rk_name.to_s.empty?
        "rk"
      else
        "#{rk_instance.rk_name}_rk"
      end

      $_rk ||= {}
      $_rk[rk_name] = rk_instance

      super() do
        define_method rk_name do |*elements|
          if elements.empty?
            $_rk[rk_name]
          else
            $_rk[rk_name].rk(elements)
          end
        end
      end
    end
  end
end
