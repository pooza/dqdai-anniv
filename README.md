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

## 記念日カレンダー

- [スプレッドシート形式のカレンダー](https://docs.google.com/spreadsheets/d/1LCDOs0zZ25_gtVY-5q0YcaktimAlAeMSHIMIBMjhUrg)は廃止、[Google Calendar](https://calendar.google.com/calendar/u/0/embed?src=c_2bbfceeeda6d58706260a59070f52686db4713c044599fb001d82132c8119b2d@group.calendar.google.com&ctz=Asia/Tokyo)に移行しました。
