-- require("image")
-- require("nn")

-- performs one epoch and updates weights
function train(network, criterion, input, ideal)
    local err = 0

    for i = 1, #input do
        -- feed it to the neural network and the criterion
        prediction = network:forward(input[i])
        
        err = err + criterion:forward(prediction, ideal[i])

        -- (1) zero the accumulation of the gradients
        network:zeroGradParameters()

        -- (2) accumulate gradients
        criterion_gradient = criterion:backward(prediction, ideal[i])
        network:backward(input[i], criterion_gradient)

        -- (3) update parameters with a 0.01 learning rate
        network:updateParameters(0.01)
    end

    return err/#input
end

function predict(network, sample)
    local out = network:forward(sample)
    if out[1] > 0 then
        return 1
    else 
        return -1
    end
end


----------------------------------------------------------------------------
-- Main
----------------------------------------------------------------------------

torch.setdefaulttensortype('torch.DoubleTensor')

params = {
    inputs = 2,
    outputs = 1,
    hiddenUnits = 3,
    opts = {},
}

datapoints = {
    torch.DoubleTensor({-1, 1}),
    torch.DoubleTensor({-1, -1}),
    torch.DoubleTensor({1, -1}),
    torch.DoubleTensor({1, 1})
}

ideal = {
    torch.DoubleTensor({1}),
    torch.DoubleTensor({-1}),
    torch.DoubleTensor({1}),
    torch.DoubleTensor({-1}),
}

-- Dataset object to be used with nn.StochasticGradient(..) 
dataset = {}
function dataset:size() return 4 end
for i = 1, dataset:size() do    
    dataset[i] = {datapoints[i], ideal[i]} 
end 



-- print("Train phase -----------------------------")
-- -- require("nn")
-- -- Design network
-- -- for k,v in pairs(_G) do print(k) end
-- for k,v in pairs(nn) do print("asdf") end

-- mlp = nn.Sequential();
-- mlp:add(nn.Linear(params.inputs, params.hiddenUnits))
-- mlp:add(nn.Tanh())
-- mlp:add(nn.Linear(params.hiddenUnits, params.outputs))


net = getAppPath() .. "/res/newnet"

print("loading network: " .. net)
mlp = torch.load(net, "ascii")
print(type(mlp))



-- if params.opts.stochastic then
--     criterion = nn.MSECriterion()  
--     trainer = nn.StochasticGradient(mlp, criterion)
    
--     -- interesting options 
--     trainer.learningRate = 0.01
--     trainer.maxIteration = 300
--     trainer.shuffleIndices = false
--     trainer:train(dataset)
-- else
    -- criterion = nn.MSECriterion()
    -- for i = 1, 1000 do 
    --     err = train(mlp, criterion, datapoints, ideal)
    --     if (err < 0.01) then
    --         print("Reached target error: " .. err .. " on epoch: " .. i)
    --         torch.save("newnet", mlp, "ascii")
    --         break
    --     end
    -- end
-- end

print("Test phase ------------------------------")


print("(1,1)\t -> " .. predict(mlp, torch.DoubleTensor({1,1})) .. "\t should be: -1")
print("(-1,-1)\t -> " .. predict(mlp, torch.DoubleTensor({-1,-1})) .. "\t should be: -1")
print("(1,-1)\t -> " .. predict(mlp, torch.DoubleTensor({1,-1})) .. "\t should be: 1")
print("(-1,1)\t -> " .. predict(mlp, torch.DoubleTensor({-1,1})) .. "\t should be: 1")
print("done.")





