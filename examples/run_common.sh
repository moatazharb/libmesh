#!/bin/bash

# Write pretty status message
message_running() {
    example_name=$1
    shift
    executable=$1
    shift
    options=$@

    echo "***************************************************************"
    echo "* Running Example $example_name:"
    echo "*  $LIBMESH_RUN ./$executable $options $LIBMESH_OPTIONS"
    echo "***************************************************************"
    echo " "
}

# Write pretty status message
message_done_running() {

    example_name=$1
    shift
    executable=$1
    shift
    options=$@

    echo " "
    echo "***************************************************************"
    echo "* Done Running Example $example_name:"
    echo "*  $LIBMESH_RUN ./$executable $options $LIBMESH_OPTIONS"
    echo "***************************************************************"
}

run_example() {
    # when benchmarking we only run specific benchmark examples
    if (test "x${LIBMESH_BENCHMARK}" != "x"); then
      return
    fi

    example_name=$1
    shift
    options=$@

    # when run outside of the automake environment make sure we get METHODS set
    # to something useful
    if (test "x${METHODS}" = "x"); then
	if (test "x${METHOD}" = "x"); then
	    METHODS=opt
	else
	    METHODS="$METHOD"
	fi
    fi

    # Run executables from most-debugging-enabled to least-, so if
    # there's a failure we get the most informative death possible
    ORDERED_METHODS="dbg debug devel profiling pro prof oprofile oprof optimized opt"
    MY_METHODS=""
    for method in ${ORDERED_METHODS}; do
        for mymethod in ${METHODS}; do
            if (test "x${mymethod}" = "x${method}"); then
                MY_METHODS="${MY_METHODS} ${mymethod}"
            fi
        done
    done

    for method in ${MY_METHODS}; do
	
	case "${method}" in
	    optimized|opt)      executable=example-opt   ;;
	    debug|dbg)          executable=example-dbg   ;;
	    devel)              executable=example-devel ;;
	    profiling|pro|prof) executable=example-prof  ;;
	    oprofile|oprof)     executable=example-oprof ;;
	    *) echo "ERROR: unknown method: ${method}!" ; exit 1 ;;
	esac

	if (test ! -x ${executable}); then
	    echo "ERROR: cannot find ${executable}!"
	    exit 1
	fi
	
	message_running $example_name $executable $options

	$LIBMESH_RUN ./$executable $options $LIBMESH_OPTIONS
        RETVAL=$?
        # If we don't return 'success' or 'skip', quit
        if [ $RETVAL -ne 0 -a $RETVAL -ne 77 ]; then
          exit $RETVAL
        fi
	
	message_done_running $example_name $executable $options
    done
}

run_example_no_extra_options() {
  LIBMESH_OPTIONS='' run_example $@
}


benchmark_example() {
    benchmark_level=$1
    shift
    example_name=$1
    shift
    options=$@

    # when benchmarking we only run specific benchmark examples
    if (test "x${LIBMESH_BENCHMARK}" = "x"); then
      return
    fi

    if (test ${LIBMESH_BENCHMARK} -lt ${benchmark_level}); then
      return
    fi

    if (test "x${METHOD}" = "x"); then
        METHOD=opt
    fi

    executable=example-${METHOD}

    if (test ! -x ${executable}); then
        echo "ERROR: cannot find ${executable}!"
        exit 1
    fi

    message_running $example_name $executable $options

    $LIBMESH_RUN ./$executable $options $LIBMESH_OPTIONS
    RETVAL=$?
    # If we don't return 'success' or 'skip', quit
    if [ $RETVAL -ne 0 -a $RETVAL -ne 77 ]; then
      exit $RETVAL
    fi

    message_done_running $example_name $executable $options
}
