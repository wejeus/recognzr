

-- print("\nCalling t = torch.FloatTensor(10) .....................")
-- t = torch.FloatTensor(10)
-- print("\nCalling print(t) ......................................")
-- print(t)

-- print("\nCalling for k,v in pairs(_G) do print(k) end ..........")
-- print("\nLoaded packages (_G) ..........")
-- for k,v in pairs(_G) do print(k) end

-- print("\nCalling print(package.path) ...........................")
-- print(package.path)

-- print("\nCalling for k,v in pairs(torch) do print(k) end ..........")
-- for k,v in pairs(torch) do print(k) end

-- package.loaded._G.torch.setdefaulttensortype('torch.FloatTensor')
-- asdf = package.loaded._G.torch.eye(1)

print("default Tensor type: " .. torch.getdefaulttensortype())
-- datapoints = {
--    -- package.loaded._G.torch.Tensor({-1, 1})
--    torch.FloatTensor({-1, -1}),
--    torch.FloatTensor({1, -1}),
--    torch.FloatTensor({1, 1})
-- }
-- print(datapoints)

-- require("nn")
print("\n--------------------------------------------")
for k,v in pairs(torch) do print(k) end








-- -- performs one epoch and updates weights
-- function train(network, criterion, input, ideal)
--     local err = 0

--     for i = 1, #input do
--         -- feed it to the neural network and the criterion
--         prediction = network:forward(input[i])
        
--         err = err + criterion:forward(prediction, ideal[i])

--         -- (1) zero the accumulation of the gradients
--         network:zeroGradParameters()

--         -- (2) accumulate gradients
--         criterion_gradient = criterion:backward(prediction, ideal[i])
--         network:backward(input[i], criterion_gradient)

--         -- (3) update parameters with a 0.01 learning rate
--         network:updateParameters(0.01)
--     end

--     return err/#input
-- end

-- function predict(network, sample)
--     local out = network:forward(sample)
--     if out[1] > 0 then
--         return 1
--     else 
--         return -1
--     end
-- end


-- ----------------------------------------------------------------------------
-- -- Main
-- ----------------------------------------------------------------------------


-- params = {
--     inputs = 2,
--     outputs = 1,
--     hiddenUnits = 3,
--     opts = {},
-- }

-- datapoints = {
--     torch.Tensor({-1, 1}),
--     torch.Tensor({-1, -1}),
--     torch.Tensor({1, -1}),
--     torch.Tensor({1, 1})
-- }

-- ideal = {
--     torch.Tensor({1}),
--     torch.Tensor({-1}),
--     torch.Tensor({1}),
--     torch.Tensor({-1}),
-- }

-- -- Dataset object to be used with nn.StochasticGradient(..) 
-- dataset = {}
-- function dataset:size() return 4 end
-- for i = 1, dataset:size() do    
--     dataset[i] = {datapoints[i], ideal[i]} 
-- end 


-- print("Test phase ------------------------------")

-- local mlp = torch.load("xor.neuralnetwork")

-- print("(1,1)\t -> " .. predict(mlp, torch.Tensor({1,1})) .. "\t should be: -1")
-- print("(-1,-1)\t -> " .. predict(mlp, torch.Tensor({-1,-1})) .. "\t should be: -1")
-- print("(1,-1)\t -> " .. predict(mlp, torch.Tensor({1,-1})) .. "\t should be: 1")
-- print("(-1,1)\t -> " .. predict(mlp, torch.Tensor({-1,1})) .. "\t should be: 1")
-- print("done.")





