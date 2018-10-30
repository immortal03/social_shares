module SocialShares
  class Base
    include SocialShares::StringHelper
    DEFAULT_TIMEOUT = 3
    DEFAULT_OPEN_TIMEOUT = 3

    @@config = {}

    class << self
      def config=(val)
        @@config = val
      end
    end

    attr_accessor :checked_url, :proxy_url

    def initialize(checked_url, proxy_url = nil)
      # remove URI fragment
      @checked_url = checked_url.gsub(/#.+$/, '')
      @proxy_url = proxy_url
      puts @proxy_url
    end

    def shares
      shares!
    rescue => e
      puts "[#{self.class.name}] Error during requesting sharings of '#{checked_url}': #{e}"
      nil
    end

    def shares!
      raise NotImplementedError
    end

  protected

    def config_name
      to_underscore(self.class.name.split('::').last).to_sym
    end

    def timeout
      (@@config[config_name] || {})[:timeout] || DEFAULT_TIMEOUT
    end

    def open_timeout
      (@@config[config_name] || {})[:open_timeout] || DEFAULT_OPEN_TIMEOUT
    end

    def proxy
      (@@config[config_name] || {})[:proxy]
    end
    
    def get(url, params)
      retries = 5
      begin
        RestClient::Resource.new(url, timeout: timeout, open_timeout: open_timeout, proxy: proxy).get(params)
      rescue Exception 
        retries -= 1
        retry if retries > 0
      end
    end

    def post(url, params, headers = {})
      RestClient::Resource.new(url, timeout: timeout, open_timeout: open_timeout, proxy: proxy).post(params, headers)
    end
  end
end
