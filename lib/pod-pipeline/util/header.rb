module PPL
  # PPL::Header
  class Header
    def self.combine_check(path, pattern_list = [])
      return false if pattern_list.empty?

      path_basename = File.basename(path)
      pattern_list.each do |pattern|
        pattern_basename = File.basename(pattern)

        return true if path_basename == "#{pattern_basename}.framework"
      end

      false
    end

    def self.combine_check_skip(path, queue, include_list = [], exclude_list = [])
      # 若 path 非目录 则跳过
      return true unless File.directory?(path)
      # 若 path 非被include标记的文件 则跳过
      return true unless combine_check(path, include_list)
      # 若 path 为被exclude标记的文件 则跳过
      return true if combine_check(path, exclude_list)
      # 若 path 为序列中已存在的文件 则跳过
      return true if queue.include? path

      false
    end

    def self.combine_collect(inputs, include_list = [], exclude_list = [])
      # 获取合并文件的路径序列
      input_queue = []
      inputs.each do |input|
        puts "\n合并路径：#{input}"

        Dir[input].each do |input_path|
          next if combine_check_skip(input_path, input_queue, include_list, exclude_list)

          # 合并
          puts "=> #{input_path}"
          input_queue << input_path
        end
      end

      input_queue
    end

    def self.combine_reset(header, include_list)
      content = File.read(header)
      replace = PPL::Scanner.name
      include_list.each do |include_name|
        content = content.gsub(include_name, replace)
      end
      File.write(header, content)
    end

    def self.combine(output, inputs, include_list = [], exclude_list = [])
      puts "\n目标文件：#{output}\n"

      combine_collect(inputs, include_list, exclude_list).each do |input|
        Dir["#{input}/Headers/*.h"].each do |header|
          FileUtils.cp(header, output, 'preserve': true)
        end
      end
      Dir["#{output}/*.h"].each do |header|
        combine_reset(header, include_list)
      end
    end
  end
end
