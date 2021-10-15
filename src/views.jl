"""
Writes the 3 plots needed for the project.
"""
function scenario_plots(processed_sojurn_times, mean_system_job_totals, proportion_orbiting_jobs, scenario_number::Int64, lambda_range::Array{Float64})
    println("Plotting data...")

    PyPlot.hist(processed_sojurn_times, bins = [i for i in 0:0.5:maximum([maximum(i) for i in processed_sojurn_times])+0.5])
    PyPlot.yscale("log")
    PyPlot.legend(["λ = $i" for i in lambda_range])
    PyPlot.title("Empirical Distribution of Sojurn Times For Scenario $scenario_number\n")
    PyPlot.xlabel("Recorded Sojurn Times (Seconds)")
    PyPlot.ylabel("Frequency")
    PyPlot.savefig("histogram_scenario_$scenario_number.png")
    PyPlot.close()

    PyPlot.scatter(lambda_range, mean_system_job_totals)
    PyPlot.xticks(lambda_range)
    PyPlot.title("Mean Number of Items in the Total System for Scenario $scenario_number\n")
    PyPlot.xlabel("λ")
    PyPlot.ylabel("Mean Items in System")
    PyPlot.savefig("mean_items_scenario_$scenario_number.png")
    PyPlot.close()

    PyPlot.plot(lambda_range, proportion_orbiting_jobs)
    PyPlot.xticks(lambda_range)
    PyPlot.title("Proportion of Jobs in Orbit at T=10e^7 for Scenario $scenario_number\n")
    PyPlot.xlabel("λ")
    PyPlot.ylabel("Jobs in Orbit / Total Jobs in System")
    PyPlot.savefig("proportion_orbiting_jobs_scenario_$scenario_number.png")
    PyPlot.close()
end