

module Area
  # 楽天APIで定められているエリアコード（8:茨城県,11:埼玉県,12:千葉県,13:東京都,14:神奈川県）
  CODES = ['8','11','12','13','14']
end

def lambda_handler(event:, context:)
  Area::CODES.each do |code| # 全てのエリアに対して以下操作を行う
    # TODO: 1. このエリアのゴルフ場を楽天APIで全て取得する
    # TODO: 2. 出発地点から取得したゴルフ場までの所要時間をGoogle Maps Platformで取得する
    # TODO: 3. 取得した取得した情報をDynamoDBに保存する
  end

  {statusCode: 200}
end
