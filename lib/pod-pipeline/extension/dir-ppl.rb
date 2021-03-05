class Dir
    def self.reset(path)
        `rm -fr "#{path}"`
        `mkdir "#{path}"`
    end
end