require 'pod-pipeline/scan'

class PodPipeline
    def self.scan(media)
        scan = Scan.new
        case media
        when 'all'
            scan.all 
        when 'pod'
            scan.pod 
        when 'git'
            scan.git
        when 'workspace'
            scan.workspace
        else
            puts "未找到要扫描的内容"
        end
    end
end