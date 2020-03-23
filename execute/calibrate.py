import numpy
import cv2
from glob import glob
import os 

src_patha = argv[1]

square_size = 0.8      # 正方形パターン1つの一辺のサイズ
pattern_size = (3,3)  # 模様のサイズ
pattern_points = numpy.zeros( (numpy.prod(pattern_size), 3), numpy.float32 ) #チェスボード（X,Y,Z）座標の指定 (Z=0)
pattern_points[:,:2] = numpy.indices(pattern_size).T.reshape(-1, 2)
pattern_points *= square_size
obj_points = []
img_points = []

filesa = sorted(glob.glob(os.path.join(src_patha,'*.png')))
if len(filesa) >0:
    for fn in filesa:
        # 画像の取得
        im = cv2.imread(fn, 0)
        print("loading..." + fn)
        # チェスボードのコーナーを検出
        found, corner = cv2.findChessboardCorners(im, pattern_size)
        # コーナーがあれば
        if found:
            term = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_COUNT, 30, 0.1)
            cv2.cornerSubPix(im, corner, (5,5), (-1,-1), term)
        # コーナーがない場合のエラー処理
        if not found:
            print('chessboard not found')
            continue
        img_points.append(corner.reshape(-1, 2))   #appendメソッド：リストの最後に因数のオブジェクトを追加
        obj_points.append(pattern_points)
        #corner.reshape(-1, 2) : 検出したコーナーの画像内座標値(x, y)

    # 内部パラメータを計算
    rms, K, d, r, t = cv2.calibrateCamera(obj_points,img_points,(im.shape[1],im.shape[0]),None,None)
    # 計算結果を表示
    print("camera opt a")
    print ("RMS = ", rms)
    print ("K = \n", K)
    print ("d = ", d.ravel())
else:
    filesa = sorted(glob.glob(os.path.join(src_patha,'*.jpg')))
    
    for fn in filesa:
        # 画像の取得
        im = cv2.imread(fn, 0)
        print("loading..." + fn)
        # チェスボードのコーナーを検出
        found, corner = cv2.findChessboardCorners(im, pattern_size)
        # コーナーがあれば
        if found:
            term = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_COUNT, 30, 0.1)
            cv2.cornerSubPix(im, corner, (5,5), (-1,-1), term)
        # コーナーがない場合のエラー処理
        if not found:
            print('chessboard not found')
            continue
        img_points.append(corner.reshape(-1, 2))   #appendメソッド：リストの最後に因数のオブジェクトを追加
        obj_points.append(pattern_points)
        #corner.reshape(-1, 2) : 検出したコーナーの画像内座標値(x, y)

    # 内部パラメータを計算
    rms, K, d, r, t = cv2.calibrateCamera(obj_points,img_points,(im.shape[1],im.shape[0]),None,None)
    # 計算結果を表示
    print("camera opt a")
    print ("RMS = ", rms)
    print ("K = \n", K)
    print ("d = ", d.ravel())
