require "FilePather/version"
require 'fog/aws'
require 'yaml'

class FPS3

    @@directory_error = "Directory does not exist."
    @@file_error = "Could not find file."

    def self.directory_error
      @@directory_error
    end

    def self.connection
      @@connection
    end

    def self.load_credentials creds = nil
        if creds
          #Settings = YAML::load(File.open(creds))
        end
        @@connection = Fog::Storage.new({
          :provider                 => 'AWS',
          :aws_access_key_id        => Settings[Rails.env][:aws][:aws_access_key_id],
          :aws_secret_access_key    => Settings[Rails.env][:aws][:aws_secret_key],
          :region                   => Settings[Rails.env][:aws][:region]
        })
    end

    def self.mock_connection
      Fog.mock!
      @@connection = Fog::Storage.new({
          :provider                 => 'AWS',
          :aws_access_key_id        => "",
          :aws_secret_access_key    => ""
        })
    end

    def self.toStream source
      begin
        dir = @@connection.directories.get(source[:dir])
        if dir
          expiry = Time.now + 1.hour
          open(dir.files.get_url(source[:file],expiry))
        else
          raise @@directory_error
        end
      rescue HTTPError
        raise @@file_error
      end
    end

    def self.copy_to_local source, dest
        s3dir = @@connection.directories.get(source[:dir])
        if s3dir
          if Pathname(dest).directory? == false
            Pathname(dest).mkpath
          end
          if s3dir.files.get(source[:file])
            open(dest+"/"+source[:file], 'w') do |f|
              s3dir.files.get(source[:file]) do |chunk,remaining_bytes,total_bytes|
                f.write chunk
              end
            end
          else
            raise @@file_error
          end
        else
          raise @@directory_error
        end
    end

    def self.copy_from_local dest, source
      begin
        s3dir = @@connection.directories.get(dest[:dir])
        if s3dir
          s3_file_object = s3dir.files.create(:key => dest[:file], 
              :body => File.open(source))
        else
          raise @@directory_error
        end
      rescue Errno::ENOENT
        raise @@file_error
      end
    end

    def self.copy_from_stream dest, stream
        s3dir = @@connection.directories.get(dest[:dir])
        if s3dir
          s3_file_object = s3dir.files.create(:key => dest[:file], 
              :body => stream)
        else
          raise @@directory_error
        end
    end

    def self.copy_to_self source, dest
        f = @@connection.directories.get(source[:dir]).files.get(source[:file])
        if f
          f.copy(dest[:dir], dest[:file])
        else
          raise @@file_error
        end
    end

    def self.delete source
        f = @@connection.directories.get(source[:dir]).files.get(source[:file])
        if f
        f.destroy
      else
        raise @@file_error
      end
    end

    def self.mkdir dir, public=true
      @@connection.directories.create(:key => dir, :public => public)
    end

end