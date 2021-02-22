require 'google_maps_service'
require 'rakuten_web_service'
require 'aws-record'

class SearchGolfApp
  include Aws::Record
  integer_attr :golf_course_id, hash_key: true
  integer_attr :duration1
  integer_attr :duration2
end

module Area
  CODES = ['8', '11', '12', '13', '14']
end

module Departure
  DEPARTURES = {
   1 => '東京駅',
   2 => '横浜駅',
  }
end

def duration_minutes(departure, destination)
  gmaps = GoogleMapsService::Client.new(key: ENV['GOOGLE_MAP_API_KEY'])
  routes = gmaps.directions(
    departure,
    destination,
    region: 'jp'
  )
  return unless routes.first
  duration_seconds = routes.first[:legs][0][:duration][:value]
  duration_seconds / 60
end

def put_item(course_id, durations)
  return if SearchGolfApp.find(golf_course_id: course_id)
  duration = SearchGolfApp.new
  duration.golf_course_id = course_id
  duration.duration1 = durations.fetch(1)
  duration.duration2 = durations.fetch(2)
  duration.save
end

def lambda_handler(event:, context:)
  RakutenWebService.configure do |c|
    c.application_id = ENV['RAKUTEN_APPID']
    c.affiliate_id = ENV['RAKUTEN_AFID']
  end

  Area::CODES.each do |code|
    1.upto(100) do |page|
     courses = RakutenWebService::Gora::Course.search(areaCode: code, page: page)
      courses.each do |course|
        course_id = course['golfCourseId']
        course_name = course['golfCourseName']
        next if course_name.include?('レッスン')
        durations = {}
        Departure::DEPARTURES.each do |duration_id, departure|
          minutes = duration_minutes(departure, course_name)
          durations.store(duration_id, minutes) if minutes
        end
        put_item(course_id, durations) unless durations.empty?
      end
      break unless courses.next_page?
    end
  end

  { statusCode: 200 }
end
