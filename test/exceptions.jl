@testset "exceptions with messages" begin

    @test_throws WindowsOverflowsData("overflow")  throw(WindowOverflowsData("overflow"))
    @test_throws WindowsUnderflowsData("underflow") throw(WindowUnderflowsData("underflow"))

end
