# dqdai-anniv

「ドラゴンクエストダイの大冒険」に関する、各種記念日をtomato-shriekerから扱えるようにするユーティリティ。
拙作[tomato-shrieker](https://github.com/pooza/tomato-shrieker)と併用して、ボットを作成できます。

## 設定例

```yaml
sources:
  - id: dai_anniv
    source:
      command:
        - bin/anniv.rb
      dir: /usr/home/pooza/repos/dqdai-anniv
    schedule:
      cron: '1 0 * * *'
    dest:
      account:
        bot: true
      hooks:
        - https://mstdn.example.com/mulukhiya/webhook/xxxxx
      tags:
        - delmulin
```

## 事前に告知する（iCalendar）

`--ics <カレンダー名>` を付けると、記念日を文章ではなく iCalendar（`.ics`）で標準出力へ出します。
tomato-shrieker の `IcalendarSource` に読ませると、当日だけでなく数日前から告知できます。

```sh
bin/anniv.rb --ics numbering_title   # ナンバリングタイトルの発売日
bin/anniv.rb --ics character         # 声優さんの誕生日・命日
```

- 予定は終日で、今年と来年のぶんを具体的な日付で出します（繰り返しは使いません。「34周年」のように文面が年で変わるため）
- `SUMMARY` に文面、`DESCRIPTION` にハッシュタグが入ります
- 該当が無いときは、空のカレンダーを出して正常終了します

```yaml
# config/sources/dai_numbering_title.yaml（tomato-shrieker 4.16.0 以降）
source:
  ical:
    command:
      - bin/anniv.rb
      - --ics
      - numbering_title
    dir: /usr/home/pooza/repos/dqdai-anniv
  days: 3   # 何日前から告知するか
dest:
  hooks:
    - https://mstdn.example.com/mulukhiya/webhook/xxxxx
```

カレンダー名は `config/application.yaml` の `/calendar` にあるものです。

## 記念日カレンダー

- [スプレッドシート形式のカレンダー](https://docs.google.com/spreadsheets/d/1LCDOs0zZ25_gtVY-5q0YcaktimAlAeMSHIMIBMjhUrg)は廃止、[Google Calendar](https://calendar.google.com/calendar/u/0/embed?src=c_2bbfceeeda6d58706260a59070f52686db4713c044599fb001d82132c8119b2d@group.calendar.google.com&ctz=Asia/Tokyo)に移行しました。
