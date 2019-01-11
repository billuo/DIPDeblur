import os
import tensorflow as tf

FLAGS = tf.flags.FLAGS
tf.flags.DEFINE_string('original_dir', 'training_set',
                       'Original dataset dir, default: training_set')
tf.flags.DEFINE_string('blur_dir', 'training_set/blur',
                       'blur path, default: training_set/blur')
tf.flags.DEFINE_string('sharp_dir', 'training_set/sharp',
                       'sharp path tfrecords file for training, default: training_set/sharp')


def rename(path, blur_path, sharp_path):
    filelist1 = os.listdir(path)  # 该文件夹下所有的文件（包括文件夹）
    for files in filelist1:  # 遍历所有文件
        filename1 = os.path.splitext(files)[0]  # 文件名
        print(filename1)

        if filename1 != "blur" and filename1 != "sharp":
            filelist2 = os.listdir(path+"\\"+filename1)
            for file in filelist2:
                filename2 =  os.path.splitext(file)[0]
                print(filename2)
                if filename2 == "blur":
                    filelist3 = os.listdir(path + "\\" + filename1 + "\\" + filename2)
                    for image in filelist3:
                        Olddir = os.path.join(path + "\\"+filename1+"\\"+filename2, image)
                        imageName = os.path.splitext(image)[0]
                        imagetype = os.path.splitext(image)[1]
                        Newdir = os.path.join(blur_path, filename1 + imageName + imagetype)  # 新的文件路径
                        os.rename(Olddir, Newdir)  # 重命名
                if filename2 == "sharp":
                    filelist3 = os.listdir(path + "\\" + filename1 + "\\" + filename2)
                    for image in filelist3:
                        Olddir = os.path.join(path + "\\"+filename1+"\\"+filename2, image)
                        imageName = os.path.splitext(image)[0]
                        imagetype = os.path.splitext(image)[1]
                        Newdir = os.path.join(sharp_path, filename1 + imageName + imagetype)  # 新的文件路径
                        os.rename(Olddir, Newdir)  # 重命名


# rename("F:\\GOPRO\\CycleMulti-scaleGAN\\training_set",
#        "F:\\GOPRO\\CycleMulti-scaleGAN\\training_set\\blur",
#        "F:\\GOPRO\\CycleMulti-scaleGAN\\training_set\\sharp")

rename(FLAGS.original_dir, FLAGS.blur_dir, FLAGS.sharp_dir)

