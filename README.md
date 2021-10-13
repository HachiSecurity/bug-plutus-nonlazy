*overzZzealous* in Plutus Starter
=================================

We identified an issue in the semantics of Plutus Core, which we refer to as
*overzZzealous*. This issue may slow down and raise the cost of evaluating code
on the Cardano blockchain, or even cause validators to reject transactions and
thus block assets. Since developers rarely engage with Plutus Core directly,
most are oblivious to *overzZzealous*. Furthermore, as the problem comes from
the design of Plutus Core, it is challenging to address.

This project aims to demonstrate *overzZzealous* within the Plutus Starter
project. It is not meant to be used as a starter project. It contains two
branches:

- [`upstream`][branch-upstream] is the state of the `main` branch of [the
  upstream project][upstream] at the time of the fork and
- [`overzzzealous`][branch-overzzzealous] adds one commit on top of `upstream`
  to help demonstrating *overzZzealous* and update the README that you are
  currently reading.

[branch-upstream]:      https://github.com/HachiSecurity/overzzzealous-in-plutus-starter/tree/upstream
[branch-overzzzealous]: https://github.com/HachiSecurity/overzzzealous-in-plutus-starter/tree/overzzzealous

For more details, please see:

- [the blog post associated to *overzZzealous*][blogpost],
- [the GitHub issue associated to *overzZzealous*][issue] and
- [the upstream Plutus Starter project][upstream].

[blogpost]: https://blog.hachi.one/post/overzzzealous-peculiar-semantics-or-and-plutus-core
[upstream]: https://github.com/input-output-hk/plutus-starter
[issue]:    https://github.com/input-output-hk/plutus/issues/4114
