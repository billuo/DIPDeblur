import tensorflow as tf
import ops
import utils
from reader import Reader
from discriminator import Discriminator
from generator import Generator

REAL_LABEL = 0.9

class CycleGAN:
  def __init__(self,
               X_train_file='',
               Y_train_file='',
               batch_size=1,
               image_size=256,
               use_lsgan=True,
               norm='instance',
               lambda1=1.0,
               lambda2=1.0,
               phi1=5.0,
               phi2=5.0,
               learning_rate=2e-4,
               beta1=0.5,
               ngf=64,
               skip=False
              ):
      """
      Args:
        X_train_file: string, X tfrecords file for training
        Y_train_file: string Y tfrecords file for training
        batch_size: integer, batch size
        image_size: integer, image size
        lambda1: integer, weight for forward cycle loss (X->Y->X)
        lambda2: integer, weight for backward cycle loss (Y->X->Y)
        use_lsgan: boolean
        norm: 'instance' or 'batch'
        learning_rate: float, initial learning rate for Adam
        beta1: float, momentum term of Adam
        ngf: number of gen filters in first conv layer
      """
      self.lambda1 = lambda1 #
      self.lambda2 = lambda2
      self.phi1 = phi1
      self.phi2 = phi2
      self.use_lsgan = use_lsgan
      use_sigmoid = not use_lsgan
      self.batch_size = batch_size
      self.image_size = image_size
      self.learning_rate = learning_rate
      self.beta1 = beta1

      self.X_train_file = X_train_file
      self.Y_train_file = Y_train_file
      self.skip = skip

      self.is_training = tf.placeholder_with_default(True, shape=[], name='is_training')

    #定义2*3个生成器和鉴别器
      self.G = Generator('G', self.is_training, ngf=ngf, norm=norm, image_size=image_size, skip=self.skip)
      self.D_Y_256 = Discriminator('D_Y_256',
          self.is_training, norm=norm, use_sigmoid=use_sigmoid)
      self.D_Y_128 = Discriminator('D_Y_128',
                                   self.is_training, norm=norm, use_sigmoid=use_sigmoid)
      self.D_Y_64 = Discriminator('D_Y_64',
                                   self.is_training, norm=norm, use_sigmoid=use_sigmoid)
      self.F = Generator('F', self.is_training, ngf=ngf, norm=norm, image_size=image_size,skip=self.skip)
      self.D_X_256 = Discriminator('D_X_256',
                                   self.is_training, norm=norm, use_sigmoid=use_sigmoid)
      self.D_X_128 = Discriminator('D_X_128',
                                   self.is_training, norm=norm, use_sigmoid=use_sigmoid)
      self.D_X_64 = Discriminator('D_X_64',
                                  self.is_training, norm=norm, use_sigmoid=use_sigmoid)

      self.fake_x_size256 = tf.placeholder(tf.float32,
          shape=[batch_size, image_size, image_size, 3])
      self.fake_y_size256 = tf.placeholder(tf.float32,
          shape=[batch_size, image_size, image_size, 3])
      self.fake_x_size128 = tf.placeholder(tf.float32,
                                           shape=[batch_size, image_size* 0.5, image_size* 0.5, 3])
      self.fake_y_size128 = tf.placeholder(tf.float32,
                                           shape=[batch_size, image_size* 0.5, image_size* 0.5, 3])
      self.fake_x_size64 = tf.placeholder(tf.float32,
                                           shape=[batch_size, image_size* 0.25, image_size* 0.25, 3])
      self.fake_y_size64 = tf.placeholder(tf.float32,
                                           shape=[batch_size, image_size* 0.25, image_size* 0.25, 3])


  def model(self):
      X_reader = Reader(self.X_train_file, name='X',
          image_size=self.image_size, batch_size=self.batch_size)
      Y_reader = Reader(self.Y_train_file, name='Y',
          image_size=self.image_size, batch_size=self.batch_size)

      x = X_reader.feed()
      y = Y_reader.feed()

      # X -> Y
      #if we want to enhance multi-scale, function G has to return 64*64 and 128 *128 pred image
      fake_y_size64, fake_y_size128, fake_y_size256 = self.G(x)
      G_gan_loss = self.generator_loss(self.D_Y_256, fake_y_size256, use_lsgan=self.use_lsgan)
      G_gan_loss += self.generator_loss(self.D_Y_128, fake_y_size128, use_lsgan=self.use_lsgan)
      G_gan_loss += self.generator_loss(self.D_Y_64, fake_y_size64, use_lsgan=self.use_lsgan)


      D_Y_256_loss = self.discriminator_loss(self.D_Y_256, y, self.fake_y_size256, use_lsgan=self.use_lsgan)  #

      _, yh_128, yw_128, _ = fake_y_size128.get_shape().as_list()
      y_128 = tf.image.resize_images(y, [yh_128, yw_128], method=0)
      D_Y_128_loss = self.discriminator_loss(self.D_Y_128, y_128, self.fake_y_size128, use_lsgan=self.use_lsgan)  #

      _, yh_64, yw_64, _ = fake_y_size64.get_shape().as_list()
      y_64 = tf.image.resize_images(y, [yh_64, yw_64], method=0)
      D_Y_64_loss = self.discriminator_loss(self.D_Y_64, y_64, self.fake_y_size64, use_lsgan=self.use_lsgan)  #

      # Y -> X
      fake_x_size64, fake_x_size128, fake_x_size256 = self.F(y)
      F_gan_loss = self.generator_loss(self.D_X_256, fake_x_size256, use_lsgan=self.use_lsgan)
      F_gan_loss += self.generator_loss(self.D_X_128, fake_x_size128, use_lsgan=self.use_lsgan)
      F_gan_loss += self.generator_loss(self.D_X_64, fake_x_size64, use_lsgan=self.use_lsgan)

      D_X_256_loss = self.discriminator_loss(self.D_X_256, x, self.fake_x_size256, use_lsgan=self.use_lsgan)

      _, xh_128, xw_128, _ = fake_x_size128.get_shape().as_list()
      x_128 = tf.image.resize_images(x, [xh_128, xw_128], method=0)
      D_X_128_loss = self.discriminator_loss(self.D_X_128, x_128, self.fake_x_size128, use_lsgan=self.use_lsgan)  #

      _, xh_64, xw_64, _ = fake_x_size64.get_shape().as_list()
      x_64 = tf.image.resize_images(x, [xh_64, xw_64], method=0)
      D_X_64_loss = self.discriminator_loss(self.D_X_64, x_64, self.fake_x_size64, use_lsgan=self.use_lsgan)  #


      rec_x_size64, rec_x_size128, rec_x_size256 = self.F(fake_y_size256)
      rec_y_size64, rec_y_size128, rec_y_size256 = self.G(fake_x_size256)

      cycle_loss = self.cycle_consistency_loss( rec_x_size256, x,rec_y_size256, y)
      cycle_loss += self.cycle_consistency_loss(rec_x_size128, x_128, rec_y_size128, y_128)
      cycle_loss += self.cycle_consistency_loss(rec_x_size64, x_64, rec_y_size64, y_64)
      G_content_loss = self.content_loss(fake_x_size256, x)
      G_content_loss += self.content_loss(fake_x_size128, x_128)
      G_content_loss += self.content_loss(fake_x_size64, x_64)

      F_content_loss = self.content_loss(fake_y_size256, y)
      F_content_loss += self.content_loss(fake_y_size128, y_128)
      F_content_loss += self.content_loss(fake_y_size64, y_64)

      G_loss = G_gan_loss + G_content_loss + cycle_loss
      F_loss = F_gan_loss + F_content_loss + cycle_loss

      # summary
      #a  histogram  visualization
      tf.summary.histogram('D_Y/true', self.D_Y_256(y))
      tf.summary.histogram('D_Y/fake', self.D_Y_256(self.G(x)[-1]))
      tf.summary.histogram('D_X/true', self.D_X_256(x))
      tf.summary.histogram('D_X/fake', self.D_X_256(self.F(y)[-1]))

      tf.summary.scalar('loss/G', G_gan_loss)
      tf.summary.scalar('loss/D_Y_256', D_Y_256_loss)
      tf.summary.scalar('loss/D_Y_128', D_Y_128_loss)
      tf.summary.scalar('loss/D_Y_64', D_Y_64_loss)

      tf.summary.scalar('loss/F', F_gan_loss)
      tf.summary.scalar('loss/D_X_256', D_X_256_loss)
      tf.summary.scalar('loss/D_X_128', D_X_128_loss)
      tf.summary.scalar('loss/D_X_64', D_X_64_loss)
      tf.summary.scalar('loss/cycle', cycle_loss)

      tf.summary.image('X/generated', utils.batch_convert2int(self.G(x)[-1]))
      tf.summary.image('X/reconstruction', utils.batch_convert2int(self.F(self.G(x)[-1])[-1]))
      tf.summary.image('Y/generated', utils.batch_convert2int(self.F(y)[-1]))
      tf.summary.image('Y/reconstruction', utils.batch_convert2int(self.G(self.F(y)[-1])[-1]))

      return G_loss, D_Y_256_loss, D_Y_128_loss, D_Y_64_loss, F_loss, D_X_256_loss, D_X_128_loss, D_X_64_loss,fake_y_size64, fake_y_size128, fake_y_size256 ,fake_x_size64, fake_x_size128, fake_x_size256

  def optimize(self, G_loss, D_Y_256_loss, D_Y_128_loss, D_Y_64_loss, F_loss, D_X_256_loss, D_X_128_loss, D_X_64_loss):
      def make_optimizer(loss, variables, name='Adam'):
            """ Adam optimizer with learning rate 0.0002 for the first 100k steps (~100 epochs)
                and a linearly decaying rate that goes to zero over the next 100k steps
            """
            global_step = tf.Variable(0, trainable=False)
            starter_learning_rate = self.learning_rate
            end_learning_rate = 0.0
            start_decay_step = 100000
            decay_steps = 100000
            beta1 = self.beta1
            learning_rate = (
                tf.where(
                        tf.greater_equal(global_step, start_decay_step),
                        tf.train.polynomial_decay(starter_learning_rate, global_step-start_decay_step,
                                                  decay_steps, end_learning_rate,
                                                  power=1.0),
                        starter_learning_rate
                )

            )
            tf.summary.scalar('learning_rate/{}'.format(name), learning_rate)

            learning_step = (
                tf.train.AdamOptimizer(learning_rate, beta1=beta1, name=name)
                        .minimize(loss, global_step=global_step, var_list=variables)
            )
            return learning_step

      G_optimizer = make_optimizer(G_loss, self.G.variables, name='Adam_G')
      D_Y_256_optimizer = make_optimizer(D_Y_256_loss, self.D_Y_256.variables, name='Adam_D_Y_256')
      D_Y_128_optimizer = make_optimizer(D_Y_128_loss, self.D_Y_128.variables, name='Adam_D_Y_128')
      D_Y_64_optimizer = make_optimizer(D_Y_64_loss, self.D_Y_64.variables, name='Adam_D_Y_64')

      F_optimizer =  make_optimizer(F_loss, self.F.variables, name='Adam_F')
      D_X_256_optimizer = make_optimizer(D_X_256_loss, self.D_X_256.variables, name='Adam_D_X_256')
      D_X_128_optimizer = make_optimizer(D_X_128_loss, self.D_X_128.variables, name='Adam_D_X_128')
      D_X_64_optimizer = make_optimizer(D_X_64_loss, self.D_X_64.variables, name='Adam_D_X_64')

      with tf.control_dependencies([G_optimizer, D_Y_256_optimizer, D_Y_128_optimizer, D_Y_64_optimizer, F_optimizer, D_X_256_optimizer, D_X_128_optimizer, D_X_64_optimizer]):
        return tf.no_op(name='optimizers')

  def discriminator_loss(self, D, y, fake_y, use_lsgan=True):
      """ Note: default: D(y).shape == (batch_size,5,5,1),
                         fake_buffer_size=50, batch_size=1
      Args:
        G: generator object
        D: discriminator object
        y: 4D tensor (batch_size, image_size, image_size, 3)
      Returns:
        loss: scalar
      """
      if use_lsgan:
        # use mean squared error
        error_real = tf.reduce_mean(tf.squared_difference(D(y), REAL_LABEL))
        error_fake = tf.reduce_mean(tf.square(D(fake_y)))
      else:
        # use cross entropy
        error_real = -tf.reduce_mean(ops.safe_log(D(y)))
        error_fake = -tf.reduce_mean(ops.safe_log(1-D(fake_y)))
      loss = (error_real + error_fake) / 2
      return loss

  def generator_loss(self, D, fake_y, use_lsgan=True):
      """  fool discriminator into believing that G(x) is real
      """
      if use_lsgan:
        # use mean squared error
        loss = tf.reduce_mean(tf.squared_difference(D(fake_y), REAL_LABEL))
      else:
        # heuristic, non-saturating loss
        loss = -tf.reduce_mean(ops.safe_log(D(fake_y))) / 2
      return loss

  def cycle_consistency_loss(self, pred_x, real_x, pred_y, real_y): #这就是cycleGAN的cycle loss
      """ cycle consistency loss (L1 norm)
      """
      forward_loss = tf.reduce_mean(tf.abs(pred_x - real_x))
      backward_loss = tf.reduce_mean(tf.abs(pred_y - real_y))
      loss = self.lambda1*forward_loss + self.lambda2*backward_loss
      return loss
  def content_loss(self, pred_x, real_x): # MSE and SSIM loss
      mse_loss = tf.reduce_mean((pred_x - real_x)**2)
      gradient_gt_i_x, gradient_gt_i_y = tf.image.image_gradients(real_x)
      gradient_pred_x, gradient_pred_y = tf.image.image_gradients(pred_x)
      ssim_x = tf.image.ssim(gradient_gt_i_x, gradient_pred_x, max_val=1.0)
      ssim_y = tf.image.ssim(gradient_gt_i_y, gradient_pred_y, max_val=1.0)
      ssim_loss = 1 - tf.reduce_mean((ssim_x ** 2 + ssim_y ** 2) / 2)
      loss = self.phi1 * mse_loss + self.phi2 * ssim_loss
      return loss
