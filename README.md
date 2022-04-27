# dqdai-anniv
「ドラゴンクエストダイの大冒険」に関する、各種記念日をtomato-shriekerから扱えるようにするユーティリティ。
拙作[tomato-shrieker](https://github.com/pooza/tomato-shrieker)と併用して、ボットを作成できます。

以下、設定例。
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
        - ダイの大冒険
        - delmulin
```
