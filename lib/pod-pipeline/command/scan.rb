require 'pod-pipeline/util/scanner'

module PPL
    class Command
        class Scan < Command
            self.summary = '项目扫描'
            self.description = <<-DESC
                获取项目的关键参数
            DESC
            self.arguments = [
                CLAide::Argument.new('项目根目录（默认使用当前目录）', false),
            ]
            def self.options
                [
                    ['--channel=pod,git,workspace', '扫描内容。（默认扫描所有内容）']
                ].concat(super)
            end

            def initialize(argv)
                @path                   = argv.arguments!
                @channels               = argv.option('channel', '').split(',')
                
                @projectPath = @path.count.zero? ? Pathname.pwd.to_s : @path.first

                super
            end

            def run
                PPL::Scanner.new(@projectPath, @channels).run
                
                puts "Pod: #{PPL::Scanner.podspec}" if PPL::Scanner.podspec
                puts "Git: remote = #{PPL::Scanner.git.remote}, branch = #{PPL::Scanner.git.branches.current.first}" if PPL::Scanner.git
                puts "Workspace: #{PPL::Scanner.workspace.path}" if PPL::Scanner.workspace
            end
        end
    end
end