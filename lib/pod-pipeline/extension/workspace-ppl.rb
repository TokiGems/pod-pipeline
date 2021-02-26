require 'xcodeproj'

module Xcodeproj
    class Workspace
        attr_accessor :path

        def self.open(path)
            workspace = new_from_xcworkspace(path)
            workspace.path = path
            workspace
        end
    end
end