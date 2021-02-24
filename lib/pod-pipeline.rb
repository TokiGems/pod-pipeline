require 'pod-pipeline/scan'

class PodPipeline
    #
    # Scan local files!
    #
    # @param [String] media 选择扫描内容
    #
    # @return String 扫描结果
    #
    # @example
    #   >> PodPipeline.scan("all")
    #   => podgitworkspace
    #
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