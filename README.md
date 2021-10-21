# Stephanie-Walker-and-William-Idoine-2504-2021-PROJECT2

Student Names: Stephanie Walker, William Idoine

Assignment Title: Discrete Event Simulation

[Assignment Instructions](https://courses.smp.uq.edu.au/MATH2504/assessment_html/project2.html)

How to run:

Navigate to the file runscript.jl in the test folder. Then at the bottom of that file will be two variables named test_params and lambdas and a call to the function named run_script. To use this program, simply change test_params to any NetworkParameter object that you would like to test along with changing lambdas to be equal to an array of floats that you would like to test your selected test_params over. Next the run_script function takes in 5 arguments. The first one is an unnamed argument where you should pass the NetworkParameter object that you assigned to the variable test_params. The last four arguments of run_script are named arguments and are explained below.

**max_time**: The maximum amount of time that you would like the simulation to run over. (Inputted as a float64).

**lambda_range**: The lambdas that you would like to test test_params over. (Inputted as an array of float64s).

**mode**: The mode that you want the simulation to run in. Setting mode to be equal to 1 will make the simulation output the following two plots.

    The mean number of items in the total system as a function of λ.

    The proportion of jobs that are in orbit (circulating between nodes) as a function of λ.

Setting mode to be equal to 2 will make the simulation output the following plot.

    The empirical distribution of the sojourn time of a job through the system (varied as a function of λ).

**plot_num**: Edits the filenames of the saved simulation plots.

An example call of run_script is provided in runscript.jl, but is also shown below.

    run_script(test_params, max_time = 100000000.0, lambda_range = lambdas, mode=2, plot_num=1044)

With,

    test_params = NetworkParameters(  L=5,
                                    gamma_shape = 3.0,
                                    λ = NaN,
                                    η = 4.0,
                                    μ_vector = collect(5:-1:1),
                                    P = [0   0.5 0.5 0   0;
                                        0   0   0   1   0;
                                        0   0   0   0   1;
                                        0.5 0   0   0   0;
                                        0.2 0.2 0.2 0.2 0.2],
                                    Q = [0 0 0 0 0;
                                        1 0 0 0 0;
                                        1 0 0 0 0;
                                        1 0 0 0 0;
                                        1 0 0 0 0],
                                    p_e = AnalyticWeights([0.2, 0.2, 0, 0, 0.6]),
                                    K = [-1, -1, 10, 10, 10])

    lambdas = [i for i in 0.2:0.2:0.8]
