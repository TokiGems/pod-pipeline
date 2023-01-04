module Pod
    class Version
        def increase(new_version = nil)
            unless new_version
                versions = @version.split('.')
                versions.push((versions.pop.to_i + 1).to_s)
                new_version = versions.join('.')
            end
            
            puts "[修改版本号：#{version} => #{new_version}]"
            @version = new_version
        end
    end
end