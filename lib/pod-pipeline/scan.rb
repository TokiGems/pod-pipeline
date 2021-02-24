class Scan
    def all
      return pod+git+workspace
    end
  
    def pod
      return "pod"
    end
    
    def git
      return "git"
    end

    def workspace
      return "workspace"
    end
end