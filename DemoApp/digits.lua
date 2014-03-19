
-- require("nn")
-- require("image")

-- Converts an integer (allowed range 0-9) to a corresponding binary vector of length 10 
-- integer 0 corresponds to high binary impuls on index 1
function labelToOutputVector(label) 
    local tensor = torch.Tensor(10):fill(-1)
    tensor[label+1] = 1
    return tensor
end

function getLabelFromNetworkOutput(output) 
    local impulse = -math.huge
    local index = 0
    for i = 1, 10 do
        if output[i] > impulse then
            impulse = output[i]
            index = i
        end
    end

    -- digit 0 is represented by index 1 and going upwards for rest
    return index - 1
end

function predict(sample)
    local output = network:forward(sample)
    local predictedLabel = getLabelFromNetworkOutput(output)
    return predictedLabel
end

-- Rounds -number- to desired -precision-
function round(number, precision)
  local mult = 10^(precision or 0)
  return math.floor(number * mult + 0.5) / mult
end

function formatEpochIDName(number)
    if number < 10 then return "00" .. number
    elseif number < 100 then return "0" .. number
    else return number end
end

function threshold(image) 
    for i = 1,32 do
        for j = 1,32 do
            if image[1][i][j] == 1.0 then
                image[1][i][j] = 0.0
            else
                if image[1][i][j] < 0.7 then
                    image[1][i][j] = 255
                end
            end
        end
    end
end

-- function test(path)
--     networkURI = "res/mnist_ascii.neuralnetwork"
--     print("Loading network: " .. networkURI)
--     network = torch.load(networkURI, "ascii")
--     print("Testing " .. path .. "..")
--     local sample = image.loadPNG(path)
    
--     sample = image.rgb2y(sample)
--     threshold(sample)
--     -- image.display(sample)
--     print(sample)
--     print(predict(sample))
-- end


-- TODO: Change to following struct (allso need change of C code to push multidimensional table instead.)
-- torch.Tensor(table)
-- The argument is assumed to be a Lua array of numbers. The constructor returns a new Tensor of the size of the table, containing all the table elements. The table might be multi-dimensional.

-- Example:

-- > = torch.Tensor({{1,2,3,4}, {5,6,7,8}})
--  1  2  3  4
--  5  6  7  8
-- [torch.DoubleTensor of dimension 2x4]
function classify(binaryImage)
    t = torch.Tensor(1, 32, 32)
    t2 = t:storage()
    x = 1
    for i = 1, 1024 do
        t2[x] = binaryImage[x]
        x = x + 1
    end

    -- threshold(t) -- really needed?
    -- print(t)
    return predict(t)
end

function getAllData(binaryImage)
    t = torch.Tensor(1, 32, 32)
    t2 = t:storage()
    x = 1
    for i = 1, 1024 do
        t2[x] = binaryImage[x]
        x = x + 1
    end

    local output = network:forward(t)

    debug_output = {}

    for i = 1, 10 do
        debug_output[i] = output[i]
    end
    -- print(output)
    return 1
end

-- Have to set manually on Torch iOS
torch.setdefaulttensortype('torch.FloatTensor')

-- Prepare
networkURI = getAppPath() .. "/res/mnist_ascii.neuralnetwork"
print("Loading nearual network: " .. networkURI)
network = torch.load(networkURI, "ascii")
