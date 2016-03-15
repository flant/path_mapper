require 'path_mapper/version'

require 'net_status'

require 'erb'
require 'ostruct'
require 'pathname'

require 'path_mapper/node/base/files_iterator'
require 'path_mapper/node/dir/inheritance'
require 'path_mapper/node/file/erb'
require 'path_mapper/node/base'
require 'path_mapper/node/dir'
require 'path_mapper/node/file'
require 'path_mapper/node/null'

require 'path_mapper/reloader'

module PathMapper
  def self.new(path)
    if File.exists? path
      if File.directory? path
        return DirNode.new(path)
      elsif !File.read(path).strip.empty?
        return FileNode.new(path)
      end
    end
    NullNode.new(path)
  end

  class DirNode
    include Node::Dir
    include Reloader
  end

  class FileNode
    include Node::File
    include Reloader
  end

  class NullNode
    include Node::Null
  end
end