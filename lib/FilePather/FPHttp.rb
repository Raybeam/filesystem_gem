class FPHttp

    def load_credentials
        
    end

    def self.toStream source
        open(source[:url])
    end

    def self.copy_to_local source, dest
          open(dest, 'wb') do |file|
          open(source[:url]) do |url|
            file.write(url)
          end
        end
    end

end