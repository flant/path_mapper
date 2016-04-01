module PathMapper
  module Helper
    module Storage
      def storage
        Thread.current[:dry_storage] ||= {}
      end

      def storage_tree(pathname)
        path = pathname
        while path.to_s != '/'
          self.storage[path] = nil
          path = path.parent
        end
      end

      def storage_file_tree(pathname)
        self.storage[pathname] = File.read(pathname)
        storage_tree(pathname.parent)
      end

      def delete_storage_branch(pathname)
        self.storage.delete(pathname)
        self.storage.select {|k,v| k.to_s.start_with? pathname.to_s }.each {|k,v| self.storage.delete(k) }
      end
    end
  end
end