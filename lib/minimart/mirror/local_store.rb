module Minimart
  class Mirror
    class LocalStore

      attr_reader :directory_path,
                  :cookbooks

      def initialize(directory_path)
        @directory_path = directory_path
        @cookbooks = {}
      end

      def add_cookbook_from_directory(path_to_cookbook)
        path_to_cookbook  = Utils::FileHelper.cookbook_path_in_directory(path_to_cookbook)
        cookbook          = Ridley::Chef::Cookbook.from_path(path_to_cookbook)

        add_cookbook_to_store(cookbook.metadata.name, cookbook.metadata.version)
        new_directory = File.join(directory, "/#{cookbook.name}")
        FileUtils.remove_dir(new_directory) if Dir.exists?(new_directory)
        FileUtils.cp_r(path_to_cookbook, new_directory)
      end

      def installed?(cookbook_name, cookbook_version)
        !!(cookbooks[cookbook_name] &&
          cookbooks[cookbook_name].include?(cookbook_version))
      end

      def add_cookbook_to_store(name, version)
        cookbooks[name] ||= []
        cookbooks[name] << version
      end

      private

      def directory
        # lazily create the directory to hold the store
        @directory ||= FileUtils.mkdir_p(directory_path).first
      end

    end
  end
end
