require 'json'
require 'net/http'
require 'nokogiri'
require 'sinatra'


set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"

get '/' do
	erb :index, :locals => {:contents => ServiceManual.new("/service-manual").topic_names}
end

CONTENT_API_URL = "https://www.gov.uk/api/content"

class ContentItem
	def initialize(slug)
		@slug = slug
	end
	def access
		uri = URI(CONTENT_API_URL + @slug)
		json = Net::HTTP.get(uri)
		JSON.parse(json)
	end
end

class ServiceManual < ContentItem
	def topic_slugs
		access["links"]["children"].collect do |child|
			child["base_path"]
		end
	end
	def topic_names
		access["links"]["children"].collect do |child|
			child["title"]
		end
	end
end

class Topic < ContentItem
	def guide_slugs
		access["links"]["linked_items"].collect do |item|
			item["base_path"]
		end
	end
	def guide_names
		access["links"]["linked_items"].collect do |item|
			item["title"]
		end
	end
end

class Guide < ContentItem
	def content
		access["details"]["body"]
	end
end



#naming_your_service = Guide.new("/service-manual/design/naming-your-service")
#puts naming_your_service.content

#design = Topic.new("/service-manual/design")
#puts design.guide_names


#service_manual = ServiceManual.new("/service-manual")
#puts service_manual.topic_slugs
