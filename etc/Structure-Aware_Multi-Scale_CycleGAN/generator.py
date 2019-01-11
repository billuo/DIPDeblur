import tensorflow as tf
import ops
import utils

class Generator:
  def __init__(self, name, is_training, skip, ngf=64, norm='instance', image_size=256):
    self.name = name
    self.reuse = False
    self.ngf = ngf
    self.norm = norm
    self.is_training = is_training
    self.image_size = image_size
    self.skip = skip

  def __call__(self, input):
    """
    Args:
      input: batch_size x width x height x 3
    Returns:
      output: same size as input
    """
    with tf.variable_scope(self.name):
      # conv layers
      # input = tf.image.resize_images(input, [self.image_size, self.image_size], method=0)
      n, h, w, c = input.get_shape().as_list()

      c7s1_64 = ops.c7s1_k(input, input, self.ngf, is_training=self.is_training, norm=self.norm,
          reuse=self.reuse, skip=self.skip, name='c7s1_64')                             # (?, w, h, 64)
      d128 = ops.dk(c7s1_64, 2*self.ngf, is_training=self.is_training, norm=self.norm,
          reuse=self.reuse, name='d128')                                 # (?, w/2, h/2, 128)
      d256 = ops.dk(d128, 4*self.ngf, is_training=self.is_training, norm=self.norm,
          reuse=self.reuse, name='d256')                                # (?, w/4, h/4, 256)

      if self.image_size <= 256:
        # use 6 residual blocks for 256x256 images
        res_output = ops.n_res_blocks(d256, reuse=self.reuse, n=6)      # (?, w/4, h/4, 256)
      else:
        # 9 blocks for higher resolution
        res_output = ops.n_res_blocks(d256, reuse=self.reuse, n=9)      # (?, w/4, h/4, 256)

      #since skip is false, so the second parameter is no need to consider
      output64 = ops.c7s1_k(res_output, input, 3, norm=None,
          activation='tanh', reuse=self.reuse, skip=self.skip, name='output64')           # (?, w/4, h/4, 3)

      # fractional-strided convolution
      u128 = ops.uk(res_output, 2*self.ngf, is_training=self.is_training, norm=self.norm,
          reuse=self.reuse, name='u128')                                 # (?, w/2, h/2, 128)

      cat_128 =  tf.image.resize_images(output64, [ int(h/2), int(w/2)], method=0)

      feature_131 = tf.concat([u128, cat_128], axis=3, name='feature131')
      C128 =ops.c7s1_k(feature_131, input, 2 * self.ngf , norm=None, reuse = self.reuse, skip=self.skip, name='C128') # 之后要加两层卷积
      output128 = ops.c7s1_k(C128, input, 3, norm=None,
          activation='tanh', reuse=self.reuse, skip=self.skip, name='output128')           # (?, w/2, h/2, 3)

      # output128 = ops.c7s1_k(u128, input, 3, norm=None,
      #                        activation='tanh', reuse=self.reuse, skip=self.skip, name='output128')  # (?, w/2, h/2, 3)



      # u64 = ops.uk(u128, self.ngf, is_training=self.is_training, norm=self.norm,
      #     reuse=self.reuse, name='u64', output_size=self.image_size)         # (?, w, h, 64  )

      u64 = ops.uk(u128, self.ngf, is_training=self.is_training, norm=self.norm,
          reuse=self.reuse, name='u64')         # (?, w, h, 64  )

      cat_256 = tf.image.resize_images(output128, [int(h), int(w)], method=0)

      feature_67 = tf.concat([u64, cat_256], axis=3, name='feature67')
      C64 = ops.c7s1_k(feature_67, input, self.ngf, norm=None, reuse=self.reuse, skip=self.skip,
                        name='C64')  # 之后要加两层卷积
      # conv layer
      # Note: the paper said that ReLU and _norm were used
      # but actually tanh was used and no _norm here

      output256 = ops.c7s1_k(C64, input, 3, norm=None,
                             activation='tanh', reuse=self.reuse, skip=self.skip, name='output')


      # output256 = ops.c7s1_k(u64, input, 3, norm=None,
      #     activation='tanh', reuse=self.reuse, skip=self.skip, name='output')           # (?, w, h, 3)
    # set reuse=True for next call
    self.reuse = True
    self.variables = tf.get_collection(tf.GraphKeys.TRAINABLE_VARIABLES, scope=self.name)

    return output64, output128, output256 #multi-scale images : 64*64, 128*128, 256*256

  def sample(self, input):
    image = utils.batch_convert2int(self.__call__(input)[-1])
    image = tf.image.encode_jpeg(tf.squeeze(image, [0]))
    return image
