module Bootscaf
  module Utils
    def self.singularize(str)
      unless str == str.gsub(/([^aeiouy])ies$/i, '\1y')
        return str.gsub(/([^aeiouy])ies$/i, '\1y')
      end
      unless str == str.gsub(/([^aeiouy]o)es$/, '\1')
        return str.gsub(/([^aeiouy]o)es$/, '\1')
      end
      unless str == str.gsub(/([sxz]|[cs]h)es$/, '\1')
        return str.gsub(/([sxz]|[cs]h)es$/, '\1')
      end
      unless str == str.gsub(/(ss)$/i, '\1')
        return str.gsub(/(ss)$/i, '\1')
      end
      unless str == str.gsub(/s$/i, '')
        return str.gsub(/s$/i, '')
      end
      return str
    end
  end
end
