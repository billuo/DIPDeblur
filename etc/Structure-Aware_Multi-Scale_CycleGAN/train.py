import time
import tensorflow as tf
from model import CycleGAN
from datetime import datetime
import os
from utils import ImagePool

FLAGS = tf.flags.FLAGS

tf.flags.DEFINE_integer('batch_size', 1, 'batch size, default: 1')
tf.flags.DEFINE_integer('image_size', 256, 'image size, default: 256')
tf.flags.DEFINE_bool('use_lsgan', True,
                     'use lsgan (mean squared error) or cross entropy loss, default: True')
tf.flags.DEFINE_string('norm', 'instance',
                       '[instance, batch] use instance norm or batch norm, default: instance')
tf.flags.DEFINE_integer('lambda1', 1,
                        'weight for forward cycle loss (X->Y->X), default: 1')
tf.flags.DEFINE_integer('lambda2', 1,
                        'weight for backward cycle loss (Y->X->Y), default: 1:')
tf.flags.DEFINE_integer('phi1', 1,
                        'weight for content loss MSE, default: 1')
tf.flags.DEFINE_integer('phi2', 1,
                        'weight for content loss SSIM, default: 1')
tf.flags.DEFINE_integer('phi3', 1,
                        'weight for content loss SSIM_gradient, default: 1')
tf.flags.DEFINE_float('learning_rate', 2e-4,
                      'initial learning rate for Adam, default: 0.0002')
tf.flags.DEFINE_float('beta1', 0.5,
                      'momentum term of Adam, default: 0.5')
tf.flags.DEFINE_float('pool_size', 50,
                      'size of image buffer that stores previously generated images, default: 50')
tf.flags.DEFINE_integer('ngf', 64,
                        'number of gen filters in first conv layer, default: 64')
tf.flags.DEFINE_string('gpu_id', '0',
                        'use gpu or cpu, default: 0')

tf.flags.DEFINE_string('X', 'training_set/tfrecords/blur.tfrecords',
                       'X tfrecords file for training, default: training_set/tfrecords/blur.tfrecords')
tf.flags.DEFINE_string('Y', 'training_set/tfrecords/sharp.tfrecords',
                       'Y tfrecords file for training, default: training_set/tfrecords/sharp.tfrecords')
tf.flags.DEFINE_string('load_model', None,
                        'folder of saved model that you wish to continue training (e.g. 20170602-1936), default: None')
#tf.flags.DEFINE_string('skip', False,
#                        'use skip or not, default: False')


def train():
  if FLAGS.load_model is not None:
    checkpoints_dir = "checkpoints/" + FLAGS.load_model.lstrip("checkpoints/")
  else:
    current_time = datetime.now().strftime("%Y%m%d-%H%M")
    checkpoints_dir = "checkpoints/{}".format(current_time)
    try:
      os.makedirs(checkpoints_dir)
    except os.error:
      pass
      # set gpu/cpu mode
  if int(FLAGS.gpu_id) >= 0:
          os.environ['CUDA_VISIBLE_DEVICES'] = FLAGS.gpu_id
  else:
          os.environ['CUDA_VISIBLE_DEVICES'] = ''
  graph = tf.Graph()
  with graph.as_default():
    cycle_gan = CycleGAN(
        X_train_file=FLAGS.X,
        Y_train_file=FLAGS.Y,
        batch_size=FLAGS.batch_size,
        image_size=FLAGS.image_size,
        use_lsgan=FLAGS.use_lsgan,
        norm=FLAGS.norm,
        lambda1=FLAGS.lambda1,
        lambda2=FLAGS.lambda2,
        phi1 = FLAGS.phi1,
        phi2 = FLAGS.phi2,
        phi3 = FLAGS.phi3,
        learning_rate=FLAGS.learning_rate,
        beta1=FLAGS.beta1,
        ngf=FLAGS.ngf
#        skip=FLAGS.skip
    )
    G_loss, D_Y_256_loss, D_Y_128_loss, D_Y_64_loss, F_loss, D_X_256_loss, D_X_128_loss, D_X_64_loss,\
    fake_y_size64,fake_y_size128,fake_y_size256, fake_x_size64,fake_x_size128,fake_x_size256= cycle_gan.model()
    optimizers = cycle_gan.optimize(G_loss, D_Y_256_loss, D_Y_128_loss, D_Y_64_loss, F_loss, D_X_256_loss, D_X_128_loss, D_X_64_loss)

    summary_op = tf.summary.merge_all()
    train_writer = tf.summary.FileWriter(checkpoints_dir, graph)
    saver = tf.train.Saver()

  with tf.Session(graph=graph) as sess:
    if FLAGS.load_model is not None:
      checkpoint = tf.train.get_checkpoint_state(checkpoints_dir)
      meta_graph_path = checkpoint.model_checkpoint_path + ".meta"
      restore = tf.train.import_meta_graph(meta_graph_path)
      restore.restore(sess, tf.train.latest_checkpoint(checkpoints_dir))
      step = int(meta_graph_path.split("-")[2].split(".")[0])
    else:
      sess.run(tf.global_variables_initializer())
      step = 0

    coord = tf.train.Coordinator()
    threads = tf.train.start_queue_runners(sess=sess, coord=coord)

    try:
      fake_Y_256_pool = ImagePool(FLAGS.pool_size)
      fake_X_256_pool = ImagePool(FLAGS.pool_size)
      fake_Y_128_pool = ImagePool(FLAGS.pool_size)
      fake_X_128_pool = ImagePool(FLAGS.pool_size)
      fake_Y_64_pool = ImagePool(FLAGS.pool_size)
      fake_X_64_pool = ImagePool(FLAGS.pool_size)

      while not coord.should_stop():

        # get previously generated images
        start_time = time.time()
        fake_y_256_val, fake_x_256_val,fake_y_128_val, fake_x_128_val,fake_y_64_val, fake_x_64_val = sess.run(
            [fake_y_size256, fake_x_size256,fake_y_size128, fake_x_size128,fake_y_size64, fake_x_size64])
        duration = time.time() - start_time
        # train
        _, G_loss_val, D_Y_256_loss_val, D_Y_128_loss_val, D_Y_64_loss_val, F_loss_val, \
        D_X_256_loss_val, D_X_128_loss_val, D_X_64_loss_val, summary = (
              sess.run(
                  [optimizers, G_loss, D_Y_256_loss, D_Y_128_loss, D_Y_64_loss, F_loss, D_X_256_loss, D_X_128_loss, D_X_64_loss, summary_op],
                  feed_dict={cycle_gan.fake_y_size256: fake_Y_256_pool.query(fake_y_256_val),
                             cycle_gan.fake_x_size256: fake_X_256_pool.query(fake_x_256_val),
                             cycle_gan.fake_y_size128: fake_Y_128_pool.query(fake_y_128_val),
                             cycle_gan.fake_x_size128: fake_X_128_pool.query(fake_x_128_val),
                             cycle_gan.fake_y_size64: fake_Y_64_pool.query(fake_y_64_val),
                             cycle_gan.fake_x_size64: fake_X_64_pool.query(fake_x_64_val)
                             }
              )
        )

        train_writer.add_summary(summary, step)
        train_writer.flush()

        if step % 5 == 0:
          sec_per_batch = float(duration)
          print('-----------Step %d:-------------' % step)
          print('  G_loss   : {}'.format(G_loss_val))
          print('  D_Y_256_loss : {}'.format(D_Y_256_loss_val))
          print('  D_Y_128_loss : {}'.format(D_Y_128_loss_val))
          print('  D_Y_64_loss : {}'.format(D_Y_64_loss_val))
          print('  F_loss   : {}'.format(F_loss_val))
          print('  D_X_256_loss : {}'.format(D_X_256_loss_val))
          print('  D_X_128_loss : {}'.format(D_X_128_loss_val))
          print('  D_X_64_loss : {}'.format(D_X_64_loss_val))
          print('  second per batch : {}'.format(sec_per_batch))
        if step % 1000 == 0:
          save_path = saver.save(sess, checkpoints_dir + "/model.ckpt", global_step=step)
          print("Model saved in file: %s" % save_path)

        step += 1

    except KeyboardInterrupt:
      print('Interrupted')
      coord.request_stop()
    except Exception as e:
      coord.request_stop(e)
    finally:
      save_path = saver.save(sess, checkpoints_dir + "/model.ckpt", global_step=step)
      print("Model saved in file: %s" % save_path)
      # When done, ask the threads to stop.
      coord.request_stop()
      coord.join(threads)

def main(unused_argv):
  train()

if __name__ == '__main__':
  tf.app.run()
