# 次の仕様を満たす、SimpleModelモジュールを作成してください
#
# 1. include されたクラスがattr_accessorを使用すると、以下の追加動作を行う
#   1. 作成したアクセサのreaderメソッドは、通常通りの動作を行う
#   2. 作成したアクセサのwriterメソッドは、通常に加え以下の動作を行う
#     1. 何らかの方法で、writerメソッドを利用した値の書き込み履歴を記憶する
#     2. いずれかのwriterメソッド経由で更新をした履歴がある場合、 `true` を返すメソッド `changed?` を作成する
#     3. 個別のwriterメソッド経由で更新した履歴を取得できるメソッド、 `ATTR_changed?` を作成する
#       1. 例として、`attr_accessor :name, :desc`　とした時、このオブジェクトに対して `obj.name = 'hoge` という操作を行ったとする
#       2. `obj.name_changed?` は `true` を返すが、 `obj.desc_changed?` は `false` を返す
#       3. 参考として、この時 `obj.changed?` は `true` を返す
# 2. initializeメソッドはハッシュを受け取り、attr_accessorで作成したアトリビュートと同名のキーがあれば、自動でインスタンス変数に記録する
#   1. ただし、この動作をwriterメソッドの履歴に残してはいけない
# 3. 履歴がある場合、すべての操作履歴を放棄し、値も初期状態に戻す `restore!` メソッドを作成する
module SimpleModel
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def attr_accessor(*args)
      attr_reader *args

      args.each do |arg|
        instance_variable_set("@#{arg}_changed", false)

        define_method("#{arg}=") do |value|
          instance_variable_set("@#{arg}", value)
          instance_variable_set("@#{arg}_changed", true)
        end

        define_method("#{arg}_changed?") do
          instance_variable_get("@#{arg}_changed")
        end
      end

      define_method :changed? do
        args.map { |arg| instance_variable_get("@#{arg}_changed") }.any?
      end

      define_method :restore! do
        args.each do |arg|
          public_send("#{arg}=", @initial_hashes[arg.to_sym])
          instance_variable_set("@#{arg}_changed", false)
        end
      end
    end
  end

  def initialize(**hashes)
    @initial_hashes = hashes
    hashes.each do |key, value|
      if respond_to?(key)
        public_send("#{key}=", value)
        instance_variable_set("@#{key}_changed", false)
      end
    end
  end
end