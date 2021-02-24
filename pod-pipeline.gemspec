Gem::Specification.new do |s|
    s.name        = 'pod-pipeline'
    s.version     = '0.0.2'
    s.summary     = "Cocoapods流水线工具"
    s.description = "为组件化开发设计的集项目构建、编译、发布为一体的强大工具"
    s.authors     = ["郑贤达"]
    s.email       = 'zhengxianda0512@gmail.com'
    s.files       = ["lib/pod-pipeline.rb", "lib/pod-pipeline/scan.rb"]
    s.homepage    = 'https://rubygems.org/gems/pod-pipeline'
    s.license     = 'MIT'

    s.executables << 'pod-pipeline'
end