# 3D Structure from Morion
structure from motion for docker
# 1．Dockerコンテナの作成
## 1. docker-compose.yml　に書いてある内容でdockerコンテナを作成
docker-compose.ymlのあるフォルダにて以下のコマンドを実行

'''
docker-compose up -d --build
'''

# 2. ライブラリの準備
## 1. 必要なライブラリをクローンし変更を加えビルドする
デフォルトでは /home/repos/install にDockerfileなどのフォルダが共有される
それ以外のフォルダがある場合は削除する
/home/repos 以下に
OpenMVG,OpenMVS,Eigen.Vcglib,Ceresをクローン
### OpenMVG
Structure from Motion を行うためのライブラリ
#### クローン

'''
git clone --recursive https://github.com/openMVG/openMVG.git
'''

#### ファイルの変更
dev_mvg/main_ComputeMatches.cpp 
dev_mvg/main_incrementalSfM.cpp に変更済みファイルあり
main_ComputeMatches:L503に以下を追加しmatches.f.txtが出力されるように変更

'''
if (!Save(map_GeometricMatches,
      std::string(sMatchesDirectory + "/" + "matches.f.txt")))
    {
      std::cerr
          << "Cannot save computed matches in: "
          << std::string(sMatchesDirectory + "/" + "matches.f.txt");
      return EXIT_FAILURE;
      }
'''

main_incrementalSfM.cpp:L263に以下を追加しsfm_result.jsonが出力されるように変更

'''
Save(sfmEngine.Get_SfM_Data(),
      stlplus::create_filespec(sOutDir, "sfm_result",".json"),
      ESfM_Data(ALL));
'''

### Eigen

'''
hg clone https://bitbucket.org/eigen/eigen#3.2
'''

### Vcglib

'''
git clone https://github.com/cdcseacave/VCG.git
'''

### Ceres

'''
git clone https://ceres-solver.googlesource.com/ceres-solver
'''

### OpenMVS
#### 繰り返しテクスチャを行う場合のクローン(デフォルト推奨)

'''
git clone https://github.com/thunders82/openMVS.git
'''

#### OpenMVS メインストリームのGitリポジトリ
https://github.com/cdcseacave/openMVS.git

# 3. 再構成用画像の準備

# 4. 再構成の実行
