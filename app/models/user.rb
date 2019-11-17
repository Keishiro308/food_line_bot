class User < ApplicationRecord
  has_many :categories, dependent: :destroy

  def add_category(index)
    genre = {
      '居酒屋': 'G001',
      'ダイニングバー・バル': 'G002',
      '創作料理': 'G003',
      '和食': 'G004',
      '洋食': 'G005',
      'イタリアン・フレンチ': 'G006',
      '中華': 'G007',
      '焼肉・ホルモン': 'G008',
      'アジア・エスニック料理': 'G009',
      '各国料理': 'G010',
      'カラオケ・パーティ': 'G011',
      'バー・カクテル': 'G012',
      'ラーメン': 'G013',
      'カフェ・スイーツ': 'G014',
      'その他グルメ': 'G015',
      'お好み焼き・もんじゃ': 'G016',
      '韓国料理': 'G017'
    }
    unless self.categories.find_by(content: genre[index])
      categories.build(content: genre[index])
    end
  end
end
