# [Project Euler](http://projecteuler.net/)  ::  Algorithms

## Prime numbers

* 1 is not a prime.
* All primes except 2 are odd.
* All primes greater than 3 can be written in the form $6k+/-1$.
* Any number n can have only one prime factor greater than sqrt(n) .
* The consequence for primality testing of a number n is: if we cannot find a number f less than or equal $\sqrt{n}$ that divides $n$ then $n$ is prime: the only prime factor of $n$ is $n$ itself.

### Function isPrime

```none
function isPrime(n)
    if n=1 then return false
    else
    if n<4 then return true //2 and 3 are prime
    else
    if n mod 2=0 then return false
    else
    if n<9 then return true //we have already excluded 4,6 and 8.
    else
    if n mod 3=0 then return false
    else
    r=floor( sqrt( n ) ) // sqrt(n) rounded to the greatest integer r so that r*r<=n
    f=5
    while f<=r
    if n mod f=0 then return false (and step out of the function)
    if n mod(f+2)=0 then return false (and step out of the function)
    f=f+6
    end while
    return true (in all other cases)
End Function
```

### The sieve of Eratosthenes

The basic idea behind this ancient method is that instead of looking for divisors d of n, we mark multiples of d as composites. Since every composite has a prime divisor, the marking of multiples need only be done for primes. The classical
algorithm is:

* Make a list of all numbers from 2 to N.

* Find the next number p not yet crossed out. This is a prime. If it is greater than $\sqrt{N}$ go to 5.

* Cross out all multiples of p which are not yet crossed out.

* Go to 2.

* The numbers not crossed out are the primes not exceeding $N$.

You only need to start crossing out multiples at $\frac{p}{2}$, because any smaller multiple
of p has a prime divisor less than p and has already been crossed out as a multiple
of that. This is also the reason why we can stop after we've reached $\sqrt{N}$.

### Largest prime factor

Every number $n$ can at most have one prime factor greater than $\sqrt{n}$ . If we,
after dividing out some prime factor, calculate the square root of the remaining number we
can use that square root as upper limit for factor. If factor exceeds this square root
we know the remaining number is prime.

Triangle number:
$1 + 2 + 3 + 4 + 5 + .. + n = \frac{n(n+1)}{2}$

### Divisors

Any integer N can be expressed as follows:

$N = p_1^{a_1}*p_2^{a_2}*p_3^{a_3}*...$

where $p_n$ is a distinct prime number, and an is its exponent.

For example, $28 = 2^2 + 7^1$

Furthermore, the number of divisors $D(N)$ of any integer $N$ can be computed from:
$D(N) = (a_1+1) *(a_2 + 1)*(a_3 + 1) * ...$
an being the exponents of the distinct prime numbers which are factors of $N$

For example, the number of divisors of 28 would be:
$D(28) = (2+1)*(1+1) = 3*2 = 6$
A table of primes will be required to apply this relationship. The efficient preparation of a prime
table is already covered in the overview for Problem 7 and will not be discussed here. Since the largest expected triangle number is within a 32-bit integer, a table containing primes up to 65500.

### Pascal Triangle

```bash
1 1 1 1
1 2 3 4
1 3 6 10
1 4 10 20
```
