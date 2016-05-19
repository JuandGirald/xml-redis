module Services
  require 'uri'
  require 'tempfile'
  require 'net/http'
  require 'zip'
  # Public: Class is in charge of managing all the files concerns
  #
  class FileManagement
    # Internal: Returns the URI with the link of the file to be downloaded
    attr_reader :uri
    private     :uri

    # Public: Initialize a FileManagement
    #
    # Examples
    #
    #   FileManagement.new(url)
    #   # => New FileManagement instance
    #
    # url - The url of the file to be downloaded
    def initialize(url)
      @uri = URI(url)
    end

    # Exception: This will raise when a given url is not valid
    #
    InvalidUrlException = Class.new(StandardError)

    # Exception: This will raise when a given file is not supported
    #
    UnsupportedFileException = Class.new(StandardError)

    # Public: Supported file extensions
    VALID_FILE_FORMAT = ['.zip']

    # Public: Supported Spreadsheet reader extensions
    VALID_READER_FORMAT = ['.xml']

    # Public: Process the given file
    #
    # Examples
    #
    #   process() # spreadsheet file
    #   # => valid spreadsheet file
    #
    #   process() # zip file
    #   # => unzipped file
    #
    #   process() # invalid file
    #   # => raise UnsupportedFileException
    #
    #   process() # invalid url
    #   # => raise InvalidUrlException
    def process
      verify_url!
      download_from_url do |downloaded_file|
        if valid_readers_format?
          downloaded_file
        else
          unzip(downloaded_file)
        end
      end
    end

    private

    # Internal: Verifies the url
    #
    # Examples
    #
    #   verify_url!() # invalid url
    #   # => raise InvalidUrlException
    #
    #   verify_url!() # invalid file
    #   # => raise UnsupportedFileException
    def verify_url!
      fail InvalidUrlException unless uri.to_s =~ URI::regexp
      fail UnsupportedFileException if !valid_readers_format? && !valid_file_format?
    end

    # Internal: Validates if is a xml format
    #
    # Examples
    #
    #   valid_readers_format?() # valid reader format
    #   # => true
    #
    #   valid_readers_format?() # invalid reader format
    #   # => false
    def valid_readers_format?
      VALID_READER_FORMAT.include? uri_extension
    end

    # Internal: Validates if is a zip format
    #
    # Examples
    #
    #   valid_file_format?() # valid unzip format
    #   # => true
    #
    #   valid_file_format?() # invalid unzip format
    #   # => false
    def valid_file_format?
      VALID_FILE_FORMAT. include? uri_extension
    end

    # Internal
    #
    # Examples
    #
    #   uri_extension() # .zip uri extension
    #   # => ".zip"
    #
    # Return the uri extension
    def uri_extension
      @uri_extension ||= File.extname(uri.path)
    end

    # Internal
    #
    # file - The file to manage
    #
    # Examples
    #
    #   unzip() # zip file
    #   # => unzipped TempFile
    #
    # Returns an unzipped file
    def unzip(file)
      temp_file = nil

      Zip::File.open(file.path) do |zip_files|
        zip_files.each do |zip_file|
          extension = File.extname(zip_file.name)
          temp_file = Tempfile.new(['unzipped_file', extension], encoding: 'ASCII-8BIT')
          temp_file.write(zip_file.get_input_stream.read)
        end
      end

      temp_file
    end

    # Internal: Downloads the file
    #
    # &block - block of the code that's going to use the TempFile
    #
    # Example
    #
    #   download_from_url(&block){ |downloaded_file| .... }
    #   # => TempFile
    #
    # Returns the downloaded TempFile
    def download_from_url
      temp_file = Tempfile.open('downloaded_file', encoding: 'ASCII-8BIT')

      Net::HTTP.start(uri.host, uri.port) do |http|

        request = Net::HTTP::Get.new uri

        http.request(request) do |response|
          temp_file.write(response.body)
        end

      end

      yield temp_file
    end
  end
end

a = Services::FileManagement.new('http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/1463378093216.zip').process
p a
