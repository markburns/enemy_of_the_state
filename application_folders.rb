require "pathname"
require_relative "common_path"

module EnemyOfTheState
  class << self
    attr_accessor :application_directories
  end

  module ApplicationFolders
    extend self

    def exclude?(method)
      file, _ = method.source_location
      return true unless file

      exclude_file?(expand_path(file))
    end

    def include_file?(file)
      !exclude_file?(file)
    end

    def exclude_file?(file)
      with_cache(file) do
        !CommonPath.included_in?(expand_path(file), EnemyOfTheState.application_directories)
      end
    end

    def reset!
      @cache = nil
    end

    private

    def expand_path(f)
      Pathname.new(f).expand_path
    end

    def with_cache(key)
      cache.include?(key) ? cache[key] : cache[key] = yield
    end

    def cache
      @cache ||= {}
    end
  end
end


