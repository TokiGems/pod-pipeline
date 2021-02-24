require 'pod-pipeline/scan'

class PodPipeline
    #
    # Scan local files!
    #
    # == Example:
    #   >> PodPipeline.scan("all")
    #   => podgitworkspace
    # @param [String] media 选择扫描内容
    #
    # @return String 扫描结果
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