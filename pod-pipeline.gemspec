# encoding: UTF-8
require 'cocoapods'

Gem::Specification.new do |s|
    s.name        = 'pod-pipeline'
    s.version     = '0.5.1'
    s.summary     = "Cocoapods流水线工具"
    s.description = "为组件化开发设计的集项目构建、发布为一体的强大工具"
    s.authors     = ["郑贤达"]
    s.email       = 'zhengxianda0512@gmail.com'
    s.files       = Dir["lib/**/*.rb"]
    s.homepage    = 'https://github.com/TokiGems/pod-pipeline'
    s.license     = 'MIT'

    s.executables = ["ppl"]

    s.add_runtime_dependency 'cocoapods-core',       "= #{Pod::VERSION}"     # CocoaPods核心代码，对应本地版本号
    s.add_runtime_dependency 'cocoapods-trunk',       '>= 1.4.0', '< 2.0'
    
    s.add_runtime_dependency 'git',                  '>= 1.8.1', '< 2.0'     # Git项目管理工具
    s.add_runtime_dependency 'xcodeproj',            '>= 1.19.0', '< 2.0'    # Cocoapods团队的xcode项目管理工具
    s.add_runtime_dependency 'claide',               '>= 1.0.2', '< 2.0'     # 命令行工具

    ## Make sure you can build the gem on older versions of RubyGems too:
    s.rubygems_version = "1.6.2"
    s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
    s.specification_version = 3 if s.respond_to? :specification_version
end