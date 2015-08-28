require "FilePather/version"

class FPLocal

    def self.load_credentials
        false
    end

    def self.toStream source
        open(source[:path])
    end


    def self.copy_from_stream dest, stream
      open(dest[:path], 'w') do |f|
        stream do |chunk|
          f.write chunk
        end
      end
    end 

    def self.copy_to_self source, dest
        cp(source[:path],dest[:path])
    end

    def self.delete source
        rm(source[:path])
    end

end