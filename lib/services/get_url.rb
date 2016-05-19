module Services
  require 'wombat'
  require 'yaml'
  # Public: Class is in charge of get all the zip urls
  ZIP_URL = YAML::load_file(File.join(File.dirname(__FILE__), "yaml/zip_url.yml"))
  
  class GetUrl
    # Internal
    # 
    # Examples
    #
    #   FileManagement.create_url
    #   # => New FileManagement instance
    #  Returns hash with the complete zip urls
    def self.zip_urls
      urls = []
      zip_ids = get_zip_ids['zip_ids']
      zip_ids.each do |zip_id|
        urls << ZIP_URL['zip_url'] + "#{zip_id}"
      end
      urls
    end

    # Internal
    # 
    #  Returns the zip_ids inside the url
    def self.get_zip_ids
      Wombat.crawl do
        base_url ZIP_URL['zip_url']
        path "/"

        zip_ids({ css: "td a" }, :list)
      end
    end

  end
end
