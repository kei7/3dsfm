# 3D Structure from Morion
structure from motion for docker
# 1．Dockerコンテナの作成
## 1.1. Dockerのイメージを最新版に

```
docker pull nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04
```

## 1.2. Dockerコンテナの作成
docker-compose.ymlの内容でコンテナ作成
必要に応じてdocker-compose.ymlのcontainer_nameを書き換える
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

### 2.2. Eigen
openMVSの依存ライブラリ

### 2.3. Vcglib
openMVSの依存ライブラリ

### 2.4. Ceres
openMVSの依存ライブラリ  

### 2.5. OpenMVS
#### 繰り返しテクスチャを行う場合のリポジトリ(デフォルト推奨)
https://github.com/thunders82/openMVS.git

#### OpenMVS メインストリームのGitリポジトリ
https://github.com/cdcseacave/openMVS.git

#### ファイルコピーとビルド

```
cp /home/repos/3dsfm/dev_mvg/SceneTexture.cpp /home/repos/openMVS/libs/MVS/
cd /home/repos/openMVS_build
cmake . ../openMVS -DCMAKE_BUILD_TYPE=RELEASE -DVCG_ROOT="/home/repos/vcglib" -DBUILD_SHARED_LIBS=OFF -DOpenMVS_USE_CUDA=OFF -DOpenMVS_USE_BREAKPAD=OFF
make -j2
make install
```

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

## 2.6. Meshlab 
ローカルのPCにて
http://www.meshlab.net/  
からインストールファイルをインストールし実行  

# 3. 再構成用画像の準備
## 3.1. 画像のコピー
Structure from Motionの入力として読み込む画像はjpg画像に直して~/openMVG_build/software/SfM/input/[フォルダ名]/images/[画像名].jpg  
となるようにしてコピーする必要がある  

### 設定ファイルの編集
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
IMGDIRNAME="20200109-1-3_1"  #画像フォルダのフォルダ名
再構成用画像のあるフォルダ名を入力 
INPUT="/mnt/Share/ExperimentData/20200109-1/20200109-1-3_1" #画像フォルダへの絶対パス
```
 
その後画像ファイルをコピーする  
 
```
/bin/bash copy.sh
```

**実行結果例**
```
/bin/bash copy.sh
ls /home/repos/openMVG_build/software/SfM/input/20200109-1-3_1/images/
#出力結果
$ H*.jpg <= 形状推定カメラ画像  
 OPTA*.jpg <= 高速度カメラ1画像  
 OPTB*.jpg <= 高速度カメラ2画像  
 OPTC*.jpg <= 高速度カメラ3画像  
```

## 3.2. カメラ素子サイズについて
以下のことに留意する  

```
vi /home/repos/3dsfm/execute/sensor_width_camera_database.txt  
```

とすると以下のようになっている  

```
SO-01K;6.167 #例1 形状推定カメラ
SA-4-512A;10.240 #例2 高速度カメラA
SA-4-512B;10.241 #例3 高速度カメラB
Mini-512C;10.242 #例4 高速度カメラC
```

[カメラの機種名];[画像センサ素子サイズ(mm)]となるように記述する必要がある

**この時、使用するカメラ機種名や素子サイズが同じ場合でも、複数台のカメラを使う場合は
SA4-512A;10.240  
SA4-512B;10.241  
のように異なる機種名、素子サイズを書き込まなければ複数のカメラが同じ内部パラメータを持つように設定されてしまうので注意する。**  

## 3.3. exifデータの編集について
画像のexifデータ(メタデータ)を書き換える

```
vi /home/repos/3dsfm/execute/chexif.py  
```

とし必要に応じてL21以降を書き換える。  

```
data["Exif.Image.Model"] = "SO-01K" #撮影カメラ機種名。sensor_width_camera_database.txtに追加したカメラ機種名と一致させる
data["Exif.Photo.FocalLength"] = meta1["Exif.Photo.FocalLength"].value #焦点距離　仮の値を別ファイルからコピーする。参照ファイルはリポジトリ内にある
data["Exif.Photo.PixelXDimension"] = 1920 #画像の横サイズ
data["Exif.Photo.PixelYDimension"] = 1080 #画像の縦サイズ
```

例  
~/openMVG_build/software/SfM/input/20200109-1-3_1/images/H*.jpg <= 形状推定カメラ画像,  [カメラモデル]="SO-01K"  
~/openMVG_build/software/SfM/input/20200109-1-3_1/images/OPTA*.jpg <= 高速度カメラA画像,  [カメラモデル]="SA4-512A"  
~/openMVG_build/software/SfM/input/20200109-1-3_1/images/OPTB*.jpg <= 高速度カメラB画像,  [カメラモデル]="SA4-512B"  
~/openMVG_build/software/SfM/input/20200109-1-3_1/images/OPTC*.jpg <= 高速度カメラC画像,  [カメラモデル]="Mini-512C"  

**この時カメラモデルが3.2.で書き込んだモデルと一致させるように注意する**

## 3.4. カメラ内部パラメータの計算
/home/repos/3dsfm/execute/calibrate.py  
を実行して形状推定カメラ1台と高速度カメラ3台それぞれについて正方形のチェスパターン画像から内部パラメータを計算する。  
必要に応じてL8,9のキャリブレーションパターンを変更する。  

```
vi calibrate.py
```

```
square_size = 0.8      # 正方形パターン1つの一辺のサイズ
pattern_size = (3,3)  # 模様のサイズ
```

編集後カメラ内部パラメータのキャリブレーションを以下のコマンドで実行

```
cd /home/repos/3dsfm/execute
python calibrate.py [キャリブレーション画像フォルダへのパス]
```

**実行例**  

```
cd /home/repos/3dsfm/execute
python calibrate.py /home/repos/openMVG_build/software/SfM/input/20200109-1-3_1/calib  #形状推定カメラキャリブレーション
python calibrate.py /home/repos/openMVG_build/software/SfM/input/20200109-1-3_1/cam_calibA  #高速度カメラ1キャリブレーション
python calibrate.py /home/repos/openMVG_build/software/SfM/input/20200109-1-3_1/cam_calibB  #高速度カメラ2キャリブレーション
python calibrate.py /home/repos/openMVG_build/software/SfM/input/20200109-1-3_1/cam_calibC  #高速度カメラ3キャリブレーション
```

すると各カメラについてキャリブレーション結果が例として以下のように得られる  

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

**このキャリブレーション結果のKとdが再構成に必要となるのでエディタなどにコピーする**  
ここで、実行結果について  
形状推定カメラの内部パラメータをC0  
高速度カメラAの内部パラメータをC1  
高速度カメラBの内部パラメータをC2  
高速度カメラCの内部パラメータをC3  
とする  

# 4. 再構成の実行
## 4.1. 画像読み込み
executeフォルダに移動し以下のように実行  

```
/bin/bash imagelisting.sh
```

すると  
~/openMVG_build/software/SfM/input/[フォルダ名]/out/matches/sfm_data.json  
というファイルが生成される。このファイルは/home/repos/3dsfm/execute/にもコピーされる  
実行結果例  
```
/bin/bash imagelisting.sh
ls /openMVG_build/software/SfM/input/20200109-1-3_1/out/matches/
$ sfm_data.json
```

## 4.2. 内部パラメータの同定 
4.1.で生成されたsfm_data.jsonの構成は以下のようになっているので確認する  

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
	{
            "key": 1,
            "value": {
                "polymorphic_id": 2147483650,
                "polymorphic_name": "pinhole_radial_k3",
                "ptr_wrapper": {
                    "id": 2147484127,
                    "data": {
                        "width": 1920,
                        "height": 1080,
                        "focal_length": 1314.00000476837159,
                        "principal_point": [
                            960.0,
                            540.0
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

ここで、"intrinsics"に書き込まれている4つの内部パラメータについてC0',C1',C2',C3'とする  

**ここでは、3.4.で計算した内部パラメータC0,C1,C2,C3と"intrinsics"の内部パラメータC0',C1',C2',C3'の対応関係を求めたい**



例  
"views"に書き込まれている画像について"key"=0 の画像は"value"の"filename":"H00020.jpg"より形状推定カメラの画像であることがわかる
よって内部パラメータC0に対応している  
また"views"の画像の"value"の"id_intrinsic":1　より内部パラメータC1'と対応していることがわかる  
よって　C0=C1'  
また"H*.jpg"という画像は"id_intrinsic":1を共有している  
同様の手順により  
"OPTA*.jpg"という画像が"id_intrinsic":3を共有とすると  
C1=C3'  
"OPTB*.jpg"という画像が"id_intrinsic":2を共有とすると  
C2=C2'  
"OPTC*.jpg"という画像が"id_intrinsic":0を共有とすると  
C3=C0'  

という関係がわかる

そこで3.4.で計算した内部パラメータKとdから各画像に対応する内部パラメータを入力する。  
内部パラメータ0のKとdを用いて

"intrinsics"の"key"=1のについて
Kの(1,1)成分と(2,2)成分からからfocallengthを計算し入力  
"focal_length" = {[(1,1)成分]+[(2,2)成分]}/0.5  

dの第1第2成分をdisto_k3の第1第2成分に入力する   
"disto_k3"=[[dの第1成分], [dの第2成分], 0.0, 0.0, 0.0]  

書き込み例
```
	{
            "key": 1,
            "value": {
                "polymorphic_id": 2147483650,
                "polymorphic_name": "pinhole_radial_k3",
                "ptr_wrapper": {
                    "id": 2147484127,
                    "data": {
                        "width": 1920,
                        "height": 1080,
                        "focal_length": 3120, <= Kから入力
                        "principal_point": [
                            960.0,
                            540.0
                        ],
                        "disto_k3": [
                            9.89016633e-01, <= dから入力
			    -6.64973985e+01, <= dから入力
                            0.0
                        ]
                    }
                }
            }
        },
```

## 4.3.  マッチングの実行

```
cp ./sfm_data.json /home/repos/openMVG_build/software/SfM/input/[フォルダ名]/out/matches/
/bin/bash featurematch.sh
```

実行例  

```
cp ./sfm_data.json /home/repos/openMVG_build/software/SfM/input/20200109-1-3_1/out/matches/
/bin/bash featurematch.sh
```

これによりマッチングが行われ実行結果が  
~/openMVG_build/software/SfM/input/[フォルダ名]/out/matches/に出力され    
特徴量とマッチング結果が出力される  
特徴量は[画像名].featの形で出力され  

```
[特徴点1のx座標] [特徴点1のy座標] [特徴点1のパラメータ1] [特徴点1のパラメータ2]
[特徴点2のx座標] [特徴点2のy座標] [特徴点2のパラメータ1] [特徴点2のパラメータ2]
...
```

のような構造になっている  
また、マッチング結果はsfm_data.bin,matches.f.txtで出力され  

```
[画像1の通し番号] [画像2の通し番号]
[マッチングした特徴点の組数]
[画像1の特徴点の通し番号1] [画像2の特徴点の通し番号1]
[画像1の特徴点の通し番号2] [画像2の特徴点の通し番号2]
...
```

のような構造になっている  
手動でマッチング結果を追加する場合はmatches.f.txtに特徴点マッチングを追加して続きを実行すればよい  

## 4.4. Structure from Motionによる位置姿勢推定
以下のように実行  

```
/bin/bash incrementSfM.sh
```  

これにより、~/openMVG_build/software/SfM/input/[フォルダ名]/out/reconstruction_sequential以下に  
scene.mvs、scene.ply、cloud_and_poses.ply、htmlファイルなどが出力される。  
cloud_and_poses.plyをmeshlabで確認すると、カメラ位置が緑の点で、マッチングした特徴点が灰色で示される。  
htmlファイルにはStructure from Motionの結果が記述されており、位置姿勢推定ができたカメラ画像については誤差が表示され、できなかった画像については空白が表示される。    

## 4.5. メッシュの再構成
以下のように実行  

```
/bin/bash reconstruct.sh
```

これにより、openMVSによるメッシュ再構成が行われ  
~/openMVG_build/software/SfM/input/[フォルダ名]/out/reconstruction_sequential以下に  
scene_dense_mesh.plyとしてメッシュファイルが出力される。  

scene_dense_mesh.plyをmeshlabで確認すると正しく推定できていれば心臓メッシュ形状が再構成される  

## 4.6. テクスチャの貼り付け
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
plyで指定したファイルのメッシュのみにテクスチャを貼り付けることができる。  
これにより  
scene_dense_mesh_texture.plyとscene_dense_mesh_texture.png  
が出力される。両方のファイルを同一フォルダに置いた状態でmeshlabでplyファイルを開くとテクスチャが貼られたメッシュが確認できる  

また、テクスチャの履歴として  
/home/repos/3dsfm/execute/atlas_backup  
が作成され、TextureMeshの実行時に

```
TextureMesh scene_dense.mvs --mesh-file [メッシュ名.ply]　--retexture 1
```

とすると、テクスチャ貼り付けの履歴を再利用できる  

## 4.7. Optical画像の貼り付け

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
