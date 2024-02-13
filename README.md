# DOP_C02
AWS Certified DevOps Engineer - Professional向けの実習です。

## 動作
- ローカルのDockerにて各種AWSリソースを作成します。
    - `./module`ディレクトリ内のリソースを作成します。
- CodeCommitへ本ソースをpushします。
- CodePipelineによりCodeBuildが起動します。
- Dockerイメージを作成しECRへpushします。
- ECSタスクでTerraformを実行できます。

# 前提条件
- Dockerfileをビルドできる環境
    - Docker Desktopなど

# 使い方
```
### ソースを取得します。
$ git clone https://github.com/yudozen/dop_c02_cicd.git
$ cd dop_c02_cicd

### 最小権限の原則にのっとったアクセスキーを`.env.secret`に指定します。
$ cp .env.secret.example .env.secret
$ vi .env.secret

### Dockerイメージ名やTerraformバージョンなど、必要に応じて編集します。
$ vi .env

### Dockerイメージを作成します。
$ make build

### ローカルDocker環境でTerraformを実行します。
$ make init
$ make plan
$ make apply

### CodeCommitにpushするとCodeBuildによりDockerイメージが作成されECRへpushされます。
### TerraformによりECSにTerraform Dockerイメージのタスク定義が作成されていますのでコマンドを設定しTerraformが実行できます。
```

# その他情報
- CodeCommitのgit認証情報を生成するためにIAMユーザーを作っています。