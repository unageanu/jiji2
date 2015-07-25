module Jiji::Utils
  class Strings

    def self.mask(string, length = 1)
      return '' unless string
      return 'x' * string.length if string.length - length <= 0
      string[0, length] + 'x' * (string.length - length)
    end

  end
end
