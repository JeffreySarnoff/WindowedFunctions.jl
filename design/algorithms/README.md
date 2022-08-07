Smoothing data with Julia’s @generated functions

One of Julia’s great strengths for technical computing is its metaprogramming features, which allow users to write collections of related code with minimal repetition. One such feature is generated functions, a feature recently implemented in Julia 0.4 that allows users to write customized compute kernels at “compile time”.

Another use case for generated functions

Section 5.7 of Jeff Bezanson’s thesis mentions an application of generated functions to boundary element method (BEM) computations, as described and implemented by Steven G. Johnson. These computations construct a Galerkin discretization of an integral equation, but the discretization process must take into account characteristics of the underlying integral kernel such as its singularities (pole structure) and the range of interactions, which in turn determine suitable choices of numerical integration (cubature) schemes. The Julia implementation uses Julia types to encode the essential features of the integral kernel in two type parameters that control the dispatch of cubature scheme, and is an elegant solution to what would otherwise be a tedious exercise in specialized code generation. Nonetheless, the BEM example may be difficult to follow for readers who are not familiar with the challenges of solving integral equations numerically. Instead, this post describes another application of generated functions to the smoothing of noisy data, which may be easier to understand.

Smoothing data using a Savitzky-Golay filter

Generated functions can be used to construct a collection of filters to clean up data. One such filter was developed by Savitzky and Golay in the context of cleaning up spectroscopic signals in analytical chemistry. The filtering method invented by Savitzky and Golay relies on least squares polynomial interpolation (of degree N) within a local moving window (of size 2M+1). An important property which makes the Savitzky-Golay method so incredibly useful in practice is that it preserves the low moments of the data, and thus the smoothening process preserves essential features of the peak structure in the data.

Given a degree N for the desired interpolating polynomial and a window size 2M+1, Savitzky and Golay derived a system of equations that governs the choice of optimal interpolation coefficients, which depend on M and N but not on the actual input data to be smoothened. In practice, the choice of parameters M and N are fixed (or scanned over a small range) and then applied to a large data vector. Hence, it would be ideal to generate specialized code for a particular choice of M and N, which can be applied quickly and efficiently. The problem, of course, is that we don’t know a priori which M and N a user wants. In a static language we would have no choice but to specify at compile time the allowed values of the parameters. However, Julia’s generated functions allow us to generate specialized methods when the filter is first applied to the data, without needing to compile all possible methods corresponding to all possible combinations of type parameters.


Implementation of Savitzky-Golay filters in Julia using generated functions.
What this code do?

Unlike ordinary Julia functions, which return an ordinary value, generated functions return a quoted expression, which is then constructed and evaluated when when Julia’s dispatch mechanism decides to use this particular method family. In this generated function, the code for the function body undergoes delayed evaluation, and is first captured in expr while being manipulated. The actual interpolation coefficients C are not computed until the generated function is first called. In effect, generated functions allow us to customize how code is generated for Julia’s multimethod system. This example takes advantage of custom code generation in several ways:

The generated function does some linear algebra to determine what values to insert into the desired method body, first calculating the interpolation coefficients C from M and N by constructing J, the Jacobian (a.k.a. design matrix) of the filter, and then extracting the first row of its pseudoinverse by doing a least-squares solve on the canonical basis vector e1. The interpolation coefficients are then spliced into the generated expression using the $(C[k]) dollar-sign syntax for expression interpolation.
2M conditional additions are also inserted into the abstract syntax tree in expr before the function body gets compiled. M determines the number of terms in the interpolating expression, and at the end points the expression must be truncated to avoid going out of bounds when indexing into the data. (expr.args[6].args[2].args[2] is the particular tree traversal that gets us to the appropriate place to insert new leaf nodes into the AST.)

Some simple type arithmetic is needed to determine To, the element type of the output vector. Not all input vectors have element types that are closed under the interpolation process, which require taking linear combinations with floating point coefficients. (The Savitzky-Golay coefficients are actually rational, but proving this to be true remains elusive…) Since the output type can be determined when the generated function is called, there is no need to do the type computation at run time; instead, it can be hoisted into the generated function as part of the code generation process.

Call overloading
This implementation of the Savitzky-Golay filter also makes use of call overloading, yet another feature introduced in Julia 0.4. Defining a new method for call() allows users to apply the SavitzkyGolayFilter type just like an ordinary function, by defining its constructor to perform the filtering. In fact, this snippet defines a family of new call methods, parametrized by the window halfwidth M, the polynomial degree N of the interpolant, and the element type of the data vector. The type parameters thus allow us to minimize repetition, while generating specialized code for each filter as it is called for a particular combination of type parameters.

Inspecting exprs as they are constructed
Putting an appropriate @show annotation on the returned expr allows us to see that the methods are indeed generated on demand, when the specific method associated with the appropriate run time values of M, N and T are invoked:

expr = quote # /Users/jiahao/savitzkygolay.jl, line 28:
    n = size(data,1) # /Users/jiahao/savitzkygolay.jl, line 29:
    smoothed = zeros(Float64,n) # /Users/jiahao/savitzkygolay.jl, line 30:
    @inbounds for i = eachindex(smoothed)

            if i — 2 ≥ 1 # /Users/jiahao/savitzkygolay.jl, line 39:
                smoothed[i] += -0.08571428571428567 * data[i — 2]
            end

            if i — 1 ≥ 1 # /Users/jiahao/savitzkygolay.jl, line 39:
                smoothed[i] += 0.34285714285714275 * data[i — 1]
            end # /Users/jiahao/savitzkygolay.jl, line 31:

            smoothed[i] += 0.4857142857142856 * data[i]
            if i + 1 ≤ n # /Users/jiahao/savitzkygolay.jl, line 44:
                smoothed[i] += 0.3428571428571427 * data[i + 1]
            end
            
            if i + 2 ≤ n # /Users/jiahao/savitzkygolay.jl, line 44:
                smoothed[i] += -0.08571428571428563 * data[i + 2]
            end
    end # /Users/jiahao/savitzkygolay.jl, line 33:
    smoothed
end

SavitzskyGolayFilter{2,3}([1:11]) = [0.9142857142857141,1.9999999999999996,3.0,3.9999999999999987,4.999999999999998,5.999999999999998,6.999999999999998,7.999999999999998,8.999999999999998,11.028571428571425,7.999999999999998]

expr = quote # /Users/jiahao/savitzkygolay.jl, line 28:
    n = size(data,1) # /Users/jiahao/savitzkygolay.jl, line 29:
    smoothed = zeros(Float64,n) # /Users/jiahao/savitzkygolay.jl, line 30:

    @inbounds for i = eachindex(smoothed)
            if i — 1 ≥ 1 # /Users/jiahao/savitzkygolay.jl, line 39:
                smoothed[i] += 0.3333333333333332 * data[i — 1]
            end # /Users/jiahao/savitzkygolay.jl, line 31:
            smoothed[i] += 0.3333333333333333 * data[i]
            if i + 1 ≤ n # /Users/jiahao/savitzkygolay.jl, line 44:
                smoothed[i] += 0.3333333333333334 * data[i + 1]
            end
    end # /Users/jiahao/savitzkygolay.jl, line 33:
    smoothed
end
SavitzskyGolayFilter{1,1}([1:11]) = [1.0000000000000002,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,6.999999999999998]
Astute readers will notice that:

The filter reasonably reproduces the original [1:11;] data set with reasonable fidelity, except at the very end where it starts to clamp the data. This is a well known limitation of polynomial interpolation that results from truncation — there simply aren’t enough data points at the end points for a reliable interpolation using the same polynomial used for the bulk. A proper treatment of the end points is needed.
SavitzskyGolayFilter{M,1} reduces to a simple moving average. Thus one interpretation of the Savitzsky-Golay filter is that it generalizes the moving average to also preserve higher moments other than just the mean.

Similar constructs in other languages
In the beginning, I wrote that generated functions allow for “compile time” code manipulations. Strictly speaking, the term “compile time” is meaningless for a dynamic language like Julia, which by definition has no static semantics. In practice, however, Julia’s just-in-time compiler provides such a “compile time” stage which allows for delayed evaluation and manipulation of code. (See Jeff’s JuliaCon 2014 presentation where he goes through the various stages of code transformations that happen in Julia.) Put another way, generated functions cannot be explained with the usual compile/run model for evaluating code, but rather should be thought of as having an additional intermediate stage immediately prior run time where the code is not yet executed and the programmer is allowed to manipulate the code.

Multistaged programming (MSP)
Julia’s generated functions are closely related to the multistaged programming (MSP) paradigm popularized by Taha and Sheard, which generalizes the compile time/run time stages of program execution by allowing for multiple stages of delayed code execution. Having at least one intermediate stage where code manipulations can take place before run time facilitates the writing of custom program generators and helps reduce the run time cost of abstraction. However, MSP cannot be retrofitted onto an existing language that does not support the requisite features for AST manipulation, symbol renaming (gensym) and code reflection. As a result, MSP usually requires a second language to describe the necessary annotations of code generation stages. The literature contains many examples of two-language systems such as MetaML/ML, MetaOCaML/OCaML, and Terra/Lua. Similar tandem systems have been used for scientific computing purposes, such as the C code generator written in OCaML used to generate the FFTW3 library. In contrast, Julia’s generated functions provide built-in program generation without the need to reason about the intermediate stage in a different language, and is therefore closer to Rompf and Odersky’s lightweight modular staging approach for Delite, which is implemented entirely using Scala’s type system and requires no additional syntax.

Parameteric polymorphism of method families
The use of type parameters here allows us to express an entire family of related computations (differing only in input data type and degree of polynomial filter) using parametrically polymorphic generic functions. Similar constructs for parametric polymorphism exist in other languages also, such as C++ expression templates with overloaded operators, Haskell typeclasses, as well as related language constructs in Typed Racket, Fortress, and Dylan.

However, I don’t think that the theoretical basis for parametric polymorphism in Julia is well understood. Parametric polymorphism is conventionally described in programming language theory using existentially quantified kinds in a Hindley-Milner type system, along the lines of Cardelli and Wegner. Expressing parametric polymorphism in a static language construct (such as in C++ expression templates) becomes tedious in practice, because the compiler must either do whole program analysis to determine which methods are actually used by the user’s program, or in the absence of such information exhaustively generate all allowed methods. The result is long compile times, since program analysis is expensive and the number of possible methods grows combinatorially. However, in practice a user may use just a very few of the possibilities, or may even want a parameter combination that was not accounted for at compile time, or may want to write a program where the choice of parameters is only known at run time. Julia sidesteps this generation problem by registering the existence of these methods in the function’s method table, but compiles the method bodies only on demand, usually when function dispatch resolves to that specific method.

Since Julia allows for defining new methods at any point in program execution, existential quantification of parametric polymorphism, if it exists in Julia, must be thought of in a run time sense. Furthermore, it’s unclear if Julia’s type system, as formulated in terms of data flow analysis over type lattices, is even relatable to the ML-style Hindley-Milner type system. Furthermore, the Fortress development team have found that the formal type theory of parametrically polymorphic generic functions can get fantastically complex. Some recent work on the theory of polymorphic functions over set theoretic types by Castagna and coworkers [1] [2] seems like a closer match to what Julia has, and is worth further scrutiny from a PL-theoretic perspective.

