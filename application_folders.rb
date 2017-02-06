require "pathname"

module EnemyOfTheState
  class << self
    attr_accessor :application_directories
  end

  module ApplicationFolders
    extend self

    def exclude?(method)
      file, _ = method.source_location
      return true unless file

      !included_in?(expand_path(file), EnemyOfTheState.application_directories)
    end

    private

    def expand_path(f)
      Pathname.new(f).expand_path
    end

    SEPARATOR = "/"

    def included_in?(p1, paths)
      paths.any? do |p2|
        common = common_parent(p1, p2)
        common.to_s.length >= p2.to_s.length
      end
    end

    def common_parent(path_a, path_b)
      dirs = [
        Pathname.new(path_a.to_s).expand_path,
        Pathname.new(path_b.to_s).expand_path,
      ]

      dir1, dir2 = dirs.sort.map { |dir| dir.to_s.split(SEPARATOR) }
      append_trailing_slash!(path_from(dir1, dir2, path_a, path_b).to_s)
    end

    private

    def path_from(dir1, dir2, path_a, path_b)
      common_path = common_path(dir1, dir2)
      common_path, path_a, path_b = append_trailing_slashes!(common_path, path_a, path_b)

      Pathname.new(common_path) if valid_length?(common_path, path_a, path_b)
    end

    def valid_length?(common_path, path_a, path_b)
      l = common_path.to_s.length
      (l <= path_a.to_s.length) || (l <= path_b.to_s.length)
    end

    def common_path(dir1, dir2)
      dir1.
        zip(dir2).
        take_while { |dn1, dn2| dn1 == dn2 }.
        map(&:first).
        join(SEPARATOR)
    end

    def append_trailing_slash!(path)
      path = path.to_s

      if Pathname.new(path).directory?
        path += SEPARATOR if path && path.to_s[-1] != SEPARATOR
      end

      path
    end

    def append_trailing_slashes!(*paths)
      paths.map do |path|
        append_trailing_slash!(path)
      end
    end

  end
end


