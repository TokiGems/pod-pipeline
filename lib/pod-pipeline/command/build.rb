require 'pod-pipeline/util/builder'

module PPL
    class Command
        class Build < Command
            self.summary = '项目构建'
            self.description = <<-DESC
                获取项目的关键参数
            DESC
            self.arguments = [
            ]
            def self.options
                [
                  ['--path=./**/*.podspec', '项目根目录。(默认使用当前目录)'],
                  ['--output=./', '项目构建的输出目录。(默认使用项目根目录)'],
                  ['--configuration=Release', '项目构建的环境。(默认为Release)'],
                  ['--arch=arm64,armv7,x86_64', '项目构建的架构。(默认为 arm64,armv7,x86_64)'],
                  ['--combine=local,pod', '项目构建后合并依赖库的二进制文件，local为本地依赖库，pod为CocoaPods依赖库。(默认为 local)'],
                ].concat(super)
            end

            def initialize(argv)
                @path               = argv.option('path', '').split(',').first
                @output             = argv.option('output', '').split(',').first
                @configuration      = argv.option('configuration', '').split(',').first
                @archs              = argv.option('arch', '').split(',')
                @combines           = argv.option('combine', '').split(',')
                
                @projectPath = @path ? @path : Pathname.pwd
                @output = @output ? @output : @projectPath

                super
            end

            def run
                PPL::Builder.new(@projectPath, @output, @configuration, @archs, @combines).run
            end
        end
    end
end