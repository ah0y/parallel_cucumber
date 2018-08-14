
Given(/^I can go to "([^"]*)"$/) do |site|
  @browser.goto(site)
end