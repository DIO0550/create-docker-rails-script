# Input App Name
read -p "AppName: " APPNAME
echo $APPNAME

# create src folder
mkdir -p src

# create GemFile
echo "##############################"
echo "START Create GemFile"
echo "##############################"

echo 
echo 

echo "source 'https://rubygems.org'" >> "src/Gemfile"
echo "gem 'rails', '~>6'" >> "src/Gemfile"
touch src/Gemfile.lock

echo "##############################"
echo "END Create GemFile"
echo "##############################"

echo 
echo

# create DockerFile
echo "##############################"
echo "START Create DcokerFile"
echo "##############################"
DOCKERFILENAME="Dockerfile"

echo "# Railsコンテナ用Dockerfile" >> $DOCKERFILENAME
echo >> $DOCKERFILENAME
echo "# イメージのベースラインにRuby2.6.5を指定" >> $DOCKERFILENAME
echo "FROM ruby:2.6.5" >> $DOCKERFILENAME
echo >> $DOCKERFILENAME
echo "# Railsに必要なパッケージをインストール" >> $DOCKERFILENAME
echo "RUN apt-get update -qq && apt-get install -y build-essential libpq-dev" >> $DOCKERFILENAME
echo >> $DOCKERFILENAME
echo "# yarnパッケージ管理ツールをインストール" >> $DOCKERFILENAME
echo "RUN apt-get update && apt-get install -y curl apt-transport-https wget && \\" >> $DOCKERFILENAME
echo "curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \\" >> $DOCKERFILENAME
echo "deb https://dl.yarnpkg.com/debian/ stable main | tee -a /etc/apt/sources.list.d/yarn.list && \\" >> $DOCKERFILENAME
echo "apt-get update && apt-get install -y yarn" >> $DOCKERFILENAME
echo >> $DOCKERFILENAME
echo "# Node.jsをインストール" >> $DOCKERFILENAME
echo "RUN apt-get install -y nodejs npm && npm install n -g && n latest" >> $DOCKERFILENAME
echo >> $DOCKERFILENAME
echo "# ルートディレクトリを作成" >> $DOCKERFILENAME
echo "RUN mkdir /$APPNAME" >> $DOCKERFILENAME
echo >> $DOCKERFILENAME
echo "# 作業ディレクトリを指定" >> $DOCKERFILENAME
echo "WORKDIR /$APPNAME" >> $DOCKERFILENAME
echo >> $DOCKERFILENAME
echo "# ローカルのGemfileとGemfile.lockをコピー" >> $DOCKERFILENAME
echo "ADD ./src/Gemfile /$APPNAME/Gemfile" >> $DOCKERFILENAME
echo "ADD ./src/Gemfile.lock /$APPNAME/Gemfile.lock" >> $DOCKERFILENAME
echo >> $DOCKERFILENAME
echo "# ローカルのsrcをコピー" >> $DOCKERFILENAME
echo "ADD src/ /$APPNAME" >> $DOCKERFILENAME
echo >> $DOCKERFILENAME
echo "# Gemのインストール実行" >> $DOCKERFILENAME
echo "RUN bundle install" >> $DOCKERFILENAME
echo >> $DOCKERFILENAME
echo "# デバッグで使用するポートを公開する" >> $DOCKERFILENAME
echo "EXPOSE 3000 1234 26162" >> $DOCKERFILENAME

echo 
echo

# create DockerFile
echo "##############################"
echo "END Create DcokerFile"
echo "##############################"

echo 
echo

echo "##############################"
echo "START Create docker-compose.yml"
echo "##############################"

DEBUGCOMPOSEFILE="docker-compose-debug.yml"
COMPOSEFILE="docker-compose.yml"

echo "# docker-compose.ymlフォーマットのバージョン" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "version: '3'" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "services:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "  # Railsコンテナ定義" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "  web:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    # Dockerfileを使用してイメージをビルド" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    build: ." | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    # コンテナ起動時のコマンド" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    # ポート番号：3000" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE 
echo "    # バインドするIPアドレス：0.0.0.0" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    # ポート3000が来たらrailsサーバーが応答" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    command: [ \"bash\", \"-c\", \"rm -f tmp/pids/server.pid; RAILS_ENV=development bundle exec rdebug-ide --host 0.0.0.0 --port 1234 --dispatcher-port 26162 -- bin/rails s -b 0.0.0.0\" ]" >> $DEBUGCOMPOSEFILE
echo "    command: [ \"bash\", \"-c\", \"rm -f tmp/pids/server.pid; RAILS_ENV=development bundle exec rails s -p 3000 -b '0.0.0.0'\" ]" >> $COMPOSEFILE
echo "    environment:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "      WEBPACKER_DEV_SERVER_HOST: webpacker" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "      WEBPACKER_DEV_SERVER_PUBLIC: 0.0.0.0:3035" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    # ローカルのsrcをコンテナにマウント" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    volumes:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "      - ./src:/$APPNAME" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    # コンテナの外部に3000番を公開" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    # 公開するポート番号：コンテナ内部の転送先ポート番号" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    ports:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "      - 3000:3000" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "      - 1234:1234" >> $DEBUGCOMPOSEFILE
echo "      - 26162:26162" >> $DEBUGCOMPOSEFILE
echo "    # dbとwebpackerを先に起動" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    depends_on:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "      - db" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    # pryを使用してデバッグができるよう設定" >> $DEBUGCOMPOSEFILE
echo "    tty: true" >> $DEBUGCOMPOSEFILE
echo "    stdin_open: true" >> $DEBUGCOMPOSEFILE
echo "  # webpacker" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "  webpacker:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    build: ." | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    command: [ "bash", "-c", 'rm -rf /$APPNAME/public/packs; /$APPNAME/bin/webpack-dev-server']" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    environment:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "      - WEBPACKER_DEV_SERVER_HOST=0.0.0.0" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    volumes:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "     - ./src:/$APPNAME" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    ports:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "     - 3035:3035" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    networks:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "     - docker-network" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    restart: always" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    depends_on:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "         - web" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "  # MySQLコンテナ定義" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "  db:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    # mysql8.0でコンテナ作成" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    image: mysql:8.0" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    volumes:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "      # Mysql8.0のデフォルトの認証形式をmysql_native_passwordに設定" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "      - ./mysql-confd:/etc/mysql/conf.d" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "      # ローカルで保持しているDBをコンテナにマウント" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "      - db-volume:/var/lib/mysql" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    # コンテナ内の環境変数を定義" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "    environment:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "      # mysqlのルートユーザーのパスワード設定" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "      MYSQL_ROOT_PASSWORD: minesweeper" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "      MYSQL_DATABASE: minesweeper" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "      MYSQL_USER: minesweeper" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "      MYSQL_PASSWORD: minesweeper" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "# DBの内容をローカルに保持" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "volumes:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "  db-volume:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "networks:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE
echo "  docker-network:" | tee -a $DEBUGCOMPOSEFILE >> $COMPOSEFILE

echo 
echo

echo "##############################"
echo "END Create docker-compose.yml"
echo "##############################"

echo 
echo

echo "##############################"
echo "START Create Rails APP"
echo "##############################"


echo 
echo

docker-compose run --rm webpacker rails new $APPNAME --force --database=mysql --webpack=react

echo 
echo

echo "##############################"
echo "END Create Rails APP"
echo "##############################"

echo 
echo

echo "##############################"
echo "START Install Debug lib"
echo "##############################"

echo "gem 'ruby-debug-ide'" >> src/$APPNAME/Gemfile 
echo "gem 'debase'" >> src/$APPNAME/Gemfile

docker-compose run --rm webpacker bundle install


echo 
echo

echo "##############################"
echo "END Install Debug lib"
echo "##############################"

echo 
echo


echo "##############################"
echo "START Install npm lib"
echo "##############################"

docker-compose run --rm webpacker npm install --prefix ./$APPNAME --save ./$APPNAME  connected-react-router react-router-dom redux unstated

echo 
echo

echo "##############################"
echo "END Install npm lib"
echo "##############################"
