local utility = {}

function utility.printLoop(iterations)
	for i = 1, iterations do
		print('iteration: '..i)
	end
end

function utility.loopFunc(start, finish, step, func)
    if func == nil then
        func = step
        step = 1
    end

    for iteration = start, finish, step do
        func(iteration)
    end
end

return utility