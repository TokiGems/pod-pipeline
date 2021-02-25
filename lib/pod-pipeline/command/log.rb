require 'cocoapods-core'

module PPL
    class Command
        class Log < Command
            self.summary = '日志输出'
            self.description = <<-DESC
                简单的日志输出
            DESC
            self.arguments = [
                CLAide::Argument.new('CONTENT', :false),
            ]
            def self.options
                [
                  ['--cite', '表示引用'],
                  ['--suffix=*', '后缀'],
                ]
            end

            def initialize(argv)
                @content          = argv.arguments!.first
                @cite             = argv.flag?('cite', '')
                @suffix           = argv.option('suffix', '').split(',').first
                
                super
            end

            def run
                puts "-----Yahaha-----"
                linter = Pod::Specification::Linter.new('/Users/toki/Workspace/JMProjects/JMBoomSDK/JMBoomSDK.podspec')
                log = @content + " " + @suffix + " " + linter.spec.name
                if @cite
                    puts "《" + log + "》"
                end
                puts "----------------"
            end
        end
    end
end