class LineBotController < ApplicationController
  require 'line/bot'
  require 'open-uri'
  require 'kconv'
  require 'uri'
  require 'json'
  require 'net/http'


  protect_from_forgery :except => [:callback]

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          input = event.message['text']
          case input
          when /.*(探す|さがす).*/
            push="まずは位置情報を送信してください\u{1F5FE}"
            message = {
            'type':'text',
            'text': push,
            'quickReply':{
              'items':[
                {
                  'type': 'action',
                  'action': {
                    'type': 'location',
                    'label': '位置情報を送信する'
                  }
                }
              ]
            }
          }
          # client.reply_message(event['replyToken'], message)
          when /.*(居酒屋|ダイニングバー・バル|創作料理|和食|洋食|イタリアン・フレンチ|中華|焼肉・ホルモン|韓国料理|アジア・エスニック料理|各国料理|カラオケ・パーティ|バー・カクテル|ラーメン|お好み焼き・もんじゃ|カフェ・スイーツ|その他グルメ).*/

            user=User.find_by(line_id: event['source']['userId'])
            category = event['message']['text']
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
            if user.categories.size >= 3
              push="カテゴリーは最大３つまでしか設定できません\u{10007C}"
            else
              unless user.categories.find_by(content: genre[category.to_sym])
                user.categories.build(content: genre[category.to_sym]).save!
                push="カテゴリーを追加しました"
              end
            end

            message = {
              type:'text',
              text: push,
              quickReply:{
                items:[
                  {
                    type: 'action',
                    action: {
                      type: 'message',
                      label: '確定する',
                      text:'確定する'
                    }
                  },
                  {
                    type: 'action',
                    action: {
                      type: 'message',
                      label: 'ジャンルを追加する',
                      text:'ジャンルを追加する'
                    }
                  }
                ]
              }
            }
            # client.reply_message(event['replyToken'], message)
          when /.*(ジャンルを追加する).*/
            push="追加するジャンルを選んでください\u{10008D}"
            message = {
              type:'text',
              text: push,
              quickReply:{
                items:[
                  {
                    type: 'action',
                    action: {
                      type: 'message',
                      label: '居酒屋',
                      text: '居酒屋'
                    }
                  },
                  {
                    type: 'action',
                    action: {
                      type: 'message',
                      label: 'ダイニングバー・バル',
                      text: 'ダイニングバー・バル'
                    }
                  },
                  {
                    type: 'action',
                    action: {
                      type: 'message',
                      label: '創作料理',
                      text: '創作料理'
                    }
                  },
                  {
                    type: 'action',
                    action: {
                      type: 'message',
                      label: '和食',
                      text: '和食'
                    }
                  },
                  {
                    type: 'action',
                    action: {
                      type: 'message',
                      label: '洋食',
                      text: '洋食'
                    }
                  },
                  {
                    type: 'action',
                    action: {
                      type: 'message',
                      label: 'イタリアン・フレンチ',
                      text: 'イタリアン・フレンチ'
                    }
                  },
                  {
                    type: 'action',
                    action: {
                      type: 'message',
                      label: '中華',
                      text: '中華'
                    }
                  },
                  {
                    type: 'action',
                    action: {
                      type: 'message',
                      label: '焼肉・ホルモン',
                      text: '焼肉・ホルモン'
                    }
                  },
                  {
                    type: 'action',
                    action: {
                      type: 'message',
                      label: '韓国料理',
                      text: '韓国料理'
                    }
                  },
                  {
                    type: 'action',
                    action: {
                      type: 'message',
                      label: 'アジア・エスニック料理',
                      text: 'アジア・エスニック料理'
                    }
                  },
                  {
                    type: 'action',
                    action: {
                      type: 'message',
                      label: 'ラーメン',
                      text: 'ラーメン'
                    }
                  },
                  {
                    type: 'action',
                    action: {
                      type: 'message',
                      label: 'お好み焼き・もんじゃ',
                      text: 'お好み焼き・もんじゃ'
                    }
                  },
                  {
                    type: 'action',
                    action: {
                      type: 'message',
                      label: 'カフェ・スイーツ',
                      text: 'カフェ・スイーツ'
                    }
                  }
                ]
              }
            }
            # client.reply_message(event['replyToken'], message)

          when /.*(確定する).*/
            user = User.find_by(line_id: event['source']['userId'])
            key=ENV['API_TOKEN']
            long = user.long
            lat = user.lat
            categories = Category.where(user_id: user.id).pluck(:content).join(',')
            url = "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=#{key}&format=json&lat=#{lat}&lng=#{long}&genre=#{categories}&range=4&order=4"
            uri=URI.parse(url)
            hash1 = Net::HTTP.get(uri)
            hash2=JSON.parse(hash1)
            json = hash2['results']['shop']
            shops=[]
            unless json.nil?
              json.each do |json|
                bubble={
                  type: "bubble",
                  size: "micro",
                  hero: {
                    type: "image",
                    url: json['photo']['mobile']['l'],
                    size: "full",
                    aspectMode: "cover",
                    aspectRatio: "320:213"
                  },
                  body: {
                    type: "box",
                    layout: "vertical",
                    contents: [
                      {
                        type: "text",
                        text: json['name'],
                        weight: "bold",
                        size: "sm",
                        color:"#0065f1",
                        decoration:'underline',
                        wrap: true,
                        action:{
                          type: "uri",
                          label: "URL",
                          uri: json['urls']['pc']
                        }
                      },
                      {
                        type: "box",
                        layout: "baseline",
                        contents: [
                          {
                            type: "text",
                            text: "最寄駅：#{json['station_name']}",
                            size: "xs",
                            color: "#000000",
                            margin: "md",
                            flex: 0,
                            weight:'bold'
                          }
                        ]
                      },
                      {
                        type: "box",
                        layout: "vertical",
                        contents: [
                          {
                            type: "box",
                            layout: "baseline",
                            spacing: "sm",
                            contents: [
                              {
                                type: "text",
                                text: "平均予算：\n#{json['budget']['average']}",
                                wrap: true,
                                color: "#000000",
                                size: "sm",
                                flex: 0
                              }
                            ]
                          }
                        ]
                      },
                      {
                        type: "box",
                        layout: "vertical",
                        contents: [
                          {
                            type: "box",
                            layout: "baseline",
                            spacing: "sm",
                            contents: [
                              {
                                type: "text",
                                text: "アクセス：\n#{json['access']}",
                                wrap: true,
                                color: "#000000",
                                size: "xs",
                                flex: 0
                              }
                            ]
                          }
                        ]
                      },
                      {
                        type: "box",
                        layout: "vertical",
                        contents: [
                          {
                            type: "box",
                            layout: "baseline",
                            spacing: "sm",
                            contents: [
                              {
                                type: "text",
                                text: "ジャンル：\n#{json['genre']['name']}, #{ json['sub_genre']['name'] unless json['sub_genre'].nil?}",
                                wrap: true,
                                color: "#918f8f",
                                size: "xs",
                                flex: 0
                              }
                            ]
                          }
                        ]
                      }
                    ],
                    spacing: "sm",
                    paddingAll: "10px"
                  }
                }
                shops.push(bubble)
              end

            end


            message={
              type:'flex',
              altText:'#',
              contents:{
                type: "carousel",
                contents: shops
              }
            }
          when /.*(こんにちは|こんにちわ).*/
            push="こんにちは\u{100039}、お店を探したいときは、まず「探す」と入力してみてください\u{100041}"
            message={
              type:'text',
              text:push
            }
          when /.*(こんばんは|こんばんわ).*/
            push="こんばんは\u{1000A8}\u{10002B}、お店を探したいときは、まず「探す」と入力してみてください\u{100041}"
            message={
              type:'text',
              text:push
            }
          when /.*(おはよう).*/
            push="おはようございます\u{1000A9}、お店を探したいときは、まず「探す」と入力してみてください\u{100041}"
            message={
              type:'text',
              text:push
            }
          else
            push="お店を探したいときは、まず「探す」と入力してみてください\u{100041}"
            message={
              type:'text',
              text:push
            }
          end
        client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Location
          push="次にジャンルを追加してください\u{1F35C}\u{1F363}\nジャンルは最大３つ登録できます\u{10008D}"
          user=User.find_by(line_id: event['source']['userId'])
          # line_id = event['source']['userId']
          # user=User.find_by(line_id: line_id)
          user.update_columns(long:event['message']['longitude'], lat:event['message']['latitude'])
          categories = user.categories
          categories.each do |category|
            category.destroy!
          end

          message = {
            type:'text',
            text: push,
            quickReply:{
              items:[
                {
                  type: 'action',
                  action: {
                    type: 'message',
                    label: '居酒屋',
                    text: '居酒屋'
                  }
                },
                {
                  type: 'action',
                  action: {
                    type: 'message',
                    label: 'ダイニングバー・バル',
                    text: 'ダイニングバー・バル'
                  }
                },
                {
                  type: 'action',
                  action: {
                    type: 'message',
                    label: '創作料理',
                    text: '創作料理'
                  }
                },
                {
                  type: 'action',
                  action: {
                    type: 'message',
                    label: '和食',
                    text: '和食'
                  }
                },
                {
                  type: 'action',
                  action: {
                    type: 'message',
                    label: '洋食',
                    text: '洋食'
                  }
                },
                {
                  type: 'action',
                  action: {
                    type: 'message',
                    label: 'イタリアン・フレンチ',
                    text: 'イタリアン・フレンチ'
                  }
                },
                {
                  type: 'action',
                  action: {
                    type: 'message',
                    label: '中華',
                    text: '中華'
                  }
                },
                {
                  type: 'action',
                  action: {
                    type: 'message',
                    label: '焼肉・ホルモン',
                    text: '焼肉・ホルモン'
                  }
                },
                {
                  type: 'action',
                  action: {
                    type: 'message',
                    label: '韓国料理',
                    text: '韓国料理'
                  }
                },
                {
                  type: 'action',
                  action: {
                    type: 'message',
                    label: 'アジア・エスニック料理',
                    text: 'アジア・エスニック料理'
                  }
                },
                {
                  type: 'action',
                  action: {
                    type: 'message',
                    label: 'ラーメン',
                    text: 'ラーメン'
                  }
                },
                {
                  type: 'action',
                  action: {
                    type: 'message',
                    label: 'お好み焼き・もんじゃ',
                    text: 'お好み焼き・もんじゃ'
                  }
                },
                {
                  type: 'action',
                  action: {
                    type: 'message',
                    label: 'カフェ・スイーツ',
                    text: 'カフェ・スイーツ'
                  }
                }
              ]
            }
          }

        end
        client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::Follow
        push="ご登録ありがとうございます\u{100079}\nこれは位置情報とジャンルからオススメのお店を紹介してくれるものです\u{1F37B}\u{1F363}\u{1F35D}\nお店を探したいときは、まず「探す」と入力してみてください\u{100041}"
        line_id = event['source']['userId']
        User.create(line_id: line_id)
        message={
          type: "text",
          text: push
        }
        client.push_message(line_id, message)
      when Line::Bot::Event::Unfollow
        line_id = event['source']['userId']
        User.find_by(line_id: line_id).destroy
      end
    end

    # Don't forget to return a successful response
    head :ok
  end

  private
    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end
end
