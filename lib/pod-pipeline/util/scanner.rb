require 'cocoapods-core'
require 'git'
require 'xcodeproj'

require 'pod-pipeline/extension/git-ppl.rb'
require 'pod-pipeline/extension/workspace-ppl.rb'

module PPL
    class Scanner
        @@linter = nil
        @@podspec = nil
        @@git = nil
        @@workspace = nil

        def initialize(projectPath, channels)
            @projectPath = projectPath
            @channels = channels
        end

        def run
            @channels = ["all"] if @channels.count.zero?
            
            puts "\n[扫描 #{@channels.join(", ")} 内容]"

            @channels.each do |channel|
                case channel
                when "all"
                    @@linter = scan_pod @projectPath
                    @@podspec = @@linter.spec
                    @@git = scan_git @projectPath
                    @@workspace = scan_workspace @projectPath
                when "pod"
                    @@linter = scan_pod @projectPath
                    @@podspec = @@linter.spec
                when "git"
                    @@git = scan_git @projectPath
                when "workspace"
                    @@workspace = scan_workspace @projectPath
                else
                    raise "暂不支持#{channel}内容扫描"
                end
            end
        end

        #----------------------------------------#

        def self.linter
            @@linter
        end

        def self.podspec
            @@podspec
        end

        def self.git
            @@git
        end

        def self.workspace
            @@workspace
        end

        #----------------------------------------#

        private

        #
        # 检查项目的 podspec 文件
        #
        # @param [String] projectPath 项目根目录
        #
        # @return [Pod::Specification] 新 {Pod::Specification} 实例
        #
        def scan_pod(projectPath)
            podspec_files = Pathname.glob(projectPath + '/*.podspec{.json,}')
            if podspec_files.count.zero? || podspec_files.count > 1
                raise '未找到或存在多个 *.podspec 文件'
            end
            podspec_file = podspec_files.first
            linter = Pod::Specification::Linter.new(podspec_file)
            unless linter.spec
                raise 'podspec文件异常'
            end
            linter
        end

        #
        # 检查项目的 Git 库
        #
        # @param [String] projectPath 项目根目录
        #
        # @return [Git::Base] 新 {Git::Base} 实例
        #
        def scan_git(projectPath)
            Git.open(projectPath)
        end

        #
        # 检查项目的 workspace
        #
        # @param [String] projectPath 项目根目录
        #
        # @return [Xcodeproj::Workspace] 新的 {Xcodeproj::Workspace} 实例
        #
        def scan_workspace(projectPath)
            workspace_files = Dir[projectPath + '/Example/*.xcworkspace']
            if workspace_files.count.zero? || workspace_files.count > 1
                raise '未找到或存在多个 *.xcworkspace 文件'
            end
            workspace_file = workspace_files.first
            Xcodeproj::Workspace.open(workspace_file)
        end
    end
end