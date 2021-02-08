namespace :distribute_ticket do
  desc "全ユーザーのticket_countをrescueしながら10増加させる"
  # environmentメソッドは、「タスクの処理をアプリケーション環境に依存させた上で実行する」ということを可能にする
  # Rails環境に依存させる（読み込まれる）ことで、Rails上に設定したモデルなどの情報を取り扱うことができる（以下の場合、Userモデル）
  task rescue: :environment do
    User.find_each do |user|
      # beginは、例外となりそうな箇所を囲い処理を実行できる文法で、どんな条件でも最低1回は処理を実行するため、例外処理を始めるときなどに使用する
      begin
        # incrementメソッドは、カラム名と数字を引数に取り、引数の数だけカラムの値を増加させる
        # メソッド名に「!」をつけると、実行に失敗したときfalseを返すのではなく例外を発生させるようになる
        user.increment!(:ticket_count, 10)
      # rescueは、発生した例外を捕捉し、例外が起こった際に呼び出される条件節
    # rescue => eという記述は、発生した例外をrescue ~ end間の処理内でeという変数に入れて扱う、という意味
      rescue => e
        Rails.logger.debug e.message　# 発生した例外をログに記録
      end
    end
  end

  desc "全ユーザーの中にticket_countが10枚追加されると最大値より大きくなるレコードがある場合に例外を発生させる"
  task raise: :environment do
    User.find_each do |user|
      begin
        if user.ticket_count > 2147483647 - 10
          # raiseは、例外を発生させることができる文法で、第一引数に発生させたい例外クラス、第二引数にエラーメッセージを記述して使用する
          raise RangeError, "#{user.id}は、チケット取得可能枚数の上限を超えてしまいます！"
        end
      rescue => e
        Rails.logger.debug e.message
      end
    end
  end

  desc "全ユーザーのticket_countをトランザクションで10増加させる"
  # トランザクションは、レコードの更新を行う複数の処理を1つにまとめて行うことを指す
  # トランザクションを利用することにより、「処理の一部は成功し、一部は失敗した」という事象は発生せず、すべての処理の成功または失敗のみの状態を作ることができる
  task transact: :environment do
    ActiveRecord::Base.transaction do
      User.find_each do |user|
        user.increment!(:ticket_count, 10)
      end
    end
  end
end