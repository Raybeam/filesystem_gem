require "FilePather/version"
require 'fog/aws'

module FilePather

  def self.parse_path path
    result = {}
    path_chunks = path.split("://")
    if path_chunks.length > 1
        if path_chunks[0].downcase == "s3"
            s3_chunks = path_chunks[1].split("/")
            if s3_chunks.length < 2
                puts('Invalid S3 path')
                return false
            end
            result[:type] = :s3
            result[:dir] = s3_chunks[0]
            result[:file] = s3_chunks[1..-1].join('/')

        elsif path_chunks[0].downcase == "http" or path_chunks[0].downcase == "https"
            result[:type] = :url
            result[:url] = path

        elsif path_chunks[0].downcase == "hdfs"
            puts('HDFS not yet supported')
            return false
        elsif path_chunks[0].downcase == "gs"
            puts('GS not yet supported')
            return false
        else
            puts('Unknown path prefix')
            return false
        end
    else
      #assume local
      result[:type] = :local
      result[:path] = path
    end
    return result
  end

  def self.copy source, dest
    puts(fpS3)
    #parse the paths from parameters
    source_result = parse_path(source)
    dest_result   = parse_path(dest)

    #check to make sure paths were parsed correctly
    if source_result == false or dest_result == false
      return false
    end

    #get the class managing the filesystem type
    source_filesys = get_system(source_result[:type])
    dest_filesys = get_system(source_result[:type])

    if source_filesys == false or dest_filesys == false
      return false
    end

    #load credentials
    source_filesys.load_credentials
    dest_filesys.load_credentials

    #call the appropriate method
    if source_result[:type] == dest_result[:type]
        source_filesys.copy_to_self(source_result[:dir], source_result[:file], 
            dest_result[:dir], dest_result[:file])
    elsif source_result[:type] == :local
        source_filesys.copy_from_local(dest_result[:dir], dest_result[:file], source_result[:path])

    elsif dest_result[:type] == :local
        source_filesys.copy_to_local(source_result[:dir], source_result[:file], dest_result[:path])
    else
        if source_filesys.method_defined? "copy_to"+dest_result[:type].to_s
            source_filesys.send("copy_to"+dest_result[:type].to_s, source_result[:dir], source_result[:file],
                dest_result[:dir], dest_result[:file])
        elsif dest_filesys.method_defined? "copy_from"+source_result[:type].to_s
            dest_filesys.send("copy_from"+source_result[:type].to_s, dest_result[:dir], dest_result[:file],
                source_result[:dir], source_result[:file])
        elsif source_filesys.method_defined? "toStream" and dest_filesys.method_defined? "copy_from_stream"
            stream = source_filesys.toStream(nil, source_result[:dir], source_result[:file])
            dest_filesys.copy_from_stream(dest_result[:dir], dest_result[:file], stream)
        else
            source_filesys.copy_to_local(source_result[:dir], source_result[:file], 'tmp')
            dest_filesys.copy_from_local(dest_result[:dir], dest_result[:file], 'tmp/'+source_result[:file])
            #delete the file
        end
    end
  end

  def self.get_system type
    if type == :S3
      return fpS3
    elsif type == :hdfs
      return false
    elsif type == :gs
      return false
    elsif type == :local
      return fpLocal
    else
      return false
    end
  end

end
