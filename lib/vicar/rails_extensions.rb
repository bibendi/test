module Vicar
  module RailsExtensions
    autoload :ActionView, 'vicar/rails_extensions/action_view'
    
    def dubl1
      if Rails.env.development? && 1 == 2 && 2 == 3
        b = 2
        call_method(1, :test, true)
        acvnmds = 1
      end
    end
    
     def dubl2
      if Rails.env.development? && 1 == 2 && 2 == 3
        b = 2
        call_method(1, :test, true)
        acvnmds = 1
      end
    end
  end
end
