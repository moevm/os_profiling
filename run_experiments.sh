#!/bin/bash

set -e

show_help() {
    echo "Usage: $0 <experiment_name> [options] [speeding_num_runs]"
    echo
    echo "Options:"
    echo "  -h, --help    Show this help message and exit"
    echo "  -c, --confirm  Set if you are sure that you have configured the config file for the main experiment"
    echo "  -p, --patches  Set if you want apply patches"
    echo
    echo
    echo "There are four implemented experiments: "
    echo "   1. Main experiment. Name -- main"
    echo "       Usage: ./run_experiments.sh main"
    echo
    echo "   2. Experiment with filtering non-working servers. Name -- filters"
    echo "       Usage: ./run_experiments.sh filters"
    echo
    echo "   3. Experiment with speeding up building via net and priority patches. Name -- speeding_up"
    echo "       Usage: ./run_experiments.sh speeding_up [speeding_num_runs]"
    echo
    echo "   4. Experiment with profiling. Name -- profiling"
    echo "       Usage: ./run_experiments.sh profiling"
    echo
    exit 0
}

PATH_TO_MAIN_EXP=./src/experiment
PATH_TO_FILTERS_EXP=./src/experiment_2
PATH_TO_SPEEDING_EXP=./src/common/scripts
PATH_TO_PROFILING_EXP=./NONE
speeding_num_runs=50

if [ "$#" -lt 1 ]; then
    echo "Error: Experiment name is required."
    show_help
fi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -c|--confirm)
            FLAG=true
            shift
            ;;
        -p|--patches)
            PATCHES_FLAG=true
            shift
            ;;
        *)
            if [ -z "$EXPERIMENT_NAME" ]; then
                EXPERIMENT_NAME=$1
            else
                if [ "$EXPERIMENT_NAME" == "speeding_up" ]; then
                    speeding_num_runs=$1
                else
                    echo "Error: Unknown argument '$1'"
                    show_help
                fi
            fi
            shift
            ;;
    esac
done

if [ -z "$EXPERIMENT_NAME" ]; then
    echo "Error: Experiment name is required."
    show_help
fi

if [ "$FLAG" == true ]; then
    echo "Using flag of confirm config"
else
    echo "Flag is not set to confirm config"
    echo

    if [ "$EXPERIMENT_NAME" == "main" ]; then
        echo "To start main experiment you need to fill configuration of experiment described in ./src/experiment/README.md"
        echo "  After filling out the config, run this script via --confirm flag"
        echo "    Usage: ./run_experiments.sh main -c"
        echo "  or"
        echo "    Usage: ./run_experiments.sh main --confirm"
        exit 1
    fi

    if [ "$EXPERIMENT_NAME" == "filters" ]; then
        echo "To start filters experiment you need to fill configuration of experiment described in ./src/experiment_2/README.md"
        echo "  After filling out the config, run this script via --confirm flag"
        echo "    Usage: ./run_experiments.sh filters -c"
        echo "  or"
        echo "    Usage: ./run_experiments.sh filters --confirm"
        exit 1
    fi

    if [ "$EXPERIMENT_NAME" == "speeding_up" ]; then
        echo "To start speeding_up experiment you do not need to fill in the configurations, you only need to specify the number of repetitions."
        echo "  To confirm the number of repetitions, run this script via --confirm flag"
        echo "    Usage: ./run_experiments.sh speeding_up -c"
        echo "  or"
        echo "    Usage: ./run_experiments.sh speeding_up --confirm"
        exit 1
    fi

    if [ "$EXPERIMENT_NAME" == "profiling" ]; then
        echo "To start profiling experiment you need to fill configuration of experiment described in <paste_config_path_or_instruction_path>"
        echo "  After filling out the config, run this script via --confirm flag"
        echo "    Usage: ./run_experiments.sh profiling -c"
        echo "  or"
        echo "    Usage: ./run_experiments.sh profiling --confirm"
        exit 1
    fi
fi


if [ "$EXPERIMENT_NAME" == "main" ]; then
    cd $PATH_TO_MAIN_EXP
    echo "starting"
    if [ "$PATCHES_FLAG" == true ]; then
        echo "Running with --patches"
        ./main.sh --patches
    else
        echo "Running without --patches"
        ./main.sh
    fi
    exit 0
fi

if [ "$EXPERIMENT_NAME" == "filters" ]; then
    cd $PATH_TO_FILTERS_EXP
    echo "starting"
    if [ "$PATCHES_FLAG" == true ]; then
        echo "Warning! filters does not require the --patches flag!"
        ./run.sh 
    else
        echo "Running without --patches"
        ./run.sh
    fi
    exit 0
fi

if [ "$EXPERIMENT_NAME" == "speeding_up" ]; then
    cd $PATH_TO_SPEEDING_EXP
    echo "starting"
    if [ "$PATCHES_FLAG" == true ]; then
        echo "Running with --patches"
        ./speeding_up_experiment.sh "$speeding_num_runs" --patches
    else
        echo "Running without --patches"
        ./speeding_up_experiment.sh "$speeding_num_runs"
    fi
    exit 0
fi

if [ "$EXPERIMENT_NAME" == "profiling" ]; then
    cd $PATH_TO_PROFILING_EXP
    echo "starting"
    # here gotta be start of profiling experiment
    if [ "$PATCHES_FLAG" == true ]; then
        echo "Running with --patches"
        # $PATH_TO_PROFILING_EXP/profiling_experiment.sh --patches
    else
        echo "Running without --patches"
        # $PATH_TO_PROFILING_EXP/profiling_experiment.sh
    fi
    exit 0
fi
