require 'xcodeproj'

module Xcodeproj
    class Workspace
        public

        def self.open(path)
            workspace = new_from_xcworkspace(path)
            workspace.setPath(path)
            workspace
        end

        def setPath(path)
            @path = path
        end

        def path
            @path
        end
    end
end