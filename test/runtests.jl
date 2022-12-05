using IceCream: current_frame_info, ic
using Test

function check_frame(frame, lineno, args=nothing)
    if frame.file != @__FILE__
        return false
    end
    if frame.line != lineno
        return false
    end
    if isnothing(args)
        return true
    end

    return args == frame.args
end


const x = 1
const y = 2

function test()
    ic()
    ic(1)
    ic(123)
    ic(1, 2)
    ic(x)
    ic(x, y)
    ic(rand(-3:3, 3))
    ic(sum(rand(rand(-3:9, 3))))
    ic(rand(-3:3, 3), rand(-3:3, 4))
end

ic()
ic(1)
ic(123)
ic(1, 2)
ic(x)
ic(x, y)
ic(rand(-3:3, 3))
ic(sum(rand(rand(-3:9, 3))))
ic(rand(-3:3, 3), rand(-3:3, 4))
test()
