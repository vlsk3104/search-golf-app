require 'google_maps_service'
require 'rakuten_web_service'

module Area
  # 楽天APIで定められているエリアコード（8:茨城県,11:埼玉県,12:千葉県,13:東京都,14:神奈川県）
  CODES = ['8','11','12','13','14']
end

module Departure
  #基準とする出発地点
  DEPARTURES = {
    1 => '東京駅',
    2 => '横浜駅',
  }
end

def duration_minutes(departure, destination)
  #Google Maps Platformを使って出発地点とゴルフ場の車での移動時間を出しています
  gmaps = GoogleMaps_Service::Client.new(key: ENV['GOOGLE_MAP_API_KEY'])
  routes = gmaps.directions(
    departure,
    destination,
    region: 'jp'
  )
  return unless routes.first #ルートが存在しない時はnillを返す（東京の離島など）
  duration_seconds = routes.first[:legs][0][:duration][:value] #レスポンスから所要時間（秒）を取得
  duration_seconds / 60 #単位が秒なので分に直す
end

def lambda_handler(event:, context:)
  RakutenWebService.configure do |c|
    c.application_id = ENV['RAKUTEN_APPID']
    c.affiliate_id = ENV['RAKUTEN_AFID']
  end

  Area::CODES.each do |code| # 全てのエリアに対して以下操作を行う
    1.upto(100) do |page|
      #コース一覧を取得する（楽天APIの仕様上、一度に全てのゴルフ場を取得できないのでpageを分けて取得している）
     courses = RakutenWebService::Gora::Course.search(areaCode: code, page: page)
      courses.each do |course|
        course_id = course['golfCourseId']
        course_name = course['golfCourseName']
        next if course_name.include?('レッスン')#ゴルフ場以外の情報（レッスン情報）をこれでスキップしてる
    durations = {}
    Departure::DEPARTURES.each do |duration_id, departure|
      minutes = duration_minutes(departure, course_name)
      durations.store(duration_id, minutes) if minutes
    end
    # TODO: 3. 取得した取得した情報をDynamoDBに保存する
      end
      break unless courses.next_page? #次のページが存在するかどうか確認するメソッド
   end
  end

  {statusCode: 200}
end
