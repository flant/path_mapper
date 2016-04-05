require 'path_mapper/version'

require 'net_status'

require 'erb'
require 'ostruct'
require 'pathname'
require 'digest/md5'
require 'diffy'

require 'path_mapper/helper/debug'
require 'path_mapper/helper/logger'
require 'path_mapper/helper/storage'
require 'path_mapper/helpers'

require 'path_mapper/node/base/file'
require 'path_mapper/node/base/grep'
require 'path_mapper/node/base/representation'
require 'path_mapper/node/dir/inheritance/base'
require 'path_mapper/node/dir/inheritance/grep'
require 'path_mapper/node/dir/inheritance'
require 'path_mapper/node/dir/erb'
require 'path_mapper/node/dir/file'
require 'path_mapper/node/dir/grep'
require 'path_mapper/node/dir/representation'
require 'path_mapper/node/file/erb'
require 'path_mapper/node/file/file'
require 'path_mapper/node/file/representation'
require 'path_mapper/node/null/file'
require 'path_mapper/node/null/representation'
require 'path_mapper/node/base'
require 'path_mapper/node/dir'
require 'path_mapper/node/file'
require 'path_mapper/node/null'

require 'path_mapper/reloader'

module PathMapper
  extend Helpers

  def self.new(path, **kwargs)
    path = Pathname(path) unless path.is_a? Pathname

    if File.exists? path
      if File.directory? path
        self.with_dry_run {|dry_run| self.storage_tree(path) if !self.storage.key?(path) and dry_run }
        return DirNode.new(path, **kwargs)
      elsif !File.read(path).strip.empty?
        self.with_dry_run {|dry_run| self.storage_file_tree(path) if !self.storage.key?(path) and dry_run }
        return FileNode.new(path, **kwargs)
      end
    end

    self.with_dry_run do |dry_run|
      if self.storage.key? path and !self.deleted_files.include? path
        if self.storage[path].nil?
          return DirNode.new(path, **kwargs)
        elsif !self.storage[path].strip.empty?
          return FileNode.new(path, **kwargs)
        end
      end if dry_run
    end

    NullNode.new(path, **kwargs)
  end

  class DirNode
    include Node::Dir
    include Node::Dir::Erb
    include Reloader
  end

  class FileNode
    include Node::File
    include Node::File::Erb
    include Reloader
  end

  class NullNode
    include Node::Null
    include Reloader
  end
end