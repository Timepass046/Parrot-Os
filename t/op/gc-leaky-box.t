#!./parrot --gc-min-threshold=100
# Copyright (C) 2010,2014, Parrot Foundation.

=head1 NAME

t/op/gc-leaky-box.t - test for memory leaks in the Garbage Collector

=head1 SYNOPSIS

    % prove t/op/gc-leaky-box.t

=head1 DESCRIPTION

Tests that we actually do a GC mark and sweep after a large number of PMC's have
been created. Test suggested by chromatic++ . Also includes tests for
TT1465 - http://trac.parrot.org/parrot/ticket/1465 .

=cut

# 20:57 <chromatic> For every million PMCs allocated, see that the GC has performed a mark/sweep.

.include 'interpinfo.pasm'

.sub _main :main
    .include 'test_more.pir'


    $S0 = interpinfo .INTERPINFO_GC_SYS_NAME
    if $S0 == "inf" goto dont_run_hanging_tests

    plan(3)
    test_gc_mark_sweep()

    goto test_end
  dont_run_hanging_tests:
    skip_all("Not relevant for this GC")
  test_end:
.end

.sub test_gc_mark_sweep
    .local int counter
    .local int cycles

    cycles  = 10
  cycle:

    counter = 0
  loop:
    $P0 = box "0"
    inc counter
    if counter < 1e7 goto loop

    $I1 = interpinfo.INTERPINFO_GC_COLLECT_RUNS
    if $I1 goto done

    dec cycles
    if cycles > 0 goto cycle

  done:
    $I2 = interpinfo.INTERPINFO_GC_MARK_RUNS
    $S0 = interpinfo .INTERPINFO_GC_SYS_NAME
    if $S0 == "gms" goto last_alloc

    $I3 = interpinfo.INTERPINFO_TOTAL_MEM_ALLOC
    goto test

  last_alloc:
    $I3 = interpinfo.INTERPINFO_MEM_ALLOCS_SINCE_COLLECT

  test:

    $S1 = $I1
    $S0 = "performed " . $S1
    $S0 .= " (which should be >=1) GC string collect runs"
    if $I1 goto collect_done
    $S0 = "#TODO " . $S0
    $S0 = $S0 . " (not entirely necessary)"
    ok($I1,$S0)
    goto mark
  collect_done:
    ok($I1,$S0)

  mark:
    $S1 = $I2
    $S0 = "performed " . $S1
    $S0 .= " (which should be >=1) GC mark runs"
    ok($I2,$S0)

    $S1 = $I3
    $S0 = "allocated " . $S1
    $S0 .= " (which should be <= 3_000_000) bytes of memory"
    $I4 = isle $I3, 3000000
    ok($I4,$S0)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
