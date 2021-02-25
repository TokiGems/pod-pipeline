require 'pod-pipeline/util/scanner'

module PPL
    class Command
        class Scan < Command
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
                
                @projectPath = @path ? @path : Pathname.pwd

                super
            end

            def run
                PPL::Scanner.new(@channels, @projectPath).run
                
                puts "Pod: #{PPL::Scanner.podspec}" if PPL::Scanner.podspec
                puts "Git: remote = #{PPL::Scanner.git.remote}, branch = #{PPL::Scanner.git.branches.current.first}" if PPL::Scanner.git
                puts "Workspace: #{PPL::Scanner.workspace.path}" if PPL::Scanner.workspace
            end
        end
    end
end