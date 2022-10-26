require 'pod-pipeline/util/scanner'

module PPL
  class Command
      class Scan < Command
          class Name < Scan
              self.summary = '输出 Pod 配置信息'

              self.description = <<-DESC
                  输出 Pod 配置信息。
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
                PPL::Scanner.new(@projectPath, ['name']).run
                  
                puts "#{PPL::Scanner.name}" if PPL::Scanner.name
              end
          end
      end
  end
end
