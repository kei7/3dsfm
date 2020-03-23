# 3D Structure from Morion
structure from motion for docker
# 1．Dockerコンテナの作成
## 1.1. Dockerのイメージを最新版に

```
docker pull nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04
```

## 1.2. Dockerコンテナの作成
docker-compose.ymlの内容でコンテナ作成
docker-compose.ymlのあるフォルダにて以下のコマンドを実行

```
docker-compose build --no-cache
docker-compose up -d 
```

コンテナが作成されるので以下のコマンドでコンテナ内に入る

```
docker exec -it [コンテナ名] /bin/bash 
```

# 2. ライブラリの準備
##  必要なライブラリをクローンし変更を加えビルドする
デフォルトでは[クローンしたリポジトリ]/3dsfm:/home/repos/3dsfmとなるようにリポジトリのホームディレクトリと共有される  

```
cd /home/repos/3dsfm/dev_mvg/link.sh
/bin/bash link.sh
```

を実行すればファイル変更が加えられる  
以下、/home/repos をホームディレクトリとする  

### 2.1. OpenMVG
Structure from Motion を行うためのライブラリ  
#### ファイルの変更内容

/home/repos/3dsfm/dev_mvg/main_ComputeMatches.cpp  
/home/repos/3dsfm/dev_mvg/main_incrementalSfM.cpp に変更済みファイルあり  
main_ComputeMatches:L503に以下を追加しmatches.f.txtが出力されるように変更  

```
if (!Save(map_GeometricMatches,
      std::string(sMatchesDirectory + "/" + "matches.f.txt")))
    {
      std::cerr
          << "Cannot save computed matches in: "
          << std::string(sMatchesDirectory + "/" + "matches.f.txt");
      return EXIT_FAILURE;
      }
```

main_incrementalSfM.cpp:L263に以下を追加しsfm_result.jsonが出力されるように変更  

```
Save(sfmEngine.Get_SfM_Data(),
      stlplus::create_filespec(sOutDir, "sfm_result",".json"),
      ESfM_Data(ALL));
```

編集後のファイルは~/openMVG/src/software/SfM/にコピー  

#### ビルド

```
cd /home/repos/openMVG_build
cmake -DCMAKE_BUILD_TYPE=RELEASE . ../openMVG/src/
make -j2
```

### 2.2. Eigen
openMVSの依存ライブラリ

#### ビルド

```
cd /home/repos/eigen_build
cmake . ../eigen3.2
make -j2
make install
```

### 2.3. Vcglib
openMVSの依存ライブラリ

### 2.4. Ceres
openMVSの依存ライブラリ  
ceres-solverを以下のバージョンにチェックアウト  

```
cd /home/repos/ceres-solver
git checkout ba62397d80b2d7d34c3cca5e75f1f154ad8e41bb
```

#### ビルド

```
cd /home/repos/ceres_build
cmake . ../ceres-solver/ -DMINIGLOG=ON -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF
make -j2
make install
```

### 2.5. OpenMVS
#### 繰り返しテクスチャを行う場合のリポジトリ(デフォルト推奨)
以下のバージョンにチェックアウト

```
cd /home/repos/openMVS
git checkout 6bdc5ecbf45b540d408ded4592191dd30c3f69cf
```

#### OpenMVS メインストリームのGitリポジトリ
https://github.com/cdcseacave/openMVS.git
#### ファイル変更内容
SceneTexture.cpp:L576を編集。textureに使う画像サイズに制限をかける(textureに使用したい画像に応じて数字は編集)  

```
Image& imageData = images[idxView];
		if (imageData.height != 512 || imageData.height != 1024)
			continue;
		if (!imageData.IsValid()) {
			++progress;
			continue;
		}
	// load image
```

編集後、~/openMVS/libs/MVS/にコピー

#### ビルド

```
cd /home/repos/openMVS_build
cmake . ../openMVS -DCMAKE_BUILD_TYPE=RELEASE -DVCG_ROOT="/home/repos/vcglib" -DBUILD_SHARED_LIBS=OFF -DOpenMVS_USE_CUDA=OFF -DOpenMVS_USE_BREAKPAD=OFF
make -j2
make install
```

## 2.6. Meshlab 
ローカルのPCにて
http://www.meshlab.net/  
からインストールファイルをインストールし実行  

# 3. 再構成用画像の準備
## 3.1. 画像のコピー
読み込む画像はjpg画像に直して~/openMVG_build/software/SfM/input/[フォルダ名]/images/[画像名].jpg  
となるようにしてコピーする必要がある  
/home/repos/3dsfm/executeにある  
setup.txtを編集する  

```
vi /home/repos/3dsfm/execute/setup.txt  
```

```
INPUT=[画像フォルダへの絶対パス] 
```
 
```
cp copy.sh
```

~/openMVG_build/software/SfM/input/[フォルダ名]/images/[画像名].jpg
となるようにしてコピーする 必要がある

## 3.2. カメラ素子サイズについて
以下のことに留意する

```
vi /home/repos/3dsfm/execute/sensor_width_camera_database.txt  
```

とすると以下のようになっている  

```
Camera-A;6.167 #例1
Camera-B:6.166 #例2
[形状推定カメラの機種名];[素子サイズ(mm)]
[高速度カメラの機種名1];[素子サイズ(mm)]
[高速度カメラの機種名2];[素子サイズ(mm)]
[高速度カメラの機種名3];[素子サイズ(mm)]
```

この時、使用するカメラ機種名や素子サイズが同じ場合でも、Camera-A;6.167,Camera-B;6.166のようにする  
異なる機種名、素子サイズにしなければ複数のカメラが同じ内部パラメータを持つように設定されてしまうので注意する。  

## 3.3. exifデータの編集


```
vi /home/repos/3dsfm/execute/chexif.py  
```

とし必要に応じてL21以降を書き換える。  
chexif.pyは画像のexifデータ(メタデータ)を書き換える

```
data["Exif.Image.Model"] = "SO-01K" #撮影カメラ機種名。sensor_width_camera_database.txtに追加したカメラ機種名と一致させる
data["Exif.Photo.FocalLength"] = meta1["Exif.Photo.FocalLength"].value #焦点距離、仮の数字なので別ファイルからコピーするだけ
data["Exif.Photo.PixelXDimension"] = 1920 #画像の横サイズ
data["Exif.Photo.PixelYDimension"] = 1080 #画像の縦サイズ
```

このとき、

## 3.4. カメラ内部パラメータの計算
/home/repos/3dsfm/execute/calibrate.py  
を実行して形状推定カメラ1台と高速度カメラ3台それぞれについて内部パラメータを計算する。  
必要に応じてL8,9のキャリブレーションパターンを変更する。  

```
cd /home/repos/3dsfm/execute
python calibrate.py [キャリブレーション画像フォルダへのパス]
```

するとキャリブレーション結果が例として以下のように得られる  

```
loading...E:\AnalysisResult\20200106\20191227-1A\cam_calib\000239.png
loading...E:\AnalysisResult\20200106\20191227-1A\cam_calib\000270.png
loading...E:\AnalysisResult\20200106\20191227-1A\cam_calib\000290.png
loading...E:\AnalysisResult\20200106\20191227-1A\cam_calib\000342.png
loading...E:\AnalysisResult\20200106\20191227-1A\cam_calib\000400.png
loading...E:\AnalysisResult\20200106\20191227-1A\cam_calib\000405.png
loading...E:\AnalysisResult\20200106\20191227-1A\cam_calib\000510.png
loading...E:\AnalysisResult\20200106\20191227-1A\cam_calib\000922.png
loading...E:\AnalysisResult\20200106\20191227-1A\cam_calib\000979.png
loading...E:\AnalysisResult\20200106\20191227-1A\cam_calib\001255.png
loading...E:\AnalysisResult\20200106\20191227-1A\cam_calib\001615.png
loading...E:\AnalysisResult\20200106\20191227-1A\cam_calib\001811.png
loading...E:\AnalysisResult\20200106\20191227-1A\cam_calib\001964.png
RMS =  0.3187571412368937
K = 
 [[3.14379080e+03 0.00000000e+00 9.82947035e+01]
 [0.00000000e+00 3.10045283e+03 2.03119761e+02]
 [0.00000000e+00 0.00000000e+00 1.00000000e+00]]
d =  [ 9.89016633e-01 -6.64973985e+01 -3.98764708e-03 -7.26857600e-02
  1.24415171e+03]
```

このキャリブレーション結果のKとdが再構成に必要となるのでエディタなどにコピーする  
ここで、形状推定カメラの結果、高速度カメラ3台(A,B,C)の結果について内部パラメータを通し番号で「0,1,2,3」とする

# 4. 再構成の実行
## 4.0. 設定ファイルの編集
/home/repos/3dsfm/executeにある
setup.txtを編集する  

```
vi /home/repos/3dsfm/execute/setup.txt
```

```
MVGBUILDMAIN="/home/repos/openMVG_build"
MVSBUILDMAIN="/home/repos/openMVS_build/bin"
MVGEXEC="software/SfM"
MVGRELEASE="Linux-x86_64-RELEASE"
上4行は使用するライブラリのフォルダに合わせて固定
IMGDIRNAME="20191203-1_3" 
再構成用画像のあるフォルダ名を入力 
```

## 4.1. 画像読み込み
executeフォルダに移動し以下のように実行  

```
/bin/bash imagelisting.sh
```

すると  
chexif.py、model1.py.in  
が実行され  
~/openMVG_build/software/SfM/input/[フォルダ名]/images/[画像名].jpg  
を読み込み  
~/openMVG_build/software/SfM/input/[フォルダ名]/out/matches/sfm_data.json  
というファイルが生成される。  

## 4.2. 特徴量計算 
~/openMVG_build/software/SfM/input/[フォルダ名]/out/matches/sfm_data.json  
は以下のようになっている  

```
cd  /home/repos/3dsfm/execute
vi sfm_data.json
```


```
{
    "sfm_data_version": "0.3",
    "root_path": "/home/repos/openMVG_build/software/SfM/input/20191203-1_3/images",
    "views": [
        {
            "key": 0,
            "value": {
                "polymorphic_id": 1073741824,
                "ptr_wrapper": {
                    "id": 2147483649,
                    "data": {
                        "local_path": "",
                        "filename": "H00020.jpg",
                        "width": 1920,
                        "height": 1080,
                        "id_view": 0,
                        "id_intrinsic": 1,
                        "id_pose": 0
                    }
                }
            }
        },
        ...
        ],
    "intrinsics": [
        {
            "key": 0,
            "value": {
                "polymorphic_id": 2147483649,
                "polymorphic_name": "pinhole_radial_k3",
                "ptr_wrapper": {
                    "id": 2147484126,
                    "data": {
                        "width": 512,
                        "height": 512,
                        "focal_length": 2800.00000476837159,
                        "principal_point": [
                            256.0,
                            256.0
                        ],
                        "disto_k3": [
                            0.0,
                            0.0,
                            0.0
                        ]
                    }
                }
            }
        },
        ...
        ],
    "extrinsics": [],
    "structure": [],
    "control_points": []
}
```

"views"は入力画像について  
"intrinsics"は画像撮影に用いたカメラの内部パラメータについてを示している  

ここで、"intrinsics"4つの通し番号を0',1',2',3'とする  
この章では、3.4.で計算した内部パラメータ0,1,2,3と"intrinsics"の内部パラメータ0',1',2',3'の対応関係を求めたい

例えば上の内容を例にすると  
"views"の各画像について"value"の"filename":"H00020.jpg"よりカメラ画像を撮影した機種がわかる(法則を決めておく)
この場合"filename":"H00020.jpg"に対応するのは形状推定カメラである
よって内部パラメータ0に対応している  
"views"の各画像について"value"の"id_intrinsic":1　より、sfm_data.jsonの"intrinsics"の内部パラメータ1'と対応していることがわかる
よって[内部パラメータ0]=[内部パラメータ1']

そこで3.4.で計算した内部パラメータKとdから各画像に対応する内部パラメータを入力する。  
内部パラメータ0のKとdを用いて

"intrinsics"の"key"=1のについて
Kの(1,1)成分と(2,2)成分からからfocallengthを計算し入力  
"focal_length" = {[(1,1)成分]+[(2,2)成分]}/0.5  

dの第1第2成分をdisto_k3の第1第2成分に入力する   
"disto_k3"=[[dの第1成分], [dの第2成分], 0.0, 0.0, 0.0]  

その後以下のように入力し実行  

```
cp ./sfm_data.json /home/repos/openMVG_build/software/SfM/input/[フォルダ名]/out/matches/
/bin/bash featurematch.sh
```

これによりsfm_data.jsonを読み込んでmodel2.py.inが実行され  
実行結果が  
~/openMVG_build/software/SfM/input/[フォルダ名]/out/matches/に出力され  
sfm_data.binとして出力されるほか  
特徴量とマッチング結果が出力される  
特徴量は  
[画像名].featの形で出力され  

```
[特徴点1のx座標] [特徴点1のy座標] [特徴点1のパラメータ1] [特徴点1のパラメータ2]
[特徴点2のx座標] [特徴点2のy座標] [特徴点2のパラメータ1] [特徴点2のパラメータ2]
...
```

のような構造になっている  
マッチング結果は  
matches.f.txtで出力され  

```
[画像1の通し番号] [画像2の通し番号]
[マッチングした特徴点の組数]
[画像1の特徴点の通し番号1] [画像2の特徴点の通し番号1]
[画像1の特徴点の通し番号2] [画像2の特徴点の通し番号2]
...
```

のような構造になっている  
手動でマッチング結果を追加する場合はmatches.f.txtに特徴点マッチングを追加して続きを実行すればよい  

## 4.2. Structure from Motionによる位置姿勢推定
以下のように実行  

```
/bin/bash incrementSfM.sh
```

matches.f.txtまたはsfm_data.binを読み込みmodel3.py.inを実行  

これにより、~/openMVG_build/software/SfM/input/[フォルダ名]/out/reconstruction_sequential以下に  
scene.mvs、scene.ply、cloud_and_poses.ply、htmlファイルなどが出力される。  
cloud_and_poses.plyをmeshlabで確認すると、カメラ位置が緑の点で、マッチングした特徴点が灰色で示される。  
htmlファイルにはStructure from Motionの結果が記述されており、位置姿勢推定ができたカメラ画像については誤差が表示される。  

## 4.3. メッシュの再構成
以下のように実行  

```
/bin/bash reconstruct.sh
```

これにより、openMVSによるメッシュ再構成が行われ  
~/openMVG_build/software/SfM/input/[フォルダ名]/out/reconstruction_sequential以下に  
scene_dense_mesh.plyとしてメッシュファイルが出力される。  

scene_dense_mesh.plyをmeshlabで確認すると正しく推定できていれば心臓メッシュ形状が再構成される  

## 4.4. テクスチャの貼り付け
meshlabで形状を確認し、心臓につながっていないメッシュとそれを構成する点群をすべて削除する  
削除後以下のように実行  

```
/bin/bash texture.sh
```

texture.shで実行しているTextureMeshの実行時に

```
TextureMesh scene_dense.mvs --mesh-file [メッシュ名.ply]　
```

とすることで  
指定したファイルのメッシュのみにテクスチャを貼り付けることができる。  
これにより  
scene_dense_mesh_texture.plyとscene_dense_mesh_texture.png  
が出力される。両方のファイルを同一フォルダに置いた状態でmeshlabでplyファイルを開くとテクスチャが貼られたメッシュが確認できる  

また、テクスチャの履歴として  
execute/atlas_backup  
が作成され、TextureMeshの実行時に

```
TextureMesh scene_dense.mvs --mesh-file [メッシュ名.ply]　--retexture 1
```

とすると、テクスチャ貼り付けの履歴を再利用できる  

## 4.5. Optical画像の貼り付け

```
~/openMVG_build/software/SfM/input/[フォルダ名]/opt/[画像名].jpg
```

のようにしてopticalマッピング画像を用意  

```
python opt_list.py
```

と実行し、optical画像の通し番号をopt_list.txtとして取得する。  

htmlファイルで確認した位置姿勢推定が成功しているカメラ画像を確認し  
opttexture.shを書き換え以下のように実行  

```
/bin/bash opttexture.sh
```

このファイルではoptical画像をコピーし、位置姿勢推定が成功している画像名にoptical画像のファイル名を変更し、  
TextureMesh関数を実行している  
これにより、  
openMVG_build/software/SfM/input/[フォルダ名]/opt_out/  
以下にopticalのテクスチャを貼り付けたplyファイルとpngファイルが出力される。  
