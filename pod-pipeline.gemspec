Gem::Specification.new do |s|
    s.name        = 'pod-pipeline'
    s.version     = '0.0.3'
    s.summary     = "[暂时不可用]Cocoapods流水线工具"
    s.description = "[暂时不可用]为组件化开发设计的集项目构建、编译、发布为一体的强大工具"
    s.authors     = ["郑贤达"]
    s.email       = 'zhengxianda0512@gmail.com'
    s.files       = ["lib/pod-pipeline.rb", "lib/pod-pipeline/scan.rb"]
    s.homepage    = 'https://rubygems.org/gems/pod-pipeline'
    s.license     = 'MIT'

    s.executables << 'pod-pipeline'

    ## Make sure you can build the gem on older versions of RubyGems too:
    s.rubygems_version = "1.6.2"
    s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
    s.specification_version = 3 if s.respond_to? :specification_version
end