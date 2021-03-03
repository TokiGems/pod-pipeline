require 'cocoapods'
require 'cocoapods-core'

require 'pod/command/trunk'

require 'pod-pipeline/util/scanner'

require 'pod-pipeline/extension/version-ppl.rb'
require 'pod-pipeline/extension/linter-ppl'
require 'pod-pipeline/extension/validator-ppl'

module PPL
    class Command
        class Update < Command
            self.summary = '项目扫描'
            self.description = <<-DESC
                更新项目内容
            DESC
            self.arguments = [
                CLAide::Argument.new('项目根目录（默认使用当前目录）', false),
            ]
            def self.options
                [
                    ['--channel=version,git,repo', '更新内容。（默认更新所有内容）'],
                    ['--repo=master', 'Pod库所属的repo。（默认使用官方repo：master）'],
                ].concat(super).concat(options_extension)
            end

            def self.options_extension_hash
                Hash[
                    'trunk-push' => Pod::Command::Trunk::Push.options,
                    'repo-push' => Pod::Command::Repo::Push.options
                ]
            end

            def initialize(argv)
                @path                   = argv.arguments!
                @channels               = argv.option('channel', '').split(',')
                @repo                   = argv.option('repo', '').split(',').first
                
                @projectPath = @path.count.zero? ? Pathname.pwd : @path.first
                @is_master = false
                unless @repo
                    @repo = 'master'
                    @is_master = true
                end

                super
            end

            def run
                PPL::Scanner.new(@projectPath, ['pod', 'git']).run

                @channels = ["all"] if @channels.count.zero?
            
                puts "\n[更新 #{@channels.join(", ")} 内容]"

                @channels.each do |channel|
                    case channel
                    when "all"
                        update_version
                        update_git
                        update_repo
                    when "version"
                        update_version
                    when "git"
                        update_git
                    when "repo"
                        update_repo
                    else
                        raise "暂不支持#{channel}内容扫描"
                    end
                end
            end

            def update_version
                version = PPL::Scanner.podspec.version
                raise "版本号异常，无法更新" unless version
                version.increase_patch

                PPL::Scanner.linter.write_to_file('version', version.version)
            end

            def update_git
                git = PPL::Scanner.git
                new_tag = PPL::Scanner.podspec.version.version
                git.tags.each do |tag|
                    raise "当前版本 #{new_tag} 已发布，请尝试其他版本号" if tag.name.eql? new_tag
                end
                git.commit_all(new_tag)
                git.add_tag(new_tag)
                git.push(git.remote, git.branches.current.first, true)
            end

            def update_repo
                podspec_file = PPL::Scanner.linter.file
                
                if @is_master
                    push_argv = [podspec_file] + argv_extension['trunk-push']
                    Pod::Command::Trunk::Push.run(push_argv)
                else
                    push_argv = [@repo, podspec_file] + argv_extension['repo-push']
                    Pod::Command::Repo::Push.run(push_argv)
                end
            end
        end
    end
end