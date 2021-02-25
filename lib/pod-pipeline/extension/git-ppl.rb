require 'git'

module Git
    class Branches
        def current
            self.local.select { |b| b.current }
        end
    end
end