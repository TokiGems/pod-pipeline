require 'minitest/autorun'
require 'pod-pipeline'

class PodPipelineTest < Minitest::Test
    def test_scan_pod
        assert_equal "pod", PodPipeline.scan("pod")
    end
  
    def test_scan_git
        assert_equal "git", PodPipeline.scan("git")
    end

    def test_scan_workspace
        assert_equal "workspace", PodPipeline.scan("workspace")
    end
end