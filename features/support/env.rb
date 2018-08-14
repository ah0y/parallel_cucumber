require 'rspec'
require 'page-object'
require 'data_magic'
require 'watir'
require 'cucumber'

World(PageObject::PageFactory)

capabilities = Selenium::WebDriver::Remote::Capabilities.new
capabilities.browser_name = :chrome

browser = Watir::Browser.new(
    :remote,
    :url => ENV['IP'], #allows you to pass in the grid IP on the command line, in case the hub url changes
    :desired_capabilities => capabilities
)

# browser = Watir::Browser.new(:chrome)


Before do
  @browser = browser
end



at_exit do
  browser.quit #at_exit hook is what actually frees up the selenium nodes, without this the nodes never get cleared
end




# To run with new grid IP, run bundle exec parallel_cucumber features/ -o IP=http://<ip>:4444/wd/hub (HTTP IS REQUIRED!!!!!!!!!!!!!!!!!!!!!!!!)
