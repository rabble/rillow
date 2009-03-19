#!/usr/bin/ruby
require 'net/http'
require 'uri'
require 'rubygems'
require 'xmlsimple'
require 'cgi'
require File.dirname(__FILE__) + "/rillow_helper"

# This api is created by Leo Chan on 10/29/2007.
# There is no license requirement.  Use it or copy any part of the code that you want to use.
# Use it at your own risk.  I am not liable for anything.  Just want to share what I wrote.  Hopefully you will find it useful.
# Rillow is a simple ruby wrapper to zillow webservice api: http://www.zillow.com/howto/api/APIOverview.htm
# It does the web service call and gets the result back for you.  You don't have to know about the url request, url encoding or 
# parsing the result.  The result object is in hash/array format.  So no need to parsse xml.
# You will need to register with zillow to get the Zillow Web Service Identifier first.
# You will need to pass the Zillow Web Service Identifier to the constructor.
# This wrapper depends on xmlsimple. 
#
# Example:
# rillow = Rillow.new('your-zillow-service identifier')
# result = rillow.get_search_results('2114 Bigelow Ave','Seattle, WA')
# result.to_hash
# result.find_attribute 'valudationRange'
class Rillow
   attr_accessor :webservice_url, :zwsid
   
   VALID_METHODS => {
     :get_search_results => 'GetSearchResults',
     :get_zestimate => 'GetZestimate',
     :get_chart => 'GetChart',
     :get_region_chart => 'GetRegionChart',
     :get_demographics => 'GetDemographics',
     :get_region_children => 'GetRegionChildren',
     :get_comps => "GetDeepSearchResults",
     :get_deep_search_results => 'GetDeepSearchResults',
     :get_monthlypayments => 'GetMonthlyPayments',
     :get_deep_comps => 'GetDeepComps',
     :get_ratesummary => 'GetRateSummary',
     
   }
   
   
   # rillow = Rillow.new('your-zillow-service identifier')
   def initialize(my_zwsid, my_webservice_url= 'http://www.zillow.com/webservice/')
      zwsid = my_zwsid
      webservice_url = my_webservice_url
   end
   
   def method_missing(method, *args)
     super(method, args) unless VALID_METHODS.has_key? method
     fetch_from_zillow(VALID_METHODS[method], args)
   end
   
   #The get_search_results finds a property for a specified address. 
   #The content returned contains the address for the property or properties as well as the Zillow Property ID (ZPID) and current Zestimate. 
   #It also includes the date the Zestimate was computed, a valuation range and the Zestimate ranking for the property within its ZIP code. 
   #If no exact address match for a property is found, a list of closely matching properties is returned. 
   #See: http://www.zillow.com/howto/api/GetSearchResults.htm
   # parameter:
   # address  street address
   # citystatezip city&state or zip code
   #Example: 
   # rillow = Rillow.new('your-zillow-service identifier')
   # result = rillow.get_search_results(:address => '2114 Bigelow Ave', :citystatezip => 'Seattle, WA')
   # result.to_hash

   #For a specified Zillow property identifier (zpid), the get_zestimate returns:
   #1.  The most recent property Zestimate
   #2.  The date the Zestimate was computed
   #3.  The valuation range
   #4.  The Zestimate ranking within the property's ZIP code.
   #5.  The full property address and geographic location (latitude/longitude) and a set of identifiers that uniquely represent the region (ZIP code, city, county & state) in which the property exists.
   #The GetZestimate API will only surface properties for which a Zestimate exists. 
   #If a request is made for a property that has no Zestimate, an error code is returned. 
   #See: http://www.zillow.com/howto/api/GetZestimate.htm
   #parameter:
   # zpid zillow property id
   #Example: 
   # rillow = Rillow.new('your-zillow-service identifier')
   # result = rillow.get_zestimate(:zpid => '48749425')
   # result.to_hash


   #The get_chart api generates a URL for an image file that displays historical Zestimates for a specific property. 
   #The API accepts as input the Zillow Property ID as well as a chart type: either percentage or dollar value change. 
   #Optionally, the API accepts width and height parameters that constrain the size of the image. 
   #The historical data can be for the past 1 year, 5 years or 10 years.
   #See:  http://www.zillow.com/howto/api/GetChart.htm
   #parameters:
   #require: 
   # zpid: The Zillow Property ID for the property; the parameter type is an integer 
   # unit_type: A string value that specifies whether to show the percent change, parameter value of "percent," 
   # or dollar change, parameter value of "dollar"
   #options: 
   # :width =>  width of the generated graph. The value must be between 200 and 600, inclusive
   # :height=>  height of the generated graph. The value must be between 100 and 300, inclusive. 
   # :chart_duration => The duration of past data that needs to be shown in the chart. Valid values are "1year", 
   # "5years" and "10years". If unspecified, the value defaults to "1year"
   #Example: 
   # rillow = Rillow.new('your-zillow-service identifier')
   # result = rillow.get_chart(:zpid => '48749425',:unit_type => 'percent',:width=>300, :height=>150, :chart_duration=>'5years')
   # result.to_hash

   #The get_region_chart generates a URL for an image file that displays the historical Zestimates for a specific geographic region. 
   #The API accepts as input the name of the region as well as a chart type: either percentage or dollar value change. #
   #Optionally, the API accepts width and height parameters that constrain the size of the image. 
   #The historical data can be for the past 1 year, 5 years or 10 years.
   #see: http://www.zillow.com/howto/api/GetRegionChart.htm
   #parameters:
   #require: 
   # unit_type: A string value that specifies whether to show the percent change, parameter value of "percent," 
   # or dollar change, parameter value of "dollar"
   #options: 
   # :city=> name of the city
   # :state=> The two-letter abbreviation for a state
   # :zip=> The 5-digit ZIP code
   # :width=>  width of the generated graph. The value must be between 200 and 600, inclusive
   # :height=>  height of the generated graph. The value must be between 100 and 300, inclusive. 
   # :chart_duration => The duration of past data that needs to be shown in the chart. Valid values are "1year", 
   # "5years" and "10years". If unspecified, the value defaults to "1year"
   #Example: 
   # rillow = Rillow.new('your-zillow-service identifier')
   # result = rillow.get_region_chart(:unit_type =>'percent',:city=>'seattle',:state=>'WA',:width=>300, :height=>150, :chart_duration=>'5years')
   # result.to_hash

   #For a specified region, the GetDemographics API returns a set of demographic data which includes:
   # * A URL linking to the corresponding demographics page at Zillow.com
   # * Census Information (i.e. total population, median household income, recent homeowners, etc)
   # * Age Distributions
   # * Who Lives Here (if available for the region)
   # * What's Unique About the People (if available for the region)
   # A region can be specified either through its respective Region ID or by providing one to three parameters: 
   # state, city, neighborhood. The neighborhood parameter can be omitted if demographic data on a city is desired. 
   # The state and city parameter are always required.
   # see: http://www.zillow.com/howto/api/GetDemographics.htm
   # parameters:
   # :rid => region id
   # :city=> name of the city
   # :state=> The two-letter abbreviation for a state
   # :neighborhood=> The neighborhood of the region to retrieve data
   #Example: 
   # rillow = Rillow.new('your-zillow-service identifier')
   # result = rillow.get_demographics(:city=>'seattle',:state=>'WA',:neighborhood=>'Ballard')
   # result.to_hash

   # For a specified region, the get_region_children API returns a list of subregions with the following information:
   # * Subregion Type
   # * Region IDs
   # * Region Names
   # * Latitudes and Longitudes
   #A region can be specified at various levels of the region hierarchy. 
   #An optional childtype parameter can also be specified to return subregions of a specific type.
   #Allowable region types include: 
   #country, state, county, and city. Country and county are optional parameters unless they are the region to be specified.
   #Possible childtype parameters include: state, county, city, zipcode, and neighborhood. 
   #Any childtype parameter can be specified as long as the childtype parameter is a subregion type 
   #(i.e.. you cannot retrieve the subregion counties of a city). 
   #The only exception is that only subregion state can be specified for a country (otherwise it returns too many results).
   #
   #Childtype parameter is optional and defaults to types dependent on the specified region type: 
   #country defaults to return subregions of type state, state -> county, county -> city, city -> zipcode.
   #see: http://www.zillow.com/howto/api/GetRegionChildren.htm
   #parameters:
   # :city=> name of the city. The city of the region to retrieve subregions from.
   # :state=> The two-letter abbreviation for a state. The state of the region to retrieve subregions from.
   # :country=> The country of the region to retrieve subregions from.
   # :rid=> The regionId of the region to retrieve subregions from.
   # :childtype=> The type of subregions to retrieve (available types: state, county, city, zipcode, and neighborhood)
   # Example:
   # rillow = Rillow.new('your-zillow-service identifier')
   # result = rillow.get_region_children(:city=>'seattle',:state=>'WA',:country=>'united states',:childtype=>'neighborhood')
   # result.to_hash

   #The get_comps returns a list of comparable recent sales for a specified property. 
   #The result set returned contains the address, Zillow property identifier, and Zestimate for the comparable properties and 
   #the principal property for which the comparables are being retrieved.
   #see: http://www.zillow.com/howto/api/GetComps.htm
   #parameters:
   #zpid The Zillow Property ID for the property for which to obtain information; the parameter type is an integer
   #count The number of comparable recent sales to obtain
   # Examples:
   # rillow = Rillow.new('your-zillow-service identifier')
   # result = rillow.get_comps('48749425',5)
   # result.to_hash

   #The get_deep_search_results finds a property for a specified address 
   #(or, if no exact match for a property is found, a list of closely matching properties is returned). 
   #The result set returned contains the full address(s), zpid and Zestimate data that is provided by the get_search_results API. 
   #Moreover, this API call also gives rich property data like lot size, year built, bath/beds, last sale details etc.
   #see: http://www.zillow.com/howto/api/GetDeepSearchResults.htm
   # parameter:
   # address  street address
   # citystatezip city&state or zip code
   #Example: 
   # rillow = Rillow.new('your-zillow-service identifier')
   # result = rillow.get_deep_search_results('2114 Bigelow Ave','Seattle, WA')
   # result.to_hash

   #The get_deep_comps api returns a list of comparable recent sales for a specified property. 
   #The result set returned contains the address, Zillow property identifier, 
   #and Zestimate for the comparable properties and the principal property for which the comparables are being retrieved. 
   #This API call also returns rich property data for the comparables.
   #see: http://www.zillow.com/howto/api/GetDeepComps.htm
   #parameters:
   #zpid The Zillow Property ID for the property for which to obtain information; the parameter type is an integer
   #count The number of comparable recent sales to obtain
   # Examples:
   # rillow = Rillow.new('your-zillow-service identifier')
   # result = rillow.get_deep_comps('48749425',5)
   # result.to_hash

   # Get monthly mortgage payments.
   # price is required.
   # optional parameters:
   # :down => down payment, as an integer, representing the percent.  If ommitted, 20% is assumed.
   # :dollarsdown => down payment in dollars
   # :zip => location of property, used to calculate tax and insurance estimate, if known.
   # see: http://www.zillow.com/howto/api/GetMonthlyPayments.htm
   # Example: 
   # rillow = Rillow.new('your-zillow-service identifier')
   # result = rillow.get_monthlypayments(350000, {:down => 15, :zip => '33432'})
   # result.to_hash

   # Get current mortgage rates.
   # No params.
   # see: http://www.zillow.com/howto/api/GetRateSummary.htm
   # Example: 
   # rillow = Rillow.new('your-zillow-service identifier')
   # result = rillow.get_ratesummary
   # result.to_hash

  private
    def fetch_from_zillow(method,options) 
      options.merge!(:zws_id, zwsid)
      fetch_result join(webservice_url, method, '.htm?', to_aguments(options))
    end
    
    def to_arguments(options)
      options.map {|k,v| "#{clean_param_key(k)}=#{CGI.escape(v.to_s)}" }.join("&")
    end
    
    def clean_param_key(param_key)
      return 'chartDuration' if param_key == :chart_duration
      k.to_s.gsub('-','_')
    end
    
   def fetch_result(url_s)
      url = URI.parse(URI.escape(url_s))
      res = Net::HTTP.get_response(url)
      doc = XmlSimple.xml_in res.body
      class<<doc
       include RillowHelper
      end
      return doc
   end
end
