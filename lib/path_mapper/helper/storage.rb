module PathMapper
  module Helper
    module Storage
      def storage
        Thread.current[:dry_storage] ||= {}
      end

      def deleted_files
        self.storage[:deleted_files] ||= []
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

      def storage_file_delete(pathname)
        self.deleted_files << pathname
        self.storage.delete(pathname)
      end

      def delete_storage_branch(pathname)
        self.storage_file_delete(pathname)
        self.storage.select {|k,v| k.to_s.start_with? pathname.to_s }.each {|k,v| self.storage_file_delete(k) }
      end
    end
  end
end