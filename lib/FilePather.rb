require "FilePather/version"
require 'fog/aws'
require 'FilePather/FPLocal'
require 'FilePather/FPS3'

module FilePather
  require 'FilePather/railtie' if defined?(Rails)
  def self.parse_path path
    result = {}
    if path == ""
      raise "Empty Path"
    end
    path_chunks = path.split("://")
    if path_chunks.length > 1
        if path_chunks[0].downcase == "s3"
            s3_chunks = path_chunks[1].split("/")
            if s3_chunks.length < 2
                raise "Invalid S3 Path"
            end
            result[:type] = :S3
            result[:dir] = s3_chunks[0]
            result[:file] = s3_chunks[1..-1].join('/')
        elsif path_chunks[0].downcase == "http" or path_chunks[0].downcase == "https"
            result[:type] = :url
            result[:url] = path
        elsif path_chunks[0].downcase == "hdfs"
            puts('HDFS not yet supported')
            raise "Unsupported filesystem"
        elsif path_chunks[0].downcase == "gs"
            puts('GS not yet supported')
            raise "Unsupported filesystem"
        else
            raise "Unknown Path Prefix"
        end
    elsif path.length > path_chunks[0].length
      raise "Missing Path Body"
    else
      #assume local
      result[:type] = :local
      result[:path] = path
    end
    return result
  end

  def self.copy source, dest
    #parse the paths from parameters
    begin
     source_result = parse_path(source)
      dest_result   = parse_path(dest)
    rescue Exception => e
      #parsing failed
      puts e.message
      raise e
    end

    #get the class managing the filesystem type
    source_filesys = get_system(source_result[:type])
    dest_filesys = get_system(dest_result[:type])

    if source_filesys == false or dest_filesys == false
      raise "Unsupported Filesystem."
    end

    #load credentials
    source_filesys.load_credentials
    dest_filesys.load_credentials

    #call the appropriate method
    begin
      if source_result[:type] == dest_result[:type]
          source_filesys.copy_to_self(source_result, dest_result)
      elsif source_result[:type] == :local
          dest_filesys.copy_from_local(dest_result, source_result[:path])
      elsif dest_result[:type] == :local
          source_filesys.copy_to_local(source_result, dest_result[:path])
      else
          if source_filesys.method_defined? "copy_to"+dest_result[:type].to_s
              source_filesys.send("copy_to"+dest_result[:type].to_s, source_result, dest_result)
          elsif dest_filesys.method_defined? "copy_from"+source_result[:type].to_s
              dest_filesys.send("copy_from"+source_result[:type].to_s, dest_result, source_result)
          elsif source_filesys.method_defined? "toStream" and dest_filesys.method_defined? "copy_from_stream"
              stream = source_filesys.toStream(source_result)
              dest_filesys.copy_from_stream(dest_result, stream)
          else
              source_filesys.copy_to_local(source_result, 'tmp')
              dest_filesys.copy_from_local(dest_result, 'tmp/'+source_result[:file])
              #delete the tmp file
              rm('tmp/'+source_result[:file])
          end
      end
    rescue Exception => e
      #exception from the copy
      puts ("Copy failed...")
      puts (e.message)
      raise e
    end
    return true
  end

  def self.delete source
    #parse the path
    result = parse_path(source)
    filesys = get_system(result[:type])
    filesys.delete result
  end


  def self.move source, dest
    begin
      #copy the file, then delete the source file
      copy source, dest
      delete source
    rescue Exception => e
      puts e.message
      raise e
    end
  end

  def self.toStream source
    #parse the path
    result = parse_path(source)
    filesys = get_system(result[:type])
    if filesys.method_defined? "toStream"
      filesys.toStream result
    else
      puts "toStream not defined for #{result[:type]}"
      raise "toStream not implemented"
    end
  end


  def self.get_system type
    if type == :S3
      return FPS3
    elsif type == :hdfs
      return false
    elsif type == :gs
      return false
    elsif type == :local
      return FPLocal
    elsif type == :url
      return FPHttp
      return false
    end
  end

end
