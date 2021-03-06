"""
    fullonelevel

Compute the mesh topology structures that correspond to the full one-level
downward and upward adjacency graph. Memory is used to store the downward incidence
relations (3, 2), (2, 1), (1, 0), and the upward incidence relations (0, 1), (1,
2), and (2, 3) and the locations of the vertices.
"""
module fullonelevel
using StaticArrays
using MeshCore: nvertices, nshapes, manifdim, attribute
using MeshCore: ir_skeleton, ir_bbyfacets, ir_bbyridges, ir_transpose
using MeshSteward: vtkwrite, T4block
using BenchmarkTools
using Test

include("usedbytes.jl")

function test()
    ts = time()
    n = 3
    membytes = 0; summembytes = 0
    @info "Initial (3, 0)"
    @time connectivity = T4block(1.0, 2.0, 3.0, n*7, n*9, n*10, :a; intbytes = 4)
    ir30 = connectivity
    @show "($(manifdim(ir30.left)), $(manifdim(ir30.right)))"
    @show (nshapes(ir30.left), nshapes(ir30.right))
    @show membytes = usedbytes(ir30._v)
    geom = attribute(ir30.right, "geom")
    @show membytes = usedbytes(geom.v)
    summembytes += membytes
    @show time() - ts

    ts = time()
    @info "Skeleton: facets. (2, 0)"
    @time ir20 = ir_skeleton(ir30)
    @show "($(manifdim(ir20.left)), $(manifdim(ir20.right)))"
    @show (nshapes(ir20.left), nshapes(ir20.right))
    @show membytes = usedbytes(ir20._v)
    summembytes += membytes

    @info "Bounded-by facets. (3, 2)"
    @time ir32 = ir_bbyfacets(ir30, ir20)
    @show "($(manifdim(ir32.left)), $(manifdim(ir32.right)))"
    @show (nshapes(ir32.left), nshapes(ir32.right))
    @show membytes = usedbytes(ir32._v)
    summembytes += membytes

    @info "Skeleton: ridges. (1, 0)"
    @time ir10 = ir_skeleton(ir20)
    @show "($(manifdim(ir10.left)), $(manifdim(ir10.right)))"
    @show (nshapes(ir10.left), nshapes(ir10.right))
    @show membytes = usedbytes(ir10._v)
    summembytes += membytes

    @info "Bounded-by facets. (2, 1)"
    @time ir21 = ir_bbyfacets(ir20, ir10)
    @show "($(manifdim(ir21.left)), $(manifdim(ir21.right)))"
    @show (nshapes(ir21.left), nshapes(ir21.right))
    @show membytes = usedbytes(ir21._v)
    summembytes += membytes
    
    @info "Transpose. (0, 1)"
    @time tr01 = ir_transpose(ir10)
    @show "($(manifdim(tr01.left)), $(manifdim(tr01.right)))"
    @show (nshapes(tr01.left), nshapes(tr01.right))
    @show membytes = usedbytes(tr01._v)
    summembytes += membytes
    
    @info "Transpose. (1, 2)"
    @time tr12 = ir_transpose(ir21)
    @show "($(manifdim(tr12.left)), $(manifdim(tr12.right)))"
    @show (nshapes(tr12.left), nshapes(tr12.right))
    @show membytes = usedbytes(tr12._v)
    summembytes += membytes
    
    @info "Transpose. (2, 3)"
    @time tr23 = ir_transpose(ir32)
    @show "($(manifdim(tr23.left)), $(manifdim(tr23.right)))"
    @show (nshapes(tr23.left), nshapes(tr23.right))
    @show membytes = usedbytes(tr23._v)
    summembytes += membytes
    
    # Print the total number of megabytes used to store the database
    @show summembytes/2^20
    @show time() - ts

    # vtkwrite("speedtest1", connectivity)
    true
end
end
using .fullonelevel
# using BenchmarkTools
# @btime fullonelevel.test()
fullonelevel.test()
