module IceCream

using Dates
using Base: @kwdef

struct FrameInfo
    file::String
    line::Int
    func::Symbol
    time::DateTime
    argnames::Tuple
    argvals::Tuple
end

function current_frame_info(args...)
    traces = stacktrace()
    for frame in traces
        #= for prop in propertynames(frame) =#
        #=     @info prop, getproperty(frame, prop) =#
        #= end =#
        if !hasproperty(frame.linfo, :code)
            continue
        end
        code = frame.linfo.code
        #= println(frame.linfo.code) =#
        for expr in code
            if expr isa Expr && expr.head == :call && first(expr.args) == :ic
                file = string(frame.file)
                line = frame.line
                func = frame.func
                argnames = Tuple(arg isa Union{Expr, Symbol} ? arg : nothing
                                 for arg in expr.args[2:end])
                return FrameInfo(file, line, func, now(), argnames, args)
            end
        end
    end
end
@kwdef struct IceCreamDebugger
    prefix::String = "ic| "
    time_format::String = "HH:MM:SS.ss"
    enabled::Bool = true
end

function format_kv(k, v)
    if string(k) == string(v)
        return string(k)
    else
        return "$(k): $(v)"
    end
end


function (ic::IceCreamDebugger)(frame::FrameInfo)
    nargs = length(frame.argnames)
    if nargs == 0
        file = basename(frame.file)
        line = frame.line
        func = frame.func
        timestr = Dates.format(frame.time, ic.time_format)
        @info "$(ic.prefix)$(file):$(line) in $(func) at $(timestr)"
    else
        argnames = frame.argnames
        argvals = frame.argvals
        buffer = IOBuffer()
        write(buffer, ic.prefix)
        pad = repeat(" ", length(ic.prefix))
        for (i, (name, val)) in enumerate(zip(argnames, argvals))
            write(buffer, i > 1 ? "\n\t" : "")
            write(buffer, i > 1 ? pad : "")
            write(buffer, "$(something(name, "(const)")):$(val)")
        end
        @info read(seekstart(buffer), String)
    end
end

function (ic::IceCreamDebugger)(args...)
    ic(current_frame_info(args...))
end

const ic = IceCreamDebugger()

export ic

end  # module IceCream
