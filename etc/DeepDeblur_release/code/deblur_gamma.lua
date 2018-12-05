-- th main.lua -load -save release_scale3_adv_gamma -blur_type gamma2.2 -type cudaHalf
-- >dofile 'deblur_gamma.lua'
require 'lfs'
local dataset = '../dataset/GOPRO_Large/test/'
local output_dir = '../deblur_output/'
for file in lfs.dir(dataset) do
  if file ~= '.' and file ~= '..' then
    local input = dataset .. file
    local output = output_dir .. file
    if lfs.attributes(input, 'mode') == 'directory' then
      local kernel = '/blur_gamma'
      output = output .. kernel
      input = input .. kernel
      print(string.format('Deblurring directory %s => %s', input, output))
      deblur_dir(input, output)
    end
  end
end
