require 'cocoapods'
require 'cocoapods-core'

require 'pod/command/trunk'

require 'pod-pipeline/util/scanner'

require 'pod-pipeline/extension/version-ppl.rb'
require 'pod-pipeline/extension/linter-ppl'
require 'pod-pipeline/extension/validator-ppl'

module PPL
    class Command
        class Publish < Command
            self.summary = '项目发布'
            self.description = <<-DESC
                整合项目发布流程
            DESC
            self.arguments = [
                CLAide::Argument.new('项目根目录（默认使用当前目录）', false),
            ]
            def self.options
                [
                    ['--repo=master', 'Pod库所属的repo。（默认使用官方repo：master）'],
                ].concat(super).concat(options_extension)
            end

            def self.options_extension_hash
                Hash[
                    'update' => PPL::Command::Update.options,
                    'trunk-push' => Pod::Command::Trunk::Push.options,
                    'repo-push' => Pod::Command::Repo::Push.options
                ]
            end

            def initialize(argv)
                @path                   = argv.arguments!
                @repo                   = argv.option('repo', '').split(',').first
                
                @projectPath = @path.count.zero? ? Pathname.pwd.to_s : @path.first
                @is_master = false
                unless @repo
                    @repo = 'master'
                    @is_master = true
                end

                super
            end

            def run
                PPL::Command::Update.run([@projectPath] + argv_extension['update'])

                PPL::Scanner.new(@projectPath, ['all']).run
                
                podspec_file = PPL::Scanner.linter.file
                
                if @is_master
                    puts "[发布 #{podspec_file}]"
                    push_argv = [podspec_file] + argv_extension['trunk-push']
                    Pod::Command::Trunk::Push.run(push_argv)
                else
                    puts "[发布 #{@repo} #{podspec_file}]"
                    push_argv = [@repo, podspec_file] + argv_extension['repo-push']
                    Pod::Command::Repo::Push.run(push_argv)
                end
            end
        end
    end
end