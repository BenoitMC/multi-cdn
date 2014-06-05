require "net/http"
require "bundler"
Bundler.require

class << MultiCDN = Object.new
  CDNs = %w(
    http://cdnjs.cloudflare.com/ajax/libs/
    http://cdn.jsdelivr.net/
    http://fonts.googleapis.com/css?family=
    http://ajax.googleapis.com/ajax/libs/
    http://netdna.bootstrapcdn.com/
  )
  
  def call(env)
    clone.send(:call!, env)
  end
  
  private
  
  def call!(env)
    @request  = Rack::Request.new(env)
    @response = Rack::Response.new
    route!
    @response.finish
  end
  
  def route!
    CDNs.each do |cdn|
      file = @request.fullpath[1..-1]
      file = file.gsub("?", "&") if cdn.include?("?")
      res  = Net::HTTP.get_response URI(cdn + file)
      
      next unless res.code.to_i == 200
      next if res["Content-Type"].to_s.include?("html")
      
      @response["Content-Type"] = res["Content-Type"]
      @response.write res.body
      return
    end
    
    @response.status = 404
    @response["Content-Type"] = "text/plain"
    @response.write "Not Found"
  end
end