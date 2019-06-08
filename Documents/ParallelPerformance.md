Parallel performance issue in Haskell program
====

## Background

I've tried parallel programming many times, but I couldn't get better performance comparing with a single-threaded program in every case.

In my new project, I tried parallel programming again. And, I get worse performance with a parallel one more time.

## Situation

In this time, I made an interpreter about the very simple script.
(I designed this for more complex script and interpreter.)
With this program, I want to figure out the efficiency of a new structure of script and interpreter.

However, when I tried parallel interpreting, I get worse performance again.

## Design

* Do not use common load function **Fibonacci**, but use multiplying iteration by script
  * I have no confidence with Fibonacci calculation independency between threads

## Conditions

* Compiled with `--threaded` even for the serial interpreter
* Provided serial interpreter(`single`) and parallel interpreter(`async`)
* Comparing with RTS core number option `-N?` options like `-N1`, `-N2`, `-N4`, etc

## Measuring

I subtract `evalScript` executing time from total executing time.
I measure elapsed time 256 times.
I get numbers from RTS `-s` option.

## Result

* Ratio
  * With `-N1`
    * Async/Single: 1.06
  * With `-N2`
    * Async/Single: 0.95
  * With `-N4`
    * Async/Single: 0.89
  * With `-N8`
    * Async/Single: 0.67
* Time
  * With `-N1`
    * Single: 1.42
    * Async:  1.48
  * With `-N2`
    * Single: 1.55
    * Async:  1.50
  * With `-N4`
    * Single: 1.67
    * Async:  1.53
  * With `-N8`
    * Single: 2.09
    * Async:  1.56

## Expected

* With the serial interpreter, it shows almost same performance independent with assigned core number
* With the parallel interpreter, it shows higher performance when assigning more core
* With the completely independent process, parallel interpreter version is faster than serial version

## Actual

* Even serial interpreter, it shows lower performance by increasing assigned core number by RTS `-N?` option
  * Without any concurrent/parallel function, a process which assigned more cores runs slower than fewer cores
  * Moreover, it shows much longer CPU time then elapsed time in Runtime status
* With the parallel interpreter, it shows lower performance when assigning more core
* Parallel interpreter is little faster than the serial version, but not so fast than expected

## Questions

I know that the parallel version is not so efficient by assigned core number.
But there still exist the problems.

### Why serial version is affected by core number?

Even only printing `aScript`, it takes x3 CPU time then elapsed time when 8-core assigned.
Does the GHC makes executing `print` function parallel implicitly?
Yes, I applied `-threaded` option, but `print` function seems not be parallel.

### Why serial version shows lower performance when assigning more core?

When I assign more core to the program, the performance becomes slower.
I can't understand, why it shows like that way.

## Investigation with ThreadScope

### Serial version (-N4, single)

Use single core, but GC runs parallel.

### Parallel version (-N4, async)

Use multi core in some part, but not all part.

## Fix

### For Serial version

Optimize RTS option that limiting assigned number of core for GC.

### For Parallel version

Arithmetic calculation was not finished in each thread.
Therefore, the arithmetic calculation was executed in single thread.

To avoid this situation, add `seq` when return the `Env`.
