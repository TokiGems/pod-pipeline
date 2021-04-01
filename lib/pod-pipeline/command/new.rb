require 'cocoapods'

module PPL
    class Command
        class New < Command
            self.summary = '创建新项目'
            
            self.description = <<-DESC
                根据TokiHunter的最佳实践，为名为 'NAME' 的新Pod库的开发创建一个脚手架。
                如果未指定 '--lib-create-template-url'，默认使用 'https://github.com/TokiPods/pod-template.git'。
            DESC

            self.arguments = [
                CLAide::Argument.new('项目名字', true),
            ]
            
            def self.options
                [].concat(super).concat(options_extension)
            end

            def self.options_extension_hash
                Hash[
                    'lib-create' => Pod::Command::Lib::Create.options,
                ]
            end

            def initialize(argv)
                @name           = argv.shift_argument
                
                super
            end
    
            def run
                const_name = 'TEMPLATE_REPO'
                if Pod::Command::Lib::Create.const_defined?(const_name)
                    Pod::Command::Lib::Create.send(:remove_const, const_name)
                    Pod::Command::Lib::Create.const_set(const_name, 'https://github.com/TokiPods/pod-template.git'.freeze)
                end
                Pod::Command::Lib::Create.run([@name] + argv_extension['lib-create'])
            end
        end
    end
end