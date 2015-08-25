class fpLocal
    def load_credentials
        
    end

    def self.toStream dir, file
        open(dir+'/'+file)
    end


    def self.copy_from_stream dir, file, stream
      open("dest"+"/"+file, 'w') do |f|
        stream do |chunk|
          f.write chunk
        end
      end
    end 

    def self.copy_to_self sourcedir, sourcefile, destdir, destfile
        f = @@connection.directoriges.get(sourcedir).files.get(sourcefile)
        f.copy(destdir, destfile)

    def self.delete dir, file
          f = @@connection.directories.get(dir).files.get(file)
          f.destroy
    end

end