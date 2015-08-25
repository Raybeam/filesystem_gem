require "FilePather/version"
require 'fog/aws'

module fpS3
    def self.load_credentials
        @@connection = Fog::Storage.new({
          :provider                 => 'AWS',
          :aws_access_key_id        => Settings[Rails.env][:aws][:aws_access_key_id],
          :aws_secret_access_key    => Settings[Rails.env][:aws][:aws_secret_key],
          :region                   => Settings[Rails.env][:aws][:region]
        })
    end

    def self.toStream dir, file
        dir = @@connection.directories.get(d)
        expiry = Time.now + 1.hour
        open(dir.files.get_url(f,expiry))
    end

    def self.copy_to_local dir, file, dest
        
        s3dir = @@connection.directories.get(dir)
        open("dest"+"/"+file, 'w') do |f|
          s3dir.files.get(file) do |chunk,remaining_bytes,total_bytes|
            f.write chunk
          end
        end
    end

    def self.copy_from_local dir, file, source
        s3dir = @@connection.directories.get(dir)
        s3_file_object = s3dir.files.create(:key => file, 
            :body => File.open(source))
    end

    def self.copy_from_stream dir, file, stream
        s3dir = @@connection.directories.get(dir)
        s3_file_object = s3dir.files.create(:key => file, 
            :body => stream)

    def self.copy_to_self sourcedir, sourcefile, destdir, destfile
        f = @@connection.directoriges.get(sourcedir).files.get(sourcefile)
        f.copy(destdir, destfile)

    def self.delete dir, file
          f = @@connection.directories.get(dir).files.get(file)
          f.destroy
    end

end