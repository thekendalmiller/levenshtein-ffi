require 'ffi'

module Levenshtein
  class << self
    extend FFI::Library

    library = "levenshtein.#{RbConfig::MAKEFILE_CONFIG['DLEXT']}"
    candidates = ["#{__FILE__}/..", "#{__FILE__}/../../ext/levenshtein"]
    candidates.unshift(Gem.loaded_specs['levenshtein-ffi'].extension_dir) if Gem.loaded_specs['levenshtein-ffi']
    ffi_lib(candidates.map { |dir| File.expand_path(library, dir) })

    # Safe version of distance, checks that arguments are really strings.
    def distance(str1, str2)
      validate(str1)
      validate(str2)
      ffi_distance(str1, str2)
    end

    # Unsafe version. Results in a segmentation fault if passed nils!
    attach_function :ffi_distance, :levenshtein, [:string, :string], :int

    private
    def validate(arg)
      unless arg.kind_of?(String)
        raise TypeError, "wrong argument type #{arg.class} (expected String)"
      end
    end
  end
end
