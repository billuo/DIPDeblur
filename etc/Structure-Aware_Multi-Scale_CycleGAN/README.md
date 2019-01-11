## Environment

* TensorFlow1.8 & Python3

## Data preparing

* First, download a dataset, e.g. GOPRO from https://github.com/SeungjunNah/DeepDeblur_release

* Since the dir structure in download dataset GOPRO is different from what we need, so we should adjust the dir structure
```bash
$ python buildDataset.py 
```

* Write the dataset to tfrecords
```bash
$ python build_data.py --X_input_dir training_set/blur' \
						--Y_input_dir training_set/sharp \
						--X_output_file training_set/tfrecords/blur.tfrecords \
						--Y_output_file training_set/tfrecords/sharp.tfrecords
```

## Training
For training, you need to download a "vgg16.npy"
```bash
$ python train.py  
```
To change other default settings, you can check 'train.py'


## Check TensorBoard to see training progress and generated images.
```
$ tensorboard --logdir checkpoints/${datetime}
```

## Export model
You can export from a checkpoint to a standalone GraphDef file as follow:

```bash
$ python export_graph.py --checkpoint_dir checkpoints/${datetime} \
                          --XtoY_model blur2sharp.pb \
                          --YtoX_model sharp2blur.pb \
                          --image_size 256
```

## Inference
After exporting model, you can use it for inference. For example:
```bash
python inference.py --model pretrained/blur2deblur.pb \
                     --input input_sample.jpg \
                     --output output_sample.jpg \
                     --image_size 256
```
More sample inference code are given in 'trans.txt' 

