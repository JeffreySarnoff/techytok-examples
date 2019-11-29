#%%
using BenchmarkTools
using Base.Threads
using Plots
using ProgressMeter
using ArrayFire
#%%
w_lr = 600
h_lr = 400

w_HD = 1920
h_HD = 1080

w_4k = 3840
h_4k = 2160

function mandelbrotBoundCheck(
    cr::T,
    ci::T,
    maxIter::Int = 1000,
) where {T<:AbstractFloat}
    zr = zero(T)
    zi = zero(T)
    zrsqr = zr^2
    zisqr = zi^2
    result = 0
    for i = 1:maxIter
        if zrsqr + zisqr > 4.0
            result = i
            break
        end
        zi = (zr + zi)^2 - zrsqr - zisqr
        zi += ci
        zr = zrsqr - zisqr + cr
        zrsqr = zr^2
        zisqr = zi^2
    end
    return result
end

function computeMandelbrot(
    xmin::Real = -2.2,
    xmax::Real = 0.8,
    ymin::Real = -1.2,
    ymax::Real = 1.2,
    width::Int = 800,
    height::Int = 600,
    maxIter::Int = 1000,
    zoom::Real = 1,
    verbose = true,
)
    if verbose
        p = Progress(width)
        update!(p, 0)
        jj = Threads.Atomic{Int}(0)
        l = Threads.SpinLock()
    end

    xc = (xmax + xmin) / 2
    yc = (ymax + ymin) / 2
    dx = (xmax - xmin) / width
    dy = (ymax - ymin) / height

    x_arr = zeros(typeof(xmin), width)
    y_arr = zeros(typeof(ymin), height)

    if zoom != 1 # redefine bounds according to zoom
        dx /= zoom
        dy /= zoom
        xmin = xc - dx * width / 2
        xmax = xc + dx * width / 2
        ymin = yc - dy * height / 2
        ymax = yc + dy * height / 2

        x_arr .= collect(range(xmin, stop = xmax, length = width))
        y_arr .= collect(range(ymin, stop = ymax, length = height))
    else
        x_arr .= collect(range(xmin, stop = xmax, length = width))
        y_arr .= collect(range(ymin, stop = ymax, length = height))
    end

    # x_arr = range(xmin, stop = xmax, length = width)
    # y_arr = range(ymin, stop = ymax, length = height)

    pixels = zeros(typeof(xmin), height, width) #pixels[y,x]

    @threads for x_j = 1:width
        @inbounds for y_i = 1:height
            pixels[y_i, x_j] = mandelbrotBoundCheck(
                x_arr[x_j],
                y_arr[y_i],
                maxIter,
            )
        end
        if verbose
            Threads.atomic_add!(jj, 1)
            Threads.lock(l)
            update!(p, jj[])
            Threads.unlock(l)
        end
    end
    return pixels
end
function displayMandelbrot(
    ;
    xmin::Real = -2.2,
    xmax::Real = 0.8,
    ymin::Real = -1.2,
    ymax::Real = 1.2,
    width::Int = 800,
    height::Int = 600,
    maxIter::Int = 1000,
    zoom::Real = 1,
    colormap = :magma,
    nRepeat::Int = 1,
    limitPaletteLength = false,
    scale = :linear,
    filename = :none,
    verbose = true,
)
    img = computeMandelbrot(
        xmin,
        xmax,
        ymin,
        ymax,
        width,
        height,
        maxIter,
        zoom,
        verbose,
    )
    # img .+= 1 # remove zeros
    if scale == :log
        img = log.(img) # normalize image to have nicer colors
    elseif scale == :exp
        img = exp.(img)
    elseif typeof(scale) <: Function
        img = scale.(img)
    end
    colorgrad = repeat_colorgrad(colormap, nRepeat, limitPaletteLength)
    res = heatmap(
        img,
        colorbar = :none,
        color = colorgrad,
        axis = false,
        size = (width, height),
        grid = false,
    )

    if filename != :none
        savefig(filename)
    end
    return res
end

function repeat_colorgrad(cmap, nRepeat::Int, limitPaletteLength = false)
    colorgrad = cgrad(cmap)
    color_array = repeat(colorgrad.colors, nRepeat)
    values_array = repeat(colorgrad.values, nRepeat)
    if limitPaletteLength
        return ColorGradient(
            color_array[1:nRepeat:length(color_array)],
            values_array[1:nRepeat:length(values_array)],
        )
    else
        return ColorGradient(color_array, values_array)
    end
end

#%%
cmap1 = :inferno
xmin1 = -1.744453831814658538530
xmax1 = -1.744449945239591698236
ymin1 = 0.022017835126305555133
ymax1 = 0.022020017997233506531

cmap2 = :ice
xmin2 = 0.308405876790033128474
xmax2 = 0.308405910247503605302
ymin2 = 0.025554220954294027410
ymax2 = 0.025554245987221578418

cmap3 = :fire
xmin3 = 0.307567454839614329536
xmax3 = 0.307567454903142214608
ymin3 = 0.023304267108419154581
ymax3 = 0.023304267156089095573

xmin3b = BigFloat("0.307567454839614329536")
xmax3b = BigFloat("0.307567454903142214608")
ymin3b = BigFloat("0.023304267108419154581")
ymax3b = BigFloat("0.023304267156089095573")

xmin4=0.2503006273651145643691
xmax4=0.2503006273651201870891
ymin4=0.0000077612880963380370
ymax4=0.0000077612881005550770

xmin4b=BigFloat("0.2503006273651145643691")
xmax4b=BigFloat("0.2503006273651201870891")
ymin4b=BigFloat("0.0000077612880963380370")
ymax4b=BigFloat("0.0000077612881005550770")



#%%

displayMandelbrot(
    xmin = xmin4b,
    xmax = xmax4b,
    ymin = ymin4b,
    ymax = ymax4b,
    width = w_lr,
    height = h_lr,
    colormap = :inferno,
    nRepeat = 4,
    limitPaletteLength = true,
    maxIter = 50000,
    verbose = true,
    scale = :log,
    filename = "mandelbrot-fractal/images/mandelbrot4.png",
)
