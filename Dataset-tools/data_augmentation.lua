-- Author: Aysegul Dundar
-- Date: December, 2014
require 'image'

require 'pl'
require 'trepl'

opt = lapp[[
   -h,--hflip              (default true)        horizontal flip
   -t,--transImgInt        (default 20)          stepping of translation, number of images to create (ta/t)^2
   --ta                    (default 40)          max translation length
   -r, --rotationImg       (default 2)           number of images to create by rotation
   --ra                    (default 0.1)         max angle of rotation
   -p,--pathToFolder       (default 'images')    path to the folder of images
]]

if not paths.dir(opt.pathToFolder) then
  error(string.format("the folder %s not exist", opt.pathToFolder))
end



function hflip_img(path_img, tmp_img, aug_path)

  local tmp_path = path_img .. "/" .. tmp_img
  local img = image.load(tmp_path)
  local img_flip = image.hflip(img)

  -- assumes .jpg ending for now
  tmp_img = string.sub(tmp_img, 1, -5)
  local img_path = aug_path .. "/" .. tmp_img .. "flip.jpg"
  image.save(img_path, img_flip)

end

function rotate_img(path_img, tmp_img, aug_path, degree)

  local tmp_path = path_img .. "/" .. tmp_img
  local img = image.load(tmp_path)
  local img_rotate = image.rotate(img, degree)

  -- assumes .jpg ending for now
  tmp_img = string.sub(tmp_img, 1, -5)
  local img_path = aug_path .. "/" .. tmp_img ..  "rotate" .. degree .. ".jpg"
  image.save(img_path, img_rotate)

end


function crop5_img(path_img, tmp_img, aug_path, jitter)

  local tmp_path = path_img .. "/" .. tmp_img
  local img = image.load(tmp_path)

  local w = img:size(2) - jitter
  local h = img:size(3) - jitter

  -- assumes .jpg ending for now
  tmp_img = string.sub(tmp_img, 1, -5)

  local number_img = jitter/opt.transImgInt

  for i=1, number_img do
    for j=1, number_img do
       local sample = img[{{}, {1+ (j-1) * opt.transImgInt, (j-1) * opt.transImgInt + w}, 
                               {1+ (i-1) * opt.transImgInt, (i-1) * opt.transImgInt + h}}]
       local img_path = aug_path .. "/" .. tmp_img .. "crop" .. (j+(i-1)*number_img) .. ".jpg"
       image.save(img_path, sample)      


       if opt.hflip == true then
         hflip_img(aug_path, tmp_img .. "crop" .. (j+(i-1)*number_img) .. ".jpg", aug_path)
       end

     end
   end

end


local image_names = paths.dir(opt.pathToFolder, 'r')
os.execute("mkdir -p " .. opt.pathToFolder .. "/augmentations")
local aug_path = opt.pathToFolder .. "/augmentations"

for i=1, #image_names do

  local tmp_img = image_names[i]
  if (string.sub(tmp_img, 1, 1) ~= '.' and tmp_img ~= 'augmentations') then
      if opt.ta > 0 then
         crop5_img(opt.pathToFolder, tmp_img, aug_path, opt.ta)
      elseif opt.hflip == true then
         hflip_img(opt.pathToFolder, tmp_img, aug_path)
      end

      if opt.ra > 0 then
         local angle = opt.ra/opt.rotationImg
         for i=1, opt.rotationImg do
             rotate_img(opt.pathToFolder, tmp_img, aug_path, angle*i)
          end
      end
  end
end


