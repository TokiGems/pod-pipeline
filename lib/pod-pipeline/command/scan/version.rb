require 'pod-pipeline/util/scanner'

module PPL
  class Command
      class Scan < Command
          class Version < Scan
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
                  PPL::Scanner.new(@projectPath, ['version']).run
                  
                  puts "#{PPL::Scanner.version}" if PPL::Scanner.version
              end
          end
      end
  end
end
