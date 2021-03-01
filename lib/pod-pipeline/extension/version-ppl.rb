module Pod
    class Version
        def increase_major
            numeric_segments[0] = numeric_segments[0].to_i + 1
            archiving(numeric_segments.join('.'))
        end
    
        def increase_minor
            numeric_segments[1] = numeric_segments[1].to_i + 1
            archiving(numeric_segments.join('.'))
        end
    
        def increase_patch
            numeric_segments[2] = numeric_segments[2].to_i + 1
            archiving(numeric_segments.join('.'))
        end

        def archiving(new_version)
            puts "[修改版本号：#{version} => #{new_version}]"
            @version = new_version
        end
    end
end