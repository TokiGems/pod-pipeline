require 'pod-pipeline/util/scanner'

module PPL
    class Command
        class Scan < Command
            class All < Scan
                self.summary = '输出 Pod 项目完整信息'
  
                self.description = <<-DESC
                    输出 Pod 项目完整信息。
                DESC
        
                self.arguments = [
                    CLAide::Argument.new('项目根目录（默认使用当前目录）', false),
                ]
                def self.options
                    [].concat(super)
                end
        
                def initialize(argv)
                    @path                   = argv.arguments!

                    @projectPath = @path.count.zero? ? Pathname.pwd.to_s : @path.first
                    
                    super
                end
        
                def run
                    PPL::Scanner.new(@projectPath, ["all"]).run
                    
                    puts "Pod: name = #{PPL::Scanner.name}, version = #{PPL::Scanner.version}" if PPL::Scanner.linter
                    puts "Git: remote = #{PPL::Scanner.git.remote}, branch = #{PPL::Scanner.git.branches.current.first}" if PPL::Scanner.git
                    puts "Workspace: #{PPL::Scanner.workspace.path}" if PPL::Scanner.workspace
                end
            end
        end
    end
end
  