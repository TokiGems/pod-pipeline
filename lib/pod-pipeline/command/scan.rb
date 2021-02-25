require 'cocoapods-core'
require 'git'
require 'xcodeproj'

require 'pod-pipeline/extension/git-ppl.rb'
require 'pod-pipeline/extension/workspace-ppl.rb'

module PPL
    class Command
        class Scan < Command
            @@podspec
            @@git
            @@workspace

            self.summary = '项目扫描'
            self.description = <<-DESC
                获取项目的关键参数
            DESC
            self.arguments = [
                CLAide::Argument.new('CHANNELS', false, true),
            ]
            def self.options
                [
                  ['--path=./**/*.podspec', '项目根目录。(默认使用当前目录)'],
                ].concat(super)
            end

            def initialize(argv)
                @channels           = argv.arguments!
                @path               = argv.option('path', '').split(',').first
                
                if @path
                    @localPath = @path
                else
                    @localPath = Pathname.pwd
                end

                super
            end

            def run
                @channels = ["all"] if @channels.count.zero?
                
                puts "扫描#{@channels.join(", ")}内容"

                @channels.each do |channel|
                    case channel
                    when "all"
                        @@podspec = scan_podspec @localPath
                        @@git = scan_git @localPath
                        @@workspace = scan_workspace @localPath
                    when "pod"
                        @@podspec = scan_podspec @localPath
                    when "git"
                        @@git = scan_git @localPath
                    when "workspace"
                        @@workspace = scan_workspace @localPath
                    else
                        raise "暂不支持#{channel}内容扫描"
                    end
                end
            end

            #----------------------------------------#

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
            # @param [String] localPath 项目根目录
            #
            # @return [Pod::Specification] 新 {Pod::Specification} 实例
            #
            def scan_podspec(localPath)
                podspec_files = Pathname.glob(localPath + '/*.podspec{.json,}')
                if podspec_files.count.zero? || podspec_files.count > 1
                    raise '未找到或存在多个 *.podspec 文件'
                end
                podspec_file = podspec_files.first
                linter = Pod::Specification::Linter.new(podspec_file)
                unless linter.spec
                    raise 'podspec文件异常'
                end
                linter.spec
            end

            #
            # 检查项目的 Git 库
            #
            # @param [String] localPath 项目根目录
            #
            # @return [Git] 新 {Git} 实例
            #
            def scan_git(localPath)
                Git.open(localPath)
            end

            #
            # 检查项目的 workspace
            #
            # @param [String] localPath 项目根目录
            #
            # @return [Xcodeproj::Workspace] 新的 {Xcodeproj::Workspace} 实例
            #
            def scan_workspace(localPath)
                workspace_files = Dir[localPath + '/Example/*.xcworkspace']
                if workspace_files.count.zero? || workspace_files.count > 1
                    raise '未找到或存在多个 *.xcworkspace 文件'
                end
                workspace_file = workspace_files.first
                Xcodeproj::Workspace.open(workspace_file)
            end
        end
    end
end