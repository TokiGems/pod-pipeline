module Pod
    class Version
        def increase_major
            numeric_segments[0] = numeric_segments[0].to_i + 1
            archiving(numeric_joint(numeric_segments))
        end
    
        def increase_minor
            numeric_segments[1] = numeric_segments[1].to_i + 1
            archiving(numeric_joint(numeric_segments))
        end
    
        def increase_patch
            numeric_segments[2] = numeric_segments[2].to_i + 1
            archiving(numeric_joint(numeric_segments))
        end

        def numeric_joint(numeric_segments)
            archive = ""
            numeric_segments.each {|numeric|
                if numeric.nil?
                    numeric = 0
                end
                archive += '.' + numeric.to_s
            }
            archive.slice!(0)
            return archive
        end

        def archiving(new_version)
            puts "[修改版本号：#{version} => #{new_version}]"
            @version = new_version
        end
    end
end